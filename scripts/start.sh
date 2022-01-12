#!/bin/bash
set -x

# # Set environment variables
# echo NEXT_PUBLIC_APP_URL $NEXT_PUBLIC_APP_URL
# find \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s#$NEXT_PUBLIC_APP_URL#$NEXT_PUBLIC_APP_URL_SUBSTITUTE#g"

/app/scripts/wait-for-it.sh ${DATABASE_HOST} -- echo "database is up"
npx prisma migrate deploy
if [[ $NODE_ENV == "development" ]]; then
    yarn dev
else
    yarn start
fi