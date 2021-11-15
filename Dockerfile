# Install Dependencies
FROM node:14 as builder
WORKDIR /app
COPY calendso/package.json calendso/yarn.lock .
COPY calendso/prisma prisma
RUN yarn install

# Build Cal Image
FROM node:14
WORKDIR /app
COPY --from=builder /app .
COPY calendso .
COPY scripts scripts
RUN wget -t 3 -qO- https://cli.doppler.com/install.sh | sh -s -- --verify-signature
EXPOSE 3000
ENTRYPOINT  if [ -z "$DOPPLER_TOKEN" ]; then         \
              /app/scripts/start.sh;                 \
            else                                     \
              doppler run -- /app/scripts/start.sh;  \
            fi
