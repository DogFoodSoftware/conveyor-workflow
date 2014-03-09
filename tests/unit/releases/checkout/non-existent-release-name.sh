#!/bin/bash

#/**
#* <pre>
#* Feature: Report bad release names on join.
#*
#* Scenario: 'con releases join bad-release'
#* Given 'conveyor-workflow' is installed
#*   And their is no release 'foo-bar'
#* When I type 'con releases checkout bad-release'
#* Then no text is printed to stdout
#*   And text is printed to stderr starting with "No such release 'bad-release'."
#*   And the script exits with exit code 1. 
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
init_test_environment `basename $0`
cd $WORKING_REPO_PATH

test_output "con releases checkout bad-release" '' "No such release 'bad-release' exists on origin." 1
