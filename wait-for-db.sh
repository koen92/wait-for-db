#!/bin/bash

set -e
DEBUG=false
VERBOSE=true

TRIES=20
SECONDS=1.0
INITIALIZED=0
PATH=`pwd`/node_modules/.bin:$PATH

which knex > /dev/null || ( echo "Usage: npm install" >&2; exit 11 )

usage() {
  cat <<EOF >&2
Usage: $(basename $0) [-d] [-v] [-q] [-i] [-t tries] [-s seconds] [-f knexfile]
    -d debug (default=$DEBUG)
    -v verbose (default=$VERBOSE)
    -q quiet operation, turn debug and verbose off
    -i wait until db is initialized (default=$INITIALIZED)
    -t how many tries are done (default=$TRIES)
    -s how many seconds to wait between tries (default=$SECONDS)
    -f use a custom filename for --knexfile

Wait for the db to be up and/or initialized using knex. It exits successfully as soon as the db
is in the desired state. If the db remains offline after the maximum tries the scripts exits
with an error.
EOF
  exit 12;
}

while getopts "hdvqit:s:f:" opt; do
  case $opt in
    d) DEBUG=true; set -x ;; # debug
    v) VERBOSE=true ;; # verbose
    q) DEBUG=false; VERBOSE=false ;; # quiet
    t) TRIES=$OPTARG ;;
    s) SECONDS=$OPTARG ;;
    i) INITIALIZED=1 ;;
    f) KNEXFILE=$OPTARG ;;
    \?) echo "Invalid option: -"$OPTARG"" >&2; usage;;
    h) usage;;
  esac
done


if [ "$KNEXFILE" ]
then
  KF="--knexfile $(basename $KNEXFILE)"
  cd $(dirname $KNEXFILE)
fi

DB_STATUS=''
DB_UP=2
for i in $(seq $TRIES -1 1)
do
  DB_STATUS=$(knex $KF migrate:currentVersion 2>/dev/null | awk '/Current Version:/{print $3}')
  : "($i) DB_STATUS=$DB_STATUS"
  case "$DB_STATUS" in
    "")
      $VERBOSE && echo "($i) db is down"
      DB_UP=2
      ;;
    "none")
      $VERBOSE && echo "($i) db is up but empty"
      DB_UP=$INITIALIZED
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
  sleep $SECONDS
done

$VERBOSE && echo "(0) exit status=$DB_UP"
exit $DB_UP
