#!/bin/bash

CURRENT_DIR="$( cd "$( dirname "$0" )" && pwd -P )"

echo "[INFO] Shell Directory [$CURRENT_DIR]"

BIN_DIR=$CURRENT_DIR/../bin
BUILD_DIR=$CURRENT_DIR/../build
DOWNLOAD_DIR=$CURRENT_DIR/../download
LOAD_DIR=$CURRENT_DIR/../load
OUTPUT_DIR=$CURRENT_DIR/../output

mkdir -p $BIN_DIR
mkdir -p $BUILD_DIR
mkdir -p $DOWNLOAD_DIR
mkdir -p $LOAD_DIR
mkdir -p $OUTPUT_DIR

function clean () {
    rm -rf $BUILD_DIR/*
    rm -rf $BIN_DIR/*
}

CMAKE2_VERSION=2.8.12.2
CMAKE3_VERSION=3.26.3

function install_environments () {
    # For configure
    ## git (user)

    # For build and runtime

    ## Open JDK 8
    mkdir -p $BIN_DIR/java_8/
    wget https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk8u342-b07/OpenJDK8U-jdk_x64_linux_8u342b07.tar.gz -O $DOWNLOAD_DIR/jdk8.tar.gz
    tar -zxvf $DOWNLOAD_DIR/jdk8.tar.gz --directory $BIN_DIR/java_8/ --strip-components=1

    ## Open JDK 11
    mkdir -p $BIN_DIR/java_11/
    wget https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.9.1%2B1/OpenJDK11U-jdk_x64_linux_hotspot_11.0.9.1_1.tar.gz -O $DOWNLOAD_DIR/jdk11.tar.gz
    tar -zxvf $DOWNLOAD_DIR/jdk11.tar.gz --directory $BIN_DIR/java_11/ --strip-components=1

    ## CMake (2.8, 3.12)
    wget https://github.com/Kitware/CMake/releases/download/v$CMAKE2_VERSION/cmake-$CMAKE2_VERSION-Linux-i386.tar.gz -O $DOWNLOAD_DIR/cmake-$CMAKE2_VERSION.tar.gz
    mkdir -p $BIN_DIR/cmake2/
    tar -zxvf $DOWNLOAD_DIR/cmake-$CMAKE2_VERSION.tar.gz --directory $BIN_DIR/cmake2/ --strip-components=1

    wget https://github.com/Kitware/CMake/releases/download/v$CMAKE3_VERSION/cmake-$CMAKE3_VERSION-linux-x86_64.tar.gz -O $DOWNLOAD_DIR/cmake-$CMAKE3_VERSION.tar.gz
    mkdir -p $BIN_DIR/cmake3/
    tar -zxvf $DOWNLOAD_DIR/cmake-$CMAKE3_VERSION.tar.gz --directory $BIN_DIR/cmake3/ --strip-components=1

    ## Bison
    # wget https://ftp.gnu.org/gnu/bison/bison-3.0.5.tar.gz -O $DOWNLOAD_DIR/bison.tar.gz
    # mkdir -p $BUILD_DIR/bison/
    # tar -zxvf $DOWNLOAD_DIR/bison.tar.gz --directory $BUILD_DIR/bison/ --strip-components=1
    # cd $BUILD_DIR/bison/
    # ./configure --prefix=$BIN_DIR/bison && make all install
    # cd -

}

function install_testtools() {
    # async-profiler for Java
    wget https://github.com/async-profiler/async-profiler/releases/download/v3.0/async-profiler-3.0-linux-x64.tar.gz -O $DOWNLOAD_DIR/async-profiler.tar.gz
    mkdir -p $BIN_DIR/async-profiler/
    tar -zxvf $DOWNLOAD_DIR/async-profiler.tar.gz --directory $BIN_DIR/async-profiler/ --strip-components=1

    # jmeter
    wget https://github.com/apache/jmeter/archive/refs/tags/rel/v5.4.1.tar.gz -O $DOWNLOAD_DIR/jmeter.tar.gz
    mkdir -p $BIN_DIR/jmeter/
    tar -zxvf $DOWNLOAD_DIR/jmeter.tar.gz --directory $BIN_DIR/jmeter/ --strip-components=1

    # gprofn
    wget http://ftp.gnu.org/gnu/binutils/binutils-2.43.tar.gz -O $DOWNLOAD_DIR/binutils.tar.gz
    mkdir -p $BUILD_DIR/binutils/build
    mkdir -p $BIN_DIR/binutils
    tar -zxvf $DOWNLOAD_DIR/binutils.tar.gz --directory $BUILD_DIR/binutils/ --strip-components=1
    cd $BUILD_DIR/binutils/build
    ../configure --prefix=$BIN_DIR/binutils --enable-gprofng
    make -j$(nproc) && make install

    # install CUBRID JDBC
    cp $CUBRID/jdbc/JDBC-*.jar $BUILD_DIR/jmeter/lib

    # link
    # ln -sf $BUILD_DIR/async-profiler/profiler.sh $BIN_DIR/profiler.sh
    # ln -sf $BUILD_DIR/jmeter/bin/jmeter.sh $BIN_DIR/jmeter.sh
    # ln -sf $BIN_DIR/binutils/bin/gprofng $BIN_DIR/gprofng
}

function initialize_testfunction()
{
    # Java SP
    "$JAVA_HOME/bin/javac" -cp $CUBRID/jdbc/cubrid_jdbc.jar $LOAD_DIR/*.java
    for clz in $(ls $LOAD_DIR/*.class); do
        echo "Load ${clz}..."
        loadjava demodb $clz -y
    done

    # Method
    echo 'build'
    cubrid_esql -u $LOAD_DIR/test_method.ec -o $OUTPUT_DIR/method.c

    echo 'compile'
    gcc -c $OUTPUT_DIR/method.c -I$CUBRID/include -fPIC -o $OUTPUT_DIR/method.o

    echo 'link'
    gcc $OUTPUT_DIR/method.o -o $OUTPUT_DIR/method.so -shared -L$CUBRID/lib -lcubridesql -lm

    echo 'deploy'
    mkdir -p $CUBRID/method
    cp $OUTPUT_DIR/method.so $CUBRID/method
}

if [ "$CUBRID" == "" ] 
then
    echo "CUBRID is not set"
fi;

if [ -e "$BIN_DIR/.installed" ]
then
    echo "Test environment is already configured"
else
    clean

    install_environments || exit 1

    install_testtools || exit 1

    touch $BIN_DIR/.installed
fi;

# if [ -e "$CUBRID/method/method.so" ]
# then
#     echo "Method Configuration is set"
# else
#     initialize_testfunction;
# fi;
