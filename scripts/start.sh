#!/usr/bin/env bash
# set -x ## uncomment for debug

## Environment Config
function ifndef () {
  ## Test for null variable and set default, echo result to stdout.
  export ${1}="${!1:=$2}" 
  echo "$1 is ${!1}"
}

ifndef NEXT_PUBLIC_WEBAPP_URL      "http://localhost:3000"
ifndef NEXT_PUBLIC_APP_URL         "http://localhost:3000"
## Must be manually overridden to "true" by end user.
ifndef NEXT_PUBLIC_LICENSE_CONSENT "false"

## If you want to keep your secrets set this to 1
ifndef CALCOM_TELEMETRY_DISABLED   "0"

## Database Config, usually good to be set as default.
ifndef POSTGRES_USER               "postgres"
ifndef POSTGRES_PASSWORD           "postgres"
ifndef POSTGRES_DB                 "postgres"
ifndef POSTGRES_PORT               "5432"

## Use this in a case where you have an external DB.
ifndef POSTGRES_ADDRESS            "postgres"
## More database environment strings required for launch.
ifndef DATABASE_HOST               "$POSTGRES_ADDRESS:$POSTGRES_PORT"
ifndef DATABASE_URL                "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${DATABASE_HOST}/${POSTGRES_DB}"
## Cryptography and secrets.
ifndef NEXTAUTH_SECRET             $([ -f /config/NEXTAUTH_SECRET ] && cat /config/NEXTAUTH_SECRET)
ifndef CALENDSO_ENCRYPTION_KEY     $([ -f /config/CALENDSO_ENCRYPTION_KEY ] && cat /config/CALENDSO_ENCRYPTION_KEY)

## Other settings that are mostly for container internal operations but are available for customization if desired.
ifndef MAX_OLD_SPACE_SIZE          4096
ifndef NODE_OPTIONS                "--max-old-space-size=$MAX_OLD_SPACE_SIZE"
ifndef RELEASE_COMMIT_ID           "6b0ac96b38b0dbd78809a73e19010192f31cc769"
ifndef REPOSITORY_URL              "https://github.com/calcom/cal.com.git"
ifndef APP_PATH                    "/calendso"

function basic_start() {
  cd $APP_PATH
  echo "Waiting for a healthy Postgres server connection prior to booting."
  wait-for-it.sh $DATABASE_HOST -- echo "database is up"
  npx prisma migrate deploy --schema $APP_PATH/packages/prisma/schema.prisma
  npx ts-node --transpile-only $APP_PATH/packages/prisma/seed-app-store.ts
  echo "Final systems checks cleared and are go for launch."
  yarn start
}

function bootstrap_copyandcleanup() {
  cp -Rfv /tmp/calendso/node_modules $APP_PATH/node_modules
  cp -Rfv /tmp/calendso/packages $APP_PATH/packages
  cp -Rfv /tmp/calendso/apps/web $APP_PATH/apps/web
  cp -Rfv /tmp/calendso/packages/prisma/schema.prisma $APP_PATH/prisma/schema.prisma
  cp -Rfv /tmp/calendso/.git $APP_PATH/
  cp -v package.json $APP_PATH/
  cp -v yarn.lock $APP_PATH/
  cp -v turbo.json $APP_PATH/
  cd $APP_PATH
  rm -Rf /tmp/calendso
}

function bootstrap_start() {
  mkdir -p /tmp/calendso
  cd /tmp/calendso
  ## Essentially running "git clone https://github.com/calcom/cal.com.git" with a depth of 1 and to the specific release commit SHA.
  git init .
    git remote add origin https://github.com/calcom/cal.com.git
    git fetch --depth 1 origin $RELEASE_COMMIT_ID
    git checkout FETCH_HEAD
  yarn install --frozen-lockfile
  yarn build
  bootstrap_copyandcleanup
  echo "$RELEASE_COMMIT_ID" > /config/RELEASE_COMMIT_ID && echo "/config/RELEASE_COMMIT_ID is now set to $(cat /config/RELEASE_COMMIT_ID)"
  basic_start
}

## Test for file
function test_for_file() {
  if [[ -f "$1" ]]; then
    echo "$1 exists"
  else
    touch $1
  fi
}

function test_for_dir() {
  if [[ -d $1 ]]; then
    echo "directory $1 exists."
  else
    echo "directory $1 doesn't exist prior to container startup, creating $1"
    mkdir -pv $1
    echo "$1 is not not mounted and will be reset every boot."
    echo "Please mount $1 in your Docker deployment to avoid this message in the future"
    echo "and to persist your environments state beyond the life of this container."
  fi
}

## Will I persist?
function test_for_volume() {
  if grep -qs "$1" /proc/mounts; then
      echo "$1 is a docker volume."
      $2
  else
      test_for_dir $1
      $2
  fi
}

