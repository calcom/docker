#!/bin/sh
set -x

/app/scripts/wait-for-it.sh db:5432 -- echo "db is up"
npx prisma db push
yarn start