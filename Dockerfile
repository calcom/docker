FROM node:14 as builder

ARG BASE_URL
ARG NEXT_PUBLIC_APP_URL
ARG NEXT_PUBLIC_LICENSE_CONSENT
ARG NEXT_PUBLIC_TELEMETRY_KEY

RUN apt-get update && \
    apt-get -y install netcat && \
    rm -rf /var/lib/apt/lists/* && \
    npm install --global prisma

COPY calcom /calcom
WORKDIR calcom
RUN yarn install --frozen-lockfile
WORKDIR /calcom/apps/web

ENV BASE_URL=$BASE_URL \
    NEXT_PUBLIC_APP_URL=$NEXT_PUBLIC_APP_URL \
    NEXT_PUBLIC_LICENSE_CONSENT=$NEXT_PUBLIC_LICENSE_CONSENT \
    NEXT_PUBLIC_TELEMETRY_KEY=$NEXT_PUBLIC_TELEMETRY_KEY

RUN yarn build

EXPOSE 3000
ENTRYPOINT ["scripts/start.sh"]
