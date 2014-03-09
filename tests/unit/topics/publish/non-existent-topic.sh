#!/bin/bash

#/**
#* <pre>
#* Feature: Report bad topics names on publish.
#*
#* Scenario: 'con topics publish bad-topic'
#* Given 'conveyor-workflow' is installed
#*   And their is no topic 'bad-topic'
#* When I type 'con topics publish bad-topic'
#* Then no text is printed to stdout
#*   And text is printed to stderr starting with "No such topic 'bad-topic' exists on origin."
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

test_output "con topics publish bad-topic" '' "Could not find topic 'bad-topic' on origin." 1
