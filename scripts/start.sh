#!/bin/sh

# Database deploy
yarn workspace @calcom/prisma db-deploy
yarn workspace @calcom/prisma seed-app-store

# Server start
yarn start
