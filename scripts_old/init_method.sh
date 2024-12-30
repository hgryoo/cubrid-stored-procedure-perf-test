#!/bin/bash
echo 'build'
cubrid_esql -u $LOAD_DIR/test_method.ec -o $OUTPUT_DIR/method.c

echo 'compile'
gcc -c $OUTPUT_DIR/method.c -I$CUBRID/include -fPIC

echo 'link'
gcc -o $OUTPUT_DIR/method.so $OUTPUT_DIR/method.o -shared -L$CUBRID/lib -lcubridesql -lm

echo 'deploy'
cp $OUTPUT_DIR/method.so $DBMETHOD_DIR