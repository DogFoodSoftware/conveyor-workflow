#!/bin/bash

#/**
#* <pre>
#* Feature: Report bad releases branch names.
#*
#* Scenario: 'con releases start "foo bar"'
#* Given 'conveyor-workflow' is installed
#* When I type 'con releases start "foo bar"'
#* Then no text is printed to stdout
#* And text is printed to stderr starting with "Branch name 'foo bar' cannot contain spaces."
#* And the script exits with exit code 1.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
init_test_environment `basename $0`
cd $WORKING_REPO_PATH

test_output "con releases start 'foo bar'" '' "Resource names cannot contain spaces; got 'foo bar'." 1
