#!/bin/sh

# Setup database
yarn db-deploy
yarn --cwd packages/prisma seed-app-store

# Build project
yarn turbo run build --filter=@calcom/web

# Start server
yarn start
