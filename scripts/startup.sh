#!/bin/bash

DBNAME="demodb"

IS_SERVER_RUNNING=$(cubrid server status | grep "Server $DBNAME")
IS_JAVASP_RUNNING=$(cubrid javasp status $DBNAME | grep "Java Stored Procedure Server ($DBNAME")

if [ "$IS_SERVER_RUNNING" == "" ] || [ "$IS_JAVASP_RUNNING" == "" ];
then
    cubrid service start
else
    cubrid service restart
fi

JAVASP_PID=$(cubrid javasp status $DBNAME | grep pid | awk -F"[ ,]" '{print $8}')

echo "Runtime Environments"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "JAVASP_PID: $JAVASP_PID"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

