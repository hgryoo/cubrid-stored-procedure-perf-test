#!/bin/bash

# Usage: ./init_db.sh debug, "develop, release/11.3, ..."

# Validate input arguments
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <mode: debug|release> [<branch1>,<branch2>,...,<branchN>]"
  exit 1
fi

MODE="$1" # The mode, e.g., debug
BRANCH_LIST="$2" # Branches enclosed in []

# Validate the mode argument
if [[ "$MODE" != "debug" && "$MODE" != "release" ]]; then
  echo "Invalid mode: $MODE. Mode must be 'debug' or 'release'."
  exit 1
fi

# Remove the enclosing square brackets
BRANCH_LIST=$(echo "$BRANCH_LIST" | sed 's/^\[//; s/\]$//')

# Split the branch list into an array
IFS=',' read -r -a BRANCHES <<< "$BRANCH_LIST"

CURRENT_DIR="$( cd "$( dirname "$0" )" && pwd -P )"
CUBRID_REPO_URL="http://github.com/cubrid/cubrid"

BIN_DIR=$CURRENT_DIR/../bin
WORKSPACE_DIR=$CURRENT_DIR/../workspace

WORKTREE_BASE=$WORKSPACE_DIR/worktrees
CUBRID_REPO_PATH=$WORKSPACE_DIR/cubrid

init_cubrid () {
        rm -rf $WORKSPACE_DIR/*

        mkdir -p $WORKSPACE_DIR

        # Add worktree with branches
        cd "$WORKSPACE_DIR" || { echo "Repository path not found!"; exit 1; }

        # Clone repos with branch names
        for BRANCH in "${BRANCHES[@]}"; do
                # Trim spaces (if any)
                BRANCH=$(echo "$BRANCH" | xargs)

                if [ "$BRANCH" == "develop" ]; then
                        # For the 'develop' branch, force the folder name to 'dev'
                        SAFE_BRANCH_NAME="dev"
                else
                        # Replace '/' with '_' in branch names to create a safe folder name
                        SAFE_BRANCH_NAME=$(echo "$BRANCH" | sed 's|[/.]|_|g')
                fi

                git clone $CUBRID_REPO_URL --branch $BRANCH --single-branch $WORKSPACE_DIR/$SAFE_BRANCH_NAME || { echo "Failed to clone branch $BRANCH"; exit 1; }
        done
}

init_cubrid_worktree () {
        rm -rf $WORKSPACE_DIR/*

        mkdir -p $WORKSPACE_DIR

        # Clone cubrid
        if [ ! -d "$CUBRID_REPO_PATH" ]; then
                git clone $CUBRID_REPO_URL $CUBRID_REPO_PATH
        fi

        # Clear worktrees
        rm -rf $WORKTREE_BASE

        # Add worktree with branches
        cd "$CUBRID_REPO_PATH" || { echo "Repository path not found!"; exit 1; }

        git fetch origin

        for BRANCH in "${BRANCHES[@]}"; do
                # Trim spaces (if any)
                BRANCH=$(echo "$BRANCH" | xargs)

                if [ "$BRANCH" == "develop" ]; then
                        # For the 'develop' branch, force the folder name to 'dev'
                        SAFE_BRANCH_NAME="dev"
                else
                        # Replace '/' with '_' in branch names to create a safe folder name
                        SAFE_BRANCH_NAME=$(echo "$BRANCH" | sed 's|[/.]|_|g')
                fi

                WORKTREE_PATH="$WORKTREE_BASE/$SAFE_BRANCH_NAME"

                # Add the worktree if it doesn't already exist
                if [ ! -d "$WORKTREE_PATH" ]; then
                        echo "Adding worktree for branch $BRANCH at $WORKTREE_PATH"
                        git checkout -b "$SAFE_BRANCH_NAME" "origin/$BRANCH" || { echo "Failed to checkout branch $BRANCH"; exit 1; }
                        git worktree add "$WORKTREE_PATH" "$BRANCH" || { echo "Failed to add worktree for branch $BRANCH"; exit 1; }
                else
                        echo "Worktree for branch $BRANCH already exists at $WORKTREE_PATH"
                fi
        done
}

build_cubrid () {
        cd $WORKSPACE_DIR || { echo "Worktree base path not found!"; exit 1; }

        if [ "$MODE" == "debug" ]; then
                # Add debug-specific setup here
                echo "Setting up debug environment for $WORKTREE_PATH"
        elif [ "$MODE" == "release" ]; then
                # Add release-specific setup here
                echo "Setting up release environment for $WORKTREE_PATH"
        fi

        # Add '-j' into MAKEFLAGS environment variable to specify the number of compile jobs to run simultaneously
        if [ -n "$MAKEFLAGS" -a -z "${MAKEFLAGS##*-j*}" ]; then
                # Append '-l<num of cpu>' option into MAKEFLAGS if the '-j' option exists
                NPROC=$(grep -c '^processor' /proc/cpuinfo)
                export MAKEFLAGS="$MAKEFLAGS -l$NPROC"
        fi

        # Build cubrid for each worktree branch (iterate directory)
        for d in */ ; do
                cd "$d" || { echo "Path not found!"; exit 1; }

                echo "Building cubrid for branch $d"

                git submodule update --init || { echo "Failed to update submodules for branch $d"; exit 1; }

                rm -rf ./cubridmanager

                # if $d is release_11_3, then set -DCMAKE_COMMAND to the bin/cmake2/bin/cmake
                if [ "$d" == "release_11_3" ]; then
                        CMAKE_COMMAND=$BIN_DIR/cmake2/bin/cmake
                else
                        CMAKE_COMMAND=$BIN_DIR/cmake3/bin/cmake
                fi
                
                # Build cubrid (CMake)
                mkdir -p build.out install.out
                cmake -H. -Bbuild.out -DCMAKE_BUILD_TYPE=$MODE -DCMAKE_INSTALL_PREFIX=install.out -DCMAKE_COMMAND=$CMAKE_COMMAND || { echo "Failed to configure cubrid for branch $d"; exit 1; }

                cmake --build build.out --target install -- -j || { echo "Failed to build cubrid for branch $d"; exit 1; }

                # ./build.sh build -m $MODE -b build.out -p install.out -g ninja || { echo "Failed to build cubrid for branch $d"; exit 1; }

                cd -
        done
}

if [ -e "$WORKSPACE_DIR/.installed" ]
then
    echo "Test Databases are already installed."
else
    init_cubrid

    build_cubrid
    
    touch $WORKSPACE_DIR/.installed
fi
