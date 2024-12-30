CURRENT_DIR="$( cd "$( dirname "$0" )" && pwd -P )"

LOAD_DIR="$CURRENT_DIR/../load"

get_pid_from_status() {
  local dir_name="$1"  # Directory name as input argument
  local command_output
  local pid

  # Validate input argument
  if [[ -z "$dir_name" ]]; then
    echo "Error: Directory name is required."
    return 1
  fi

  # Check if the path contains 'release_11_3'
  if [[ "$dir_name" == *"release_11_3"* ]]; then
    command_output=$(cubrid javasp status testdb 2>/dev/null)
  else
    command_output=$(cubrid pl status testdb 2>/dev/null)
  fi

  # Extract the PID using grep and sed
  pid=$(echo "$command_output" | grep -oP 'pid \K[0-9]+')

  # Return the PID or an error message
  if [[ -n "$pid" ]]; then
    echo "$pid"
  else
    echo "Error: PID not found in the status output."
    return 1
  fi
}

is_db_created () {
        if [[ -d $CUBRID_DATABASES/testdb ]]; then
                return 0
        else
                return 1
        fi
}

create_and_loaddb() {
        echo "Creating and loading testdb"
        echo "CUBRID_DATABASES: $CUBRID_DATABASES"

        cubrid server stop testdb > /dev/null 2>&1
        
        sleep 1
        
        cubrid deletedb testdb

        mkdir -p $CUBRID_DATABASES/testdb
        cubrid createdb --db-volume-size=100M --log-volume-size=100M --file-path=$CUBRID_DATABASES/testdb testdb ko_KR.utf8
        cubrid loaddb -S -u dba -s $LOAD_DIR/testdb_schema -d $LOAD_DIR/testdb_objects testdb
        javac $LOAD_DIR/SpPrepareTest.java
        loadjava testdb $LOAD_DIR/SpPrepareTest.class -y
}

test_server () {
        cubrid server start testdb
        cubrid server status
        cubrid server stop testdb
        cubrid deletedb testdb
}

register_func () {
        local branch_name="$1"  # Directory name as input argument

        # Check if the path contains 'release_11_3'
        # if [[ "$branch_name" == *"release_11_3"* ]]; then
                csql -u dba testdb -i $LOAD_DIR/load.sql
        # else
        #        csql -u dba testdb -i $LOAD_DIR/load.sql
        #        csql -u dba testdb -c "CREATE OR REPLACE FUNCTION fn_string(s string) RETURN STRING AS BEGIN RETURN s; END;"
        #fi

}

# Example usage
:<<END
dir_path="/path/to/release_11_3/install.out"
pid=$(get_pid_from_status "$dir_path")
if [[ $? -eq 0 ]]; then
  echo "The PID for $dir_path is: $pid"
else
  echo "Failed to get PID for $dir_path"
fi
END