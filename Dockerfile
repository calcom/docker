FROM node:14-alpine as deps

RUN apk add --no-cache libc6-compat
RUN mkdir app
COPY calendso/package.json calendso/yarn.lock /app/
COPY calendso/prisma /app/prisma
WORKDIR /app
RUN ls
RUN yarn install

FROM node:14-alpine as builder
COPY calendso /app
COPY --from=deps /app/node_modules /app/node_modules
WORKDIR /app
# RUN yarn install

FROM node:14-alpine as runner
ENV NODE_ENV production

# copy all files
COPY --from=builder /app /app
COPY .env /app/.env
# COPY --from=builder /app/next.config.js ./
# COPY --from=builder /app/public ./public
# COPY --from=builder /app/.next ./.next
# COPY --from=builder /app/node_modules ./node_modules
# COPY --from=builder /app/package.json ./package.json
# COPY --from=builder /app/prisma ./prisma
COPY  scripts /app/scripts
WORKDIR /app
EXPOSE 3000
CMD ["/app/scripts/start.sh"]