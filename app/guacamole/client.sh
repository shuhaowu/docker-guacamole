#!/bin/bash

export CATALINA_PID="/app/tmp/tomcat.pid"
export CATALINA_HOME="/usr/share/tomcat9"
export CATALINA_BASE="/var/lib/tomcat9"

wait_for_mysql() {
  port=$1
  echo "Waiting for MySQL at port $port..."
  attempts=0
  while ! mysql -u guacamole -pguacamole -h 127.0.0.1 -P 3306 -e "SELECT 1"; do
    sleep 1
    attempts=$((attempts + 1))
    if (( attempts > 120 )); then
      echo "ERROR: mysql $port was not started." >&2
      exit 1
    fi
  done
  echo "MySQL at port $port has started!"
}

wait_for_mysql 3306
exec /usr/share/tomcat9/bin/catalina.sh run
