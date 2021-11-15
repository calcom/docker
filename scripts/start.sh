#!/bin/sh

/app/scripts/wait-for-it.sh ${DATABASE_HOST} -- echo "db is up";
npx prisma migrate deploy
yarn start;
