# syntax=docker/dockerfile:1
#     ^ Syntax version >= 1.5 is needed for `ADD`ing a git repository.

# Reference:
#  - https://github.com/calcom/docker/blob/main/Dockerfile
#  - https://cal.com/docs/introduction/quick-start/self-hosting/installation#development-setup-&-production-build
#  - https://cal.com/docs/introduction/quick-start/self-hosting/upgrading
#  - https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md
#  - https://github.com/docker/docker-bench-security/tree/master
#  - https://yarnpkg.com/cli/workspaces/focus#details

# ---------------------------------
FROM node:18-alpine as builder

ARG CALCOM_BRANCH=v3.4.3

# Set this to '1' if you don't want Cal to collect anonymous usage
ENV CALCOM_TELEMETRY_DISABLED=0
# CHECKPOINT_DISABLE disables Prisma's telemetry
ENV CHECKPOINT_DISABLE=0
ENV NEXT_TELEMETRY_DISABLED=0
ENV NODE_ENV=production
ENV STORYBOOK_DISABLE_TELEMETRY=0

WORKDIR /cal.com

ADD --keep-git-dir=false https://github.com/calcom/cal.com.git#${CALCOM_BRANCH} /cal.com

# Notice yarn telemetry can be set here.
RUN \
    --mount=type=cache,target=/caches \
    yarn config set enableTelemetry 1 && \
    yarn config set cacheFolder /caches/yarn && \
    yarn config set httpTimeout 1200000 && \
    yarn install

# Set CI so that linting and type checking are skipped during the build.  This is to lower the build time.  Seems to have no other effects in Cal.com during build (currently).  Defaults `yarn install` to use `--immutable`, which isn't desirable here because `yarn.lock` needs to be rebuilt, so it is set here after `yarn install` has already run.
ENV CI=1

# Use a secret mount for the environment variables, to avoid passing in build args.  The secrets are only stored in memory, not in the container layer.  Tooling caches are preserved to speed future builds.
RUN \
    --mount=type=cache,target=/cal.com/apps/web/.next/cache \
    --mount=type=cache,target=/cal.com/node_modules/.cache \
    --mount=type=secret,id=calcom-environment,target=/cal.com/.env \
    set -a && . .env && set +a && \
    npx turbo run build --filter=@calcom/web...

# The Next.js and Turbo caches are stored for future builds in the previous layer.  Since neither tool allows moving its cache directory outside of the default location inside `/cal.com`, the directories are removed here so they don't get copied to the runner later.
RUN rm -rf /cal.com/apps/web/.next/cache /cal.com/node_modules/.cache

# ---------------------------------
FROM node:18-alpine as runner
WORKDIR /cal.com

# Copy appropriate directories.
COPY --from=builder --chown=node:node /cal.com/.yarn/ .yarn/
COPY --from=builder --chown=node:node /cal.com/apps/web/ apps/web/
COPY --from=builder --chown=node:node /cal.com/packages/ packages/
COPY --from=builder --chown=node:node /cal.com/node_modules/ node_modules/

# Copy individual files.
COPY --from=builder --chown=node:node \
    /cal.com/.yarnrc.yml \
    /cal.com/package.json \
    /cal.com/turbo.json \
    /cal.com/yarn.lock \
    /cal.com/
COPY --from=builder --chown=node:node /cal.com/packages/prisma/schema.prisma prisma/schema.prisma

# Copy the scripts used to start the container, and make them executable.
COPY --chmod=555 --chown=node:node \
    scripts/start.sh \
    scripts/wait-for-it.sh \
    /cal.com/scripts/

# This symlink is not needed to build this way.  Harmless to leave it in, but unlinking it cleans up a large warning in the logs.
RUN unlink /cal.com/packages/prisma/.env

# Set this to '1' if you don't want Cal to collect anonymous usage
ENV CALCOM_TELEMETRY_DISABLED=0
ENV NEXT_TELEMETRY_DISABLED=0
ENV NODE_ENV=production
ENV STORYBOOK_DISABLE_TELEMETRY=0

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=30s --retries=5 \
    CMD wget --spider http://localhost:3000 || exit 1

USER node
CMD ["/cal.com/scripts/start.sh"]
