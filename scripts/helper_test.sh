#!/bin/bash

CURRENT_DIR="$( cd "$( dirname "$0" )" && pwd -P )"
BIN_DIR="$CURRENT_DIR/../bin"
BUILD_DIR="$CURRENT_DIR/../build"
RESULT_DIR="$CURRENT_DIR/../results"  # Base result directory

# Global variables for results
TEST_COUNT=0
TEST_PASSED=0
TEST_FAILED=0
TEST_RESULTS=()

BRANCH_NAME="release_11_3"    # Branch name for organization

# Start the profiler for the given test
start_profiler() {
  local profiler_output=$(realpath "$1/profiler.prof")
  echo "Starting profiler, output: $profiler_output"
  mkdir -p "$(dirname "$profiler_output")"
  $BUILD_DIR/async-profiler/bin/asprof start -f "$profiler_output" $2
}

# Stop the profiler
stop_profiler() {
  local profiler_output=$(realpath "$1/profiler.prof")
  echo "Stopping profiler"
  $BUILD_DIR/async-profiler/bin/asprof stop -o tree -f "$profiler_output" $2
}

create_tmp_for_iteration() {
    local file_path=$1
    local sql_file_path=$2
    local iterations=$3

    # Initialize the file, remove if it already exists
    rm -f "$file_path"
    > "$file_path"

    # Read the content of the SQL file
    if [[ -f "$sql_file_path" ]]; then
        local sql_query=$(<"$sql_file_path")
    else
        echo "Invalid SQL file path: $sql_file_path"
        return 1
    fi

    # Write the content to the file repeatedly
    # echo ";autocommit off" >> "$file_path"
    for ((i = 1; i <= iterations; i++)); do
        echo "$sql_query" >> "$file_path"
    done
    # echo "ROLLBACK;" >> "$file_path"

    echo "File creation completed: $file_path"
}

# Measure execution time of a single command
measure_time() {
  local start_time=$(date +%s%N)
  "$@"  # Execute the provided command
  local exit_code=$?
  local end_time=$(date +%s%N)
  local duration=$(( (end_time - start_time) / 1000000 )) # Convert to ms
  echo "$duration" "$exit_code"
}

# Assertion function
assert_equals() {
  local expected="$1"
  local actual="$2"
  local message="${3:-}"

  if [ "$expected" == "$actual" ]; then
    return 0
  else
    echo "  Expected: $expected"
    echo "  Actual:   $actual"
    return 1
  fi
}

# Performance test runner
run_test() {
  local test_name="$1"
  local branch_name="$2"
  local execution_script="$3"
  local condition_script="$4"
  local iterations="${5:-1}"

  local test_name_branch="$branch_name-$test_name"
  # Create result directory for the test
  local test_result_dir="$RESULT_DIR/$branch_name/$test_name"
  mkdir -p "$test_result_dir"

  echo "test_result_dir: $test_result_dir"

  echo "Running test: $test_name_branch ($iterations iterations)" | tee -a "$test_result_dir/result.log"

  pid=$(get_pid_from_status "$test_name_branch")

  echo "PID: $pid"

  # Start profiler for the entire test
  start_profiler "$test_result_dir" "$pid"

  local total_time=0
  local iteration
  local success=true

  for ((iteration=1; iteration<=iterations; iteration++)); do
    # Measure time for a single iteration
    read duration exit_code <<<$(measure_time . "$execution_script")

    echo "  Iteration $iteration: ${duration}ms (Exit code: $exit_code)" | tee -a "$test_result_dir/result.log"
    total_time=$((total_time + duration))

    # Evaluate the condition script
    if ! bash "$condition_script" "$exit_code" "$duration"; then
      success=false
    fi
  done

  # Stop profiler after all iterations
  stop_profiler "$test_result_dir" "$pid"

  local average_time=$((total_time / iterations))
  if $success; then
    echo "[PASS] $test_name_branch (Average time: ${average_time}ms)" | tee -a "$test_result_dir/result.log"
    TEST_PASSED=$((TEST_PASSED + 1))
    TEST_RESULTS+=("$test_name_branch: PASS (${average_time}ms avg)")
  else
    echo "[FAIL] $test_name_branch (Average time: ${average_time}ms)" | tee -a "$test_result_dir/result.log"
    TEST_FAILED=$((TEST_FAILED + 1))
    TEST_RESULTS+=("$test_name_branch: FAIL (${average_time}ms avg)")
  fi

  TEST_COUNT=$((TEST_COUNT + 1))
}

# Test summary
print_summary() {
  echo ""
  echo "Test Summary:"
  echo "  Total Tests: $TEST_COUNT"
  echo "  Passed:      $TEST_PASSED"
  echo "  Failed:      $TEST_FAILED"

  echo ""
  echo "Detailed Results:"
  for result in "${TEST_RESULTS[@]}"; do
    echo "  $result"
  done

  # Save summary to the result directory
  local summary_file="$1/summary.log"
  mkdir -p "$(dirname "$summary_file")"
  {
    echo "Test Summary:"
    echo "  Total Tests: $TEST_COUNT"
    echo "  Passed:      $TEST_PASSED"
    echo "  Failed:      $TEST_FAILED"
    echo ""
    echo "Detailed Results:"
    for result in "${TEST_RESULTS[@]}"; do
      echo "  $result"
    done
  } > "$summary_file"

  if [ "$TEST_FAILED" -eq 0 ]; then
    echo "All tests passed!"
    return 0
  else
    echo "Some tests failed."
    return 1
  fi
}

visualize_prof() {
  local prof_file="$1"
  local output_dir="${2:-$(dirname "$prof_file")}"  # Default to the same directory as .prof file
  local flamegraph_html="$output_dir/flamegraph.html"

  # Check if the .prof file exists
  if [[ ! -f "$prof_file" ]]; then
    echo "Error: Profile file '$prof_file' does not exist."
    return 1
  fi

  # Generate the Flame Graph
  echo "Generating Flame Graph for '$prof_file'..."
  ./async-profiler/profiler.sh convert "$prof_file" -o flamegraph -f "$flamegraph_html"

  if [[ -f "$flamegraph_html" ]]; then
    echo "Flame Graph generated: $flamegraph_html"
  else
    echo "Error: Failed to generate Flame Graph."
    return 1
  fi
}

# Test suite
run_tests() {
  # Test: Run Java application
  run_test "JavaTest" "./executions/java_command.sh" "./conditions/success_condition.sh" 3

  # Test: Simulate another operation
  run_test "SimpleTest" "./executions/simple_command.sh" "./conditions/exit_code_condition.sh" 2
}
