FROM node:14-alpine as deps
WORKDIR /app
COPY calendso/package.json .
COPY calendso/prisma prisma
RUN yarn install --frozen

FROM node:14-alpine as builder
WORKDIR /app
COPY calendso .
COPY --from=deps /app/node_modules ./node_modules
RUN yarn build
RUN yarn install --production --ignore-scripts --prefer-offline

FROM node:14-alpine as runner
WORKDIR /app
ENV NODE_ENV production

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/prisma ./prisma
COPY  scripts scripts
EXPOSE 3000
CMD ["/app/scripts/start.sh"]