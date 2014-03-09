#!/bin/bash

#/**
#* <pre>
#* Feature: List current local topics.
#*
#* Scenario: 'con topics list' from any branch
#* Given 'conveyor-workflow' is installed
#* And a pre-populated test repository
#* And I am on the 'master' branch'
#* When I type 'con list'
#* Then lines 'add-bar' and 'add-foo' are printed to stdout
#* And the script exits with exit code 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
init_test_environment `basename $0`
cd $WORKING_REPO_PATH

populate_test_environment

git checkout -q master

test_output 'con topics' "  add-bar
  add-foo" '' 0
test_output 'con topics list' "  add-bar
  add-foo" '' 0
