#!/bin/bash

#/**
#* <pre>
#* Feature: Checkout
#*
#* Scenario: 'con topics checkout master' from topic branch
#* Given 'conveyor-workflow' is installed
#*   And I am on topic '1-foo'
#* When I type 'con topics checkout master'
#* Then text "No such release 'master'." is printed to stderr
#*   And I am still on topic '1-foo'
#*   And the script exits with exit code 1.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
init_test_environment `basename $0`
cd $WORKING_REPO_PATH

git checkout -q master
con topics start --checkout 1-foo >/dev/null
test_output 'con topics checkout master' "" "No such topic 'master' exists on origin." 1
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
if [ x"$CURRENT_BRANCH" != x'topics-1-foo' ]; then
    echo "ERROR: Expected to be on branch 'topics-1-foo' after checking out release, but instead on '$CURRENT_BRANCH'."
fi
