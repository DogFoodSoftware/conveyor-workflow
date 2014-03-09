#!/bin/bash

#/**
#* <pre>
#* Feature: Report lack of local topic on publish.
#*
#* Scenario: 'con topics publish no-local-topic'
#* Given 'conveyor-workflow' is installed
#*   And their is a topic 'no-local-topic' on origin
#*   And topic 'no-local-topic' does not exist locally
#* When I type 'con topics publish no-local-topic'
#* Then no text is printed to stdout
#*   And text is printed to stderr starting with "No such topic 'no-local-topic' exists locally."
#*   And the script exits with exit code 1. 
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
init_test_environment $TEST_BASE/.. `basename $0`
cd $WORKING_REPO_PATH

con topics start no-local-topic > /dev/null
test_output "con topics publish no-local-topic" '' "No such topic 'no-local-topic' exists locally." 1
