#!/bin/sh

VARIABLE_NAME=$1
ENV_PATH=${2:-".env"}

RESULT=$(grep -v '^#' $ENV_PATH | grep "^$VARIABLE_NAME=" | xargs | awk -F '=' '{print $2}')
echo $RESULT