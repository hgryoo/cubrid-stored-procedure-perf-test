#!/bin/bash

if [ -z "$CUBRID" ]; then
  exit 1
fi

DBNAME=testdb

DBCONF_DIR=$CUBRID/conf

DBMETHOD_DIR=$CUBRID/method
DBJAVASP_DIR=$CUBRID_DATABASES/$DBNAME/java

DBLOG_DIR=$CUBRID/log
DBLOG_SERVER_DIR=$DBLOG_DIR/server
DBLOG_BROKER_DIR=$DBLOG_DIR/broker

DBLOG_SERVER_LATEST=${DBNAME}_latest.err
DBLOG_JAVASP_LOG=${DBNAME}_java.log
DBLOG_JAVASP_ERR=${DBNAME}_java.err

echo "Build Environments"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "DBNAME: $DBNAME"
echo "CUBRID: $CUBRID"
echo "CUBRID_DATABASES: $CUBRID_DATABASES"
echo "DBCONF_DIR: $DBCONF_DIR"
echo "DBLOG_DIR: $DBLOG_DIR"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"