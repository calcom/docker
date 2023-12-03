#!/bin/sh

# Replace http://NEXT_PUBLIC_WEBAPP_URL_PLACEHOLDER
NEXT_PUBLIC_WEBAPP_URL=$(grep "^NEXT_PUBLIC_WEBAPP_URL=" .env | awk -F '=' '{print $2}')
sh scripts/replace-placeholder.sh "http://NEXT_PUBLIC_WEBAPP_URL_PLACEHOLDER" $NEXT_PUBLIC_WEBAPP_URL

# Database deploy
yarn workspace @calcom/prisma db-deploy
yarn workspace @calcom/prisma seed-app-store

# Server start
yarn start
