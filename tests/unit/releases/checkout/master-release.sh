#!/bin/bash

#/**
#* <pre>
#* Feature: Checkout
#*
#* Scenario: 'con releases checkout master' from topic branch
#* Given 'conveyor-workflow' is installed
#*   And I am on topic '1-foo'
#* When I type 'con releases checkout master'
#* Then text "Switched to release 'master'." is printed to stdout
#*   And I am now on branch 'master'
#*   And the script exits with exit code 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
source $TEST_BASE/lib/cli-lib.sh
check_path
source $TEST_BASE/lib/environment-lib.sh
init_test_environment `basename $0`
cd $WORKING_REPO_PATH

git checkout -q master
con topics start --checkout 1-foo >/dev/null
test_output 'con releases checkout master' "Switched to release 'master'." '' 0
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
if [ x"$CURRENT_BRANCH" != x'master' ]; then
    echo "ERROR: Expected to be on branch 'master' after checking out release, but instead on '$CURRENT_BRANCH'."
fi
