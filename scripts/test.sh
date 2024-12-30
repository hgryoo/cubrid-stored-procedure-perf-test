#!/bin/bash

CURRENT_DIR="$(cd "$(dirname "$0")" && pwd -P)"

BUILD_DIR="$CURRENT_DIR/../build"
WORKSPACE_DIR="$CURRENT_DIR/../workspace"
TEMPLATE_DIR="$CURRENT_DIR/../templates"
TMP_DIR="$CURRENT_DIR/../tmp"
CASES_DIR="$CURRENT_DIR/../cases"
CONDITIONS_DIR="$CURRENT_DIR/../conditions"
RESULTS_DIR="$CURRENT_DIR/../results"

source $CURRENT_DIR/helper_cubrid.sh
source $CURRENT_DIR/helper_test.sh

echo "====================== Test ======================"

CUBRID_PORT_ID=2000


extract_last_dir() {
        local input_path="$1"
        echo "${input_path%/}" | awk -F '/' '{print $NF}'
}

clear_before_testing () {
        pkill cub_server
        pkill cub_master
        
        rm -rf $RESULTS_DIR/*
}

test_sa() {
        return 0;
}

test_cs() {
        for branches_dir in $WORKSPACE_DIR/*; do
                branch_name=$(extract_last_dir "$branches_dir")

                echo "Starting to test in workspace directory: $branches_dir"

                if [ ! -d "$branches_dir" ]; then
                        echo "No branches found in workspace directory: $branches_dir"
                        continue
                fi

                cd $branches_dir

                # set env
                source $TEMPLATE_DIR/.envrc_template
                PATH=$BUILD_DIR/async-profiler/bin:$PATH

                echo "Dummy Test"

                # create db
                create_and_loaddb

                # if branch_dir is release_11_3, add java_stored_procedure=yes to the $CUBRID/conf/cubrid.conf
                if [[ $branch_name == "release_11_3" ]]; then
                        echo "java_stored_procedure=yes" >>$CUBRID/conf/cubrid.conf
                fi

                # In $CUBRID/conf/cubrid.conf, change the cubrid_port_id to $CUBRID_PORT_ID, and increment $CUBRID_PORT_ID
                # cubrid_port_id=$CUBRID_PORT_ID
                # CUBRID_PORT_ID=$((CUBRID_PORT_ID+1))
                sed -i "s/^cubrid_port_id=.*/cubrid_port_id=$CUBRID_PORT_ID/" $CUBRID/conf/cubrid.conf
                CUBRID_PORT_ID=$((CUBRID_PORT_ID + 1))

                cubrid server start testdb
                # if branch_dir is release_11_3, start javasp manually
                if [[ $branch_name == "release_11_3" ]]; then
                        cubrid javasp start testdb
                fi

                register_func $branch_name

                create_tmp_for_iteration $TMP_DIR/constant_func.sql $CASES_DIR/constant_func.sql 50
                run_test "constant_func" "$branch_name" "$CONDITIONS_DIR/test_constant_func.sh" "$CONDITIONS_DIR/always_true.sh" 1

                create_tmp_for_iteration $TMP_DIR/simple_query.sql $CASES_DIR/simple_query.sql 5
                run_test "simple_query" "$branch_name" "$CONDITIONS_DIR/test_simple_query.sh" "$CONDITIONS_DIR/always_true.sh" 1

                #create_tmp_for_iteration $TMP_DIR/constant.sql $CASES_DIR/constant.sql 1000
                #run_test "constant" "$branch_name" "$CONDITIONS_DIR/test_constant.sh" "$CONDITIONS_DIR/always_true.sh" 1

                cubrid server stop testdb
                # if branch_dir is release_11_3, stop javasp manually
                if [[ $branch_name == "release_11_3" ]]; then
                        cubrid javasp stop testdb
                fi

                cd $WORKSPACE_DIR
        done
        
        print_summary "$RESULTS_DIR"
}

clear_before_testing

test_cs