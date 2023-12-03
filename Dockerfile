FROM node:18

WORKDIR /calcom

ARG MAX_OLD_SPACE_SIZE=4096

ENV NODE_OPTIONS=--max-old-space-size=${MAX_OLD_SPACE_SIZE}

COPY calcom/package.json calcom/yarn.lock calcom/.yarnrc.yml calcom/playwright.config.ts calcom/turbo.json calcom/git-init.sh calcom/git-setup.sh ./
COPY calcom/.yarn ./.yarn
COPY calcom/apps/web ./apps/web
COPY calcom/packages ./packages
COPY calcom/tests ./tests

RUN yarn config set httpTimeout 1200000 && \ 
    npx turbo prune --scope=@calcom/web --docker && \
    yarn install

COPY scripts scripts

CMD ["/bin/sh", "/calcom/scripts/start.sh"]
