FROM node:18 as builder

WORKDIR /calcom

ARG MAX_OLD_SPACE_SIZE=4096

ENV NEXT_PUBLIC_WEBAPP_URL=http://NEXT_PUBLIC_WEBAPP_URL_PLACEHOLDER \
    NEXTAUTH_SECRET=NEXTAUTH_SECRET_PLACEHOLDER \
    CALENDSO_ENCRYPTION_KEY=CALENDSO_ENCRYPTION_KEY_PLACEHOLDER \
    NODE_ENV=production \
    NODE_OPTIONS=--max-old-space-size=${MAX_OLD_SPACE_SIZE}

COPY calcom/package.json calcom/yarn.lock calcom/.yarnrc.yml calcom/playwright.config.ts calcom/turbo.json calcom/git-init.sh calcom/git-setup.sh ./
COPY calcom/.yarn ./.yarn
COPY calcom/apps/web ./apps/web
COPY calcom/packages ./packages
COPY calcom/tests ./tests

RUN yarn config set httpTimeout 1200000 && \ 
    npx turbo prune --scope=@calcom/web --docker && \
    yarn install

RUN yarn build

RUN rm -rf node_modules/.cache .yarn/cache apps/web/.next/cache

FROM node:18 as runner

WORKDIR /calcom

COPY --from=builder /calcom ./
COPY scripts scripts

CMD ["/bin/sh", "/calcom/scripts/start.sh"]
