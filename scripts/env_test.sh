#!/bin/bash

CURRENT_DIR="$( cd "$( dirname "$0" )" && pwd -P )"

BIN_DIR=$(readlink -f $CURRENT_DIR/../bin)
BUILD_DIR=$(readlink -f $CURRENT_DIR/../build)
DOWNLOAD_DIR=$(readlink -f $CURRENT_DIR/../downlaod)
LOAD_DIR=$(readlink -f $CURRENT_DIR/../load)

mkdir -p $BIN_DIR
mkdir -p $BUILD_DIR
mkdir -p $DOWNLOAD_DIR

echo "Test Environments"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "BIN_DIR: $BIN_DIR"
echo "BUILD_DIR: $BUILD_DIR"
echo "DOWNLOAD_DIR: $DOWNLOAD_DIR"
echo "LOAD_DIR: $LOAD_DIR"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"