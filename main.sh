#!/bin/bash
#
# A lot of this is based on options.bash by Daniel Mills.
# @see https://github.com/e36freak/tools/blob/master/options.bash

# Preamble {{{

# Exit immediately on error
set -e

# Detect whether output is piped or not.
[[ -t 1 ]] && piped=0 || piped=1

init () {
        # init environments
        scripts/init_env.sh

        # init db (>= release 11.3)
        scripts/init_db.sh release [develop,release/11.3,cubpl/perf]
}

test () {
        # test
        scripts/test.sh
}

init || { echo "Initializing failed"; exit 1; }

test || { echo "Testing failed"; exit 1; }