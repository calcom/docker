FROM node:14 as builder

WORKDIR /calcom
ARG NEXT_PUBLIC_WEBAPP_URL
ARG NEXT_PUBLIC_APP_URL
ARG NEXT_PUBLIC_LICENSE_CONSENT
ARG NEXT_PUBLIC_TELEMETRY_KEY
ARG DATABASE_URL

ENV NEXT_PUBLIC_WEBAPP_URL=$NEXT_PUBLIC_WEBAPP_URL \
    NEXT_PUBLIC_APP_URL=$NEXT_PUBLIC_APP_URL \
    NEXT_PUBLIC_LICENSE_CONSENT=$NEXT_PUBLIC_LICENSE_CONSENT \
    NEXT_PUBLIC_TELEMETRY_KEY=$NEXT_PUBLIC_TELEMETRY_KEY \
    DATABASE_URL=$DATABASE_URL

COPY calcom/package.json calcom/yarn.lock calcom/turbo.json ./
COPY calcom/apps/web ./apps/web
COPY calcom/packages ./packages

RUN yarn install --frozen-lockfile

RUN yarn build

FROM node:14 as runner

WORKDIR /calcom
ENV NODE_ENV production

RUN apt-get update && \
    apt-get -y install netcat && \
    rm -rf /var/lib/apt/lists/* && \
    npm install --global prisma

COPY calcom/package.json calcom/yarn.lock calcom/turbo.json ./
COPY --from=builder /calcom/node_modules ./node_modules
COPY --from=builder /calcom/packages ./packages
COPY --from=builder /calcom/apps/web ./apps/web
COPY scripts scripts

EXPOSE 3000
CMD ["/calcom/scripts/start.sh"]
