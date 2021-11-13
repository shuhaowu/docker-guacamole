#!/bin/bash

DATA_DIR=/app/data/mysql
TMP_DIR=/app/tmp/mysql

MYSQLD="/usr/sbin/mysqld --defaults-file=/app/mysql/my.cnf"
MYSQL="/usr/bin/mysql -S $TMP_DIR/mysqld.sock"
SERVER_ID=1

set -xe

mkdir -p $TMP_DIR
chown mysql:mysql -R $TMP_DIR

if [ ! -d "$(dirname $DATA_DIR)" ]; then
  echo "error: /app/data not mounted" >&2
  exit 1
fi

if [ ! -d "$DATA_DIR" ]; then
  # Need to initialize MySQL
  umask 0077

  mkdir $DATA_DIR
  chown mysql:mysql -R $DATA_DIR

  pushd $DATA_DIR
    mkdir data
    mkdir logs
    mkdir tmp
    chown mysql:mysql data
    chown mysql:mysql logs
    chown mysql:mysql tmp

    $MYSQLD --initialize-insecure --user=mysql
  popd

  # Perform database initialization
  $MYSQLD --skip-networking --user=mysql --server-id=${SERVER_ID} &
  pid="$!"

  set +x

  for i in {120..0}; do
    if $MYSQL -e "SELECT 1" >/dev/null 2>&1; then
      break
    fi
    echo "waiting for mysql to startup..."

    sleep 1
  done

  if [ "$i" == 0 ]; then
    echo "error: MySQL startup failed" >&2
    exit 1
  fi

  $MYSQL < /app/mysql/init.sql
  for f in /app/guacamole/schema/*.sql; do
    $MYSQL guacamole < $f
  done

  set -x

  $MYSQL -e "SELECT user, host FROM mysql.user"
  $MYSQL -e "SHOW DATABASES"

  if ! kill -s TERM "$pid" || ! wait "$pid"; then
    echo >&2 'MySQL init process failed.'
    exit 1
  fi
fi

chown mysql:mysql -R $DATA_DIR

exec $MYSQLD --user=mysql --server-id=${SERVER_ID}
