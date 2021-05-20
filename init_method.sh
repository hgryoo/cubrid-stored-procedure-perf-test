#!/bin/bash

if [ -z "$CUBRID" ]; then
  echo "Can not find CUBRID"
  exit 1
fi

current_dir="$( cd "$( dirname "$0" )" && pwd -P )"
function_dir="$current_dir/function"
out_dir="$current_dir/output"

echo 'init'
mkdir $CUBRID/method
mkdir $current_dir/output

echo 'build'
cubrid_esql -u $function_dir/test_method.ec -o $out_dir/method.c

echo 'compile'
gcc -c $out_dir/method.c -I$CUBRID/include -fPIC

echo 'link'
gcc -o $out_dir/method.so $out_dir/method.o -shared -L$CUBRID/lib -lcubridesql -lm

echo 'deploy'
cp $out_dir/method.so $CUBRID/method

db_name=demodb
curDir=`pwd`
csql -u dba $db_name -i $function_dir/init_met.sql 1>/dev/null

