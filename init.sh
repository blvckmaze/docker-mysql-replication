#!/bin/bash

set -e

DC='docker compose exec -T'
DOCKER_SUBNET_RANGE='0.0.0.0/0'

MASTER_ROOT_PASSWORD='cat .env.master | grep MYSQL_ROOT_PASSWORD | cut -d = -f 2'
MASTER_STATUS="$DC mysql_master mysql --login-path=local -e 'SHOW MASTER STATUS'"

SLAVE_USER='cat .env.slave | grep MYSQL_USER | cut -d = -f 2'
SLAVE_PASSWORD='cat .env.slave | grep MYSQL_PASSWORD | cut -d = -f 2'
SLAVE_ROOT_PASSWORD='cat .env.slave | grep MYSQL_ROOT_PASSWORD | cut -d = -f 2'

SOURCE_LOG_FILE="$MASTER_STATUS | awk '{print \$1}' | grep mysql"
SOURCE_LOG_POS="$MASTER_STATUS | awk '{print \$2}' | grep -o '[[:digit:]]*'"

TRIM_NEWLINE='| rev | cut -c2- | rev'

function init_master {
  $DC mysql_master mysql_config_editor reset
  echo $(eval $MASTER_ROOT_PASSWORD) | $DC mysql_master mysql_config_editor set --login-path=local --host=localhost --user=root --password

  sed -i "1s|.*|CREATE USER '$(eval $SLAVE_USER $TRIM_NEWLINE)'@'$DOCKER_SUBNET_RANGE' IDENTIFIED WITH mysql_native_password BY '$(eval $SLAVE_PASSWORD $TRIM_NEWLINE)';|" $PWD/sql/master.sql
  sed -i "2s|.*|GRANT REPLICATION SLAVE ON *.* TO '$(eval $SLAVE_USER $TRIM_NEWLINE)'@'$DOCKER_SUBNET_RANGE';|" $PWD/sql/master.sql

  $DC mysql_master mysql --login-path=local < $PWD/sql/master.sql
}

function init_slave {
  $DC mysql_slave mysql_config_editor reset
  echo $(eval $SLAVE_ROOT_PASSWORD) | $DC mysql_slave mysql_config_editor set --login-path=local --host=localhost --user=root --password

  sed -i "3s|.*|SOURCE_USER='$(eval $SLAVE_USER $TRIM_NEWLINE)',|" $PWD/sql/slave.sql
  sed -i "4s|.*|SOURCE_PASSWORD='$(eval $SLAVE_PASSWORD $TRIM_NEWLINE)',|" $PWD/sql/slave.sql
  sed -i "5s|.*|SOURCE_LOG_FILE='$(eval $SOURCE_LOG_FILE)',|" $PWD/sql/slave.sql
  sed -i "6s|.*|SOURCE_LOG_POS=$(eval $SOURCE_LOG_POS);|" $PWD/sql/slave.sql

  $DC mysql_slave mysql --login-path=local < $PWD/sql/slave.sql
}

init_master
init_slave
