FROM node:18 as builder

WORKDIR /calcom

COPY calcom .
COPY .env /calcom

RUN yarn config set httpTimeout 1200000 && \ 
    npx turbo prune --scope=@calcom/web --docker && \
    yarn install

RUN yarn db-deploy && \
    yarn --cwd packages/prisma seed-app-store

RUN NODE_OPTIONS="--max-old-space-size=8192" yarn turbo run build --filter=@calcom/web    

FROM node:18 as runner

WORKDIR /calcom

COPY calcom/package.json calcom/.yarnrc.yml calcom/yarn.lock calcom/turbo.json ./
COPY calcom/.yarn ./.yarn
COPY --from=builder /calcom/node_modules ./node_modules
COPY --from=builder /calcom/packages ./packages
COPY --from=builder /calcom/apps/web ./apps/web
COPY --from=builder /calcom/packages/prisma/schema.prisma ./prisma/schema.prisma
COPY --from=builder /calcom/.env .
# COPY scripts/bootstrap.sh .

CMD ["/bin/sh", "-c", "bash"]
# CMD ["bootstrap.sh"]
