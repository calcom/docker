#!/bin/sh

# Setup database
yarn workspace @calcom/prisma db-deploy
yarn workspace @calcom/prisma seed-app-store

# Build project
yarn build

# Start server
yarn start
