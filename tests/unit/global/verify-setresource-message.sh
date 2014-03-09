#!/bin/bash

#/**
#* <pre>
#* Feature: Set Resource
#*
#* Scenario: Set resource with long option.
#* Given 'conveyor-workflow' is installed
#* When I type 'con --setresource topics'
#* Then text is printed to stdout starting with 'Resource set as 'topics'.'
#*   And the script exits with value 0.
#* </pre>
#*
#* Repeat for 'releases' and 'issues', and then repeat again with short form.
#*/
TEST_BASE=`dirname $0`/../..
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
init_test_environment $TEST_BASE/.. `basename $0`
cd $WORKING_REPO_PATH

test_output 'con --setresource topics' "Resource set as 'topics'." '' 0
test_output 'con --setresource releases' "Resource set as 'releases'." '' 0
test_output 'con --setresource issues' "Resource set as 'issues'." '' 0
test_output 'con -s topics' "Resource set as 'topics'." '' 0
test_output 'con -s releases' "Resource set as 'releases'." '' 0
test_output 'con -s issues' "Resource set as 'issues'." '' 0
