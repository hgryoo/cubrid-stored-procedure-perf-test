#!/bin/bash

CURRENT_DIR="$( cd "$( dirname "$0" )" && pwd -P )"

echo "[INFO] Shell Directory [$CURRENT_DIR]"

BIN_DIR=$CURRENT_DIR/../bin
BUILD_DIR=$CURRENT_DIR/../build
DOWNLOAD_DIR=$CURRENT_DIR/../download
LOAD_DIR=$CURRENT_DIR/../build

mkdir -p $BIN_DIR
mkdir -p $BUILD_DIR
mkdir -p $DOWNLOAD_DIR

function initialize_testtools()
{
    # async-profiler for Java
    wget https://github.com/jvm-profiling-tools/async-profiler/releases/download/v2.0/async-profiler-2.0-linux-x86.tar.gz -O $DOWNLOAD_DIR/async-profiler.tar.gz

    mkdir -p $BUILD_DIR/async-profiler/
    tar -zxvf $DOWNLOAD_DIR/async-profiler.tar.gz --directory $BUILD_DIR/async-profiler/ --strip-components=1
    ln -sf $BUILD_DIR/async-profiler/profiler.sh  $BIN_DIR/profiler.sh
}

function initialize_testfunction()
{
    "$JAVA_HOME/bin/javac" -cp $CUBRID/jdbc/cubrid_jdbc.jar *.java
    for clz in $(ls *.class); do
        echo "Load ${clz}..."
        loadjava $DBNAME $clz
    done

    init_method.sh
}

function load()
{

}

initialize_testtools