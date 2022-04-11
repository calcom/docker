FROM node:14 as deps

WORKDIR /calcom

# Copy rootand all workspace package.json files
COPY calendso/package.json calendso/yarn.lock ./
COPY calendso/apps/web/package.json calendso/apps/web/yarn.lock ./apps/web/
COPY calendso/packages/ui/package.json ./packages/ui/package.json
COPY calendso/packages/types/package.json ./packages/types/package.json
COPY calendso/packages/core/package.json ./packages/core/package.json
COPY calendso/packages/config/package.json ./packages/config/package.json
COPY calendso/packages/ee/package.json ./packages/ee/package.json
COPY calendso/packages/tsconfig/package.json ./packages/tsconfig/package.json
COPY calendso/packages/prisma/package.json ./packages/prisma/package.json
COPY calendso/packages/app-store/googlevideo/package.json ./packages/app-store/googlevideo/package.json
COPY calendso/packages/app-store/caldavcalendar/package.json ./packages/app-store/caldavcalendar/package.json
COPY calendso/packages/app-store/zoomvideo/package.json ./packages/app-store/zoomvideo/package.json
COPY calendso/packages/app-store/huddle01video/package.json ./packages/app-store/huddle01video/package.json
COPY calendso/packages/app-store/jitsivideo/package.json ./packages/app-store/jitsivideo/package.json
COPY calendso/packages/app-store/stripepayment/package.json ./packages/app-store/stripepayment/package.json
COPY calendso/packages/app-store/office365video/package.json ./packages/app-store/office365video/package.json
COPY calendso/packages/app-store/office365calendar/package.json ./packages/app-store/office365calendar/package.json
COPY calendso/packages/app-store/slackmessaging/package.json ./packages/app-store/slackmessaging/package.json
COPY calendso/packages/app-store/tandemvideo/package.json ./packages/app-store/tandemvideo/package.json
COPY calendso/packages/app-store/package.json ./packages/app-store/package.json
COPY calendso/packages/app-store/_example/package.json ./packages/app-store/_example/package.json
COPY calendso/packages/app-store/googlecalendar/package.json ./packages/app-store/googlecalendar/package.json
COPY calendso/packages/app-store/dailyvideo/package.json ./packages/app-store/dailyvideo/package.json
COPY calendso/packages/app-store/applecalendar/package.json ./packages/app-store/applecalendar/package.json
COPY calendso/packages/lib/package.json ./packages/lib/package.json
COPY calendso/packages/embeds/embed-snippet/package.json ./packages/embeds/embed-snippet/package.json
COPY calendso/packages/embeds/embed-react/package.json ./packages/embeds/embed-react/package.json
COPY calendso/packages/embeds/embed-core/package.json ./packages/embeds/embed-core/package.json
COPY calendso/packages/stripe/package.json ./packages/stripe/package.json

# Prisma schema is required by a post-install script
COPY calendso/packages/prisma/schema.prisma ./packages/prisma/schema.prisma

# Install dependencies
RUN yarn install --frozen-lockfile

FROM node:14 as builder

WORKDIR /calcom
ARG BASE_URL
ARG NEXT_PUBLIC_APP_URL
ARG NEXT_PUBLIC_LICENSE_CONSENT
ARG NEXT_PUBLIC_TELEMETRY_KEY
ENV BASE_URL=$BASE_URL \
    NEXT_PUBLIC_APP_URL=$NEXT_PUBLIC_APP_URL \
    NEXT_PUBLIC_LICENSE_CONSENT=$NEXT_PUBLIC_LICENSE_CONSENT \
    NEXT_PUBLIC_TELEMETRY_KEY=$NEXT_PUBLIC_TELEMETRY_KEY

COPY calendso/package.json calendso/yarn.lock calendso/turbo.json ./
COPY calendso/apps/web ./apps/web
COPY calendso/packages ./packages
COPY --from=deps /calcom/node_modules ./node_modules
RUN yarn build && yarn install --ignore-scripts --prefer-offline

FROM node:14 as runner
WORKDIR /calcom
ENV NODE_ENV production
RUN apt-get update && \
    apt-get -y install netcat && \
    rm -rf /var/lib/apt/lists/* && \
    npm install --global prisma

COPY calendso/package.json calendso/yarn.lock calendso/turbo.json ./
COPY --from=builder /calcom/node_modules ./node_modules
COPY --from=builder /calcom/packages ./packages
COPY --from=builder /calcom/apps/web/node_modules ./apps/web/node_modules
COPY --from=builder /calcom/apps/web/scripts ./apps/web/scripts
COPY --from=builder /calcom/apps/web/next.config.js ./apps/web/next.config.js
COPY --from=builder /calcom/apps/web/next-i18next.config.js ./apps/web/next-i18next.config.js
COPY --from=builder /calcom/apps/web/public ./apps/web/public
COPY --from=builder /calcom/apps/web/.next ./apps/web/.next
COPY --from=builder /calcom/apps/web/package.json ./apps/web/package.json
COPY scripts scripts

EXPOSE 3000
CMD ["/calcom/scripts/start.sh"]
