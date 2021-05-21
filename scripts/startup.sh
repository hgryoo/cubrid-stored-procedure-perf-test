#!/bin/bash

cubrid service start

JAVASP_PID=$(cubrid javasp status $DBNAME | grep pid | awk -F"[ ,]" '{print $8}')

echo "Runtime Environments"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "JAVASP_PID: $JAVASP_PID"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"