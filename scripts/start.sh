#!/bin/sh

set -xeuo pipefail

# Export all the variables from the `.env` file to the current shell instance.  The secrets are stored in memory, only while the container is running.
set -a
. .env
set +a

scripts/wait-for-it.sh ${DATABASE_HOST} -- echo "database is up"

# Run commands directly, instead of through e.g. `yarn db-deploy; yarn start`.  This is generally preferred for reasons like SIGINT handling, error reporting, running fewer processes, etc.  This could get out of sync with the various `package.json` and `turbo.json` files, and in that case these commands would need to be updated.
PATH=$PATH:$PWD/node_modules/.bin/

# `yarn db-deploy` => `turbo run db-deploy` =>
prisma migrate deploy packages/prisma/migrations/**/*.sql

# yarn --cwd packages/prisma seed-app-store =>
ts-node --transpile-only packages/prisma/seed-app-store.ts

# `yarn start` => `turbo run start --scope="@calcom/web"` =>
cd apps/web
next start
