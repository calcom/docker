#!/bin/sh

if [ -n "${CALCOM_LICENSE_KEY_FILE}" ]; then
  CALCOM_LICENSE_KEY=$(cat "$CALCOM_LICENSE_KEY_FILE")
  export CALCOM_LICENSE_KEY
fi

if [ -n "${CALENDSO_ENCRYPTION_KEY_FILE}" ]; then
  CALENDSO_ENCRYPTION_KEY=$(cat "$CALENDSO_ENCRYPTION_KEY_FILE")
  export CALENDSO_ENCRYPTION_KEY
fi

if [ -n "${EMAIL_SERVER_PASSWORD_FILE}" ]; then
  EMAIL_SERVER_PASSWORD=$(cat "$EMAIL_SERVER_PASSWORD_FILE")
  export EMAIL_SERVER_PASSWORD
fi

if [ -n "${GOOGLE_API_CREDENTIALS_FILE}" ]; then
  GOOGLE_API_CREDENTIALS=$(cat "$GOOGLE_API_CREDENTIALS_FILE")
  export GOOGLE_API_CREDENTIALS
fi

if [ -n "${NEXTAUTH_SECRET_FILE}" ]; then
  NEXTAUTH_SECRET=$(cat "$NEXTAUTH_SECRET_FILE")
  export NEXTAUTH_SECRET
fi

if [ -n "${POSTGRES_PASSWORD_FILE}" ]; then
  POSTGRES_PASSWORD=$(cat "$POSTGRES_PASSWORD_FILE")
  export POSTGRES_PASSWORD
fi

if [ -n "${MS_GRAPH_CLIENT_SECRET_FILE}" ]; then
  MS_GRAPH_CLIENT_SECRET=$(cat "$MS_GRAPH_CLIENT_SECRET_FILE")
  export MS_GRAPH_CLIENT_SECRET
fi

if [ -n "${ZOOM_CLIENT_SECRET_FILE}" ]; then
  ZOOM_CLIENT_SECRET=$(cat "$ZOOM_CLIENT_SECRET_FILE")
  export ZOOM_CLIENT_SECRET
fi

if [ ! -n "${DATABASE_URL}" ]; then
  DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${DATABASE_HOST}/${POSTGRES_DB}
  export DATABASE_URL
fi

set -x

# Replace the statically built BUILT_NEXT_PUBLIC_WEBAPP_URL with run-time NEXT_PUBLIC_WEBAPP_URL
# NOTE: if these values are the same, this will be skipped.
scripts/replace-placeholder.sh "$BUILT_NEXT_PUBLIC_WEBAPP_URL" "$NEXT_PUBLIC_WEBAPP_URL"

scripts/wait-for-it.sh ${DATABASE_HOST} -- echo "database is up"
npx prisma migrate deploy --schema /calcom/packages/prisma/schema.prisma
npx ts-node --transpile-only /calcom/packages/prisma/seed-app-store.ts
yarn start