## Preboot Check NEXTAUTH_SECRET
function autoconfigure_nextauth_secret() {
  echo "Rudimentary NEXTAUTH_SECRET test: $NEXTAUTH_SECRET --------- $(cat /config/NEXTAUTH_SECRET)"
  echo "Check if encryption key is set and if not generating a random one and placing it in a /config/NEXTAUTH_SECRET file."
  test_for_volume /config
  test_for_file /config/NEXTAUTH_SECRET
  if [ $(echo $(cat /config/NEXTAUTH_SECRET)|wc -c) != 65 ];
    then
      echo "NEXTAUTH_SECRET seems unset, attempting to set a new secret now."
      RAND32STR=$(tr -dc '[:alnum:]' < /dev/urandom | dd bs=4 count=16 2>/dev/null)
      echo "${NEXTAUTH_SECRET:=$RAND32STR}" > /config/NEXTAUTH_SECRET
      echo "Set the /config/NEXTAUTH_SECRET to the following:"
      cat /config/NEXTAUTH_SECRET
      echo "Secret set and recorded to filesystem, now checking to see if its recorded correctly to the environment."
      autoconfigure_nextauth_secret
    else
      echo "/config/NEXTAUTH_SECRET seems to be correctly installed."
      export NEXTAUTH_SECRET=$(cat /config/NEXTAUTH_SECRET)
      if [[ $NEXTAUTH_SECRET == $(cat /config/NEXTAUTH_SECRET) ]]; then
        echo "NEXTAUTH_SECRET is set correctly in the environment and on disk."
        echo "Rudimentary NEXTAUTH_SECRET postconfigure proof: $NEXTAUTH_SECRET --------- $(cat /config/NEXTAUTH_SECRET)"
      else
        echo "There is something wrong here someone has configured the environment variable NEXTAUTH_SECRET strangely please fix this and start over."
        exit
      fi
  fi
}

## Preboot Check CALENDSO_ENCRYPTION_KEY
function autoconfigure_calendso_encryption_key() {
  echo "Rudimentary CALENDSO_ENCRYPTION_KEY test: $CALENDSO_ENCRYPTION_KEY --------- $(cat /config/CALENDSO_ENCRYPTION_KEY)"
  echo "Check if encryption key is set and if not generating a random one and placing it in a /config/NEXTAUTH_SECRET file."
  test_for_volume /config
  test_for_file /config/CALENDSO_ENCRYPTION_KEY
  if [ $(echo $(cat /config/CALENDSO_ENCRYPTION_KEY)|wc -c) != 65 ];
    then
      echo "CALENDSO_ENCRYPTION_KEY seems unset, attempting to set a new secret now."
      RAND32STR=$(tr -dc '[:alnum:]' < /dev/urandom | dd bs=4 count=16 2>/dev/null)
      echo "${CALENDSO_ENCRYPTION_KEY:=$RAND32STR}" > /config/CALENDSO_ENCRYPTION_KEY
      echo "Set the /config/CALENDSO_ENCRYPTION_KEY to the following:"
      cat /config/CALENDSO_ENCRYPTION_KEY
      echo "Secret set and recorded to filesystem, now checking to see if its recorded correctly to the environment."
      autoconfigure_calendso_encryption_key
    else
      export CALENDSO_ENCRYPTION_KEY=$(cat /config/CALENDSO_ENCRYPTION_KEY)
      echo "/config/CALENDSO_ENCRYPTION_KEY seems to be correctly installed."
      if [[ $CALENDSO_ENCRYPTION_KEY == $(cat /config/CALENDSO_ENCRYPTION_KEY) ]]; then
        echo "CALENDSO_ENCRYPTION_KEY is set correctly in the environment and on disk."
        echo "Rudimentary CALENDSO_ENCRYPTION_KEY postconfigure proof: $CALENDSO_ENCRYPTION_KEY --------- $(cat /config/CALENDSO_ENCRYPTION_KEY)"
      else
        echo "There is something wrong here someone has configured the environment variable CALENDSO_ENCRYPTION_KEY strangely please fix this and start over."
        exit
      fi
  fi
}

## Preboot Check RELEASE_COMMIT_ID
function bootmode_check() {
  echo "Rudimentary RELEASE_COMMIT_ID test: $RELEASE_COMMIT_ID --------- $(cat /config/RELEASE_COMMIT_ID)"
  echo "Check if commit ID is present and is identical to deployed RELEASE_COMMIT_ID."
  test_for_volume /config
  test_for_file /config/RELEASE_COMMIT_ID
  if [ $(echo $(cat /config/RELEASE_COMMIT_ID)|wc -c) == 41 ]; then
    # export RELEASE_COMMIT_ID=$(cat /config/RELEASE_COMMIT_ID)
    # echo "$APP_PATH/RELEASE_COMMIT_ID seems to be correctly installed."
    if [[ $RELEASE_COMMIT_ID == $(cat /config/RELEASE_COMMIT_ID) ]]; then
      # echo "RELEASE_COMMIT_ID is set correctly in the environment and on disk."
      # echo "Rudimentary RELEASE_COMMIT_ID postconfigure proof: $RELEASE_COMMIT_ID --------- $(cat /config/RELEASE_COMMIT_ID)"
      export BOOTMODE="basic_start"
    else
      echo "RELEASE_COMMIT_ID is different from previously installed RELEASE_COMMIT_ID assuming an upgrade is required and setting bootstrap_start."
      export BOOTMODE="bootstrap_start"
    fi
  else
    echo "RELEASE_COMMIT_ID seems incorrect or unset triggering further checks."
    if [[ -z $(cat /config/RELEASE_COMMIT_ID) ]]; then
      echo "Cal is not yet installed setting boot flag for first time installation."
      export BOOTMODE="bootstrap_start"
    fi
  fi
}

## Preflight Checks
autoconfigure_nextauth_secret
autoconfigure_calendso_encryption_key
bootmode_check

## Start app.
case $BOOTMODE in
  basic_start )
    echo "Systems go for basic start."
    basic_start
    ;;
  bootstrap_start )
    echo "Systems go for bootstrap start."
    bootstrap_start
    ;;
  * )
    echo "Invalid BOOTMODE selected. Valid options are basic_start and bootstrap_start."
    echo "BOOTMODE selected was instead: $BOOTMODE"
    ;;
esac
