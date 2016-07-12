#!/bin/bash

set -e
DEBUG=false
$DEBUG && set -x
VERBOSE=true

ATTEMPTS=${1:-20}
INTERVAL=${2:-1.0}
MINIMUM=${3:-5}
PATH=`pwd`/node_modules/.bin:$PATH

DB_STATUS=''
DB_UP=2
for i in $(seq $ATTEMPTS -1 1)
do
  DB_STATUS=$(knex migrate:currentVersion 2>/dev/null | awk '/Current Version:/{print $3}')
  : "($i) DB_STATUS=$DB_STATUS"
  case "$DB_STATUS" in
    "")
      $VERBOSE && echo "($i) db is down"
      DB_UP=2
      ;;
    "none")
      $VERBOSE && echo "($i) db is up but empty"
      DB_UP=0
      ;;
    *)
      $VERBOSE && echo "($i) db is up and initialized"
      DB_UP=0
      ;;
  esac
  : "($i) DB_UP=$DB_UP"
  if [ $DB_UP -eq 0 ]
  then
    break
  fi
  sleep $INTERVAL
done

$VERBOSE && echo "(0) exit status=$DB_UP"
exit $DB_UP
