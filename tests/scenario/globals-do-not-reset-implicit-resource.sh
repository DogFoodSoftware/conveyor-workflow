#!/bin/bash

#/**
#* <pre>
#* Feature: Scenario
#*
#* Scenario: User invokes global action without resetting implicit repo
#*
#* Given 'conveyor-workflow' is installed
#*   And a there is a local origin repo
#* When user executes 'con -s topics; con status; con start --checkout 1-test-topic'
#* Then topic branch 'topics-1-test-topic' is created
#*   And the script exits with status 0
#* </pre>
#*/

TEST_BASE=`dirname $0`/..
source $TEST_BASE/lib/cli-lib.sh
check_path
source $TEST_BASE/lib/environment-lib.sh
init_test_environment `basename $0`
cd "$WORKING_REPO_PATH"

con -s topics >/dev/null
con status > /dev/null
test_output 'con start --checkout 1-test-topic' "Created topic '1-test-topic'" '' 0
con -s > /dev/null
