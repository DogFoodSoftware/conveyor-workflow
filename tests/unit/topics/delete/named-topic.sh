#!/bin/bash

#/**
#* <pre>
#* Feature: Delete existing (local) topic.
#*
#* Scenario: 'con topics delete existing-topic' from master
#* Given 'git-convey' is installed
#*   And I am on the 'master' branch
#*   And there exists a topic 'existing-topic'
#* When I type 'con topics delete existing-topic'
#* Then text "Deleted local topic 'existing-topic'." is printed to stdout
#*   And I am on branch 'master'
#*   And the script exits with exit code 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
init_test_environment $TEST_BASE/.. `basename $0`
cd $WORKING_REPO_PATH

git checkout -q master
if ! con topics start --checkout existing-topic >/dev/null; then
    echo "ERROR: could not start topic 'existing-topic'; test inconclusive."
    exit
fi
if ! git checkout -q master; then
    echo "ERROR: Could not reset to master; test inconclusive."
fi
test_output 'con topics delete existing-topic' "Deleted local topic 'existing-topic'." '' 0
if git rev-parse --verify -q topics-existing-topic; then
    echo "ERROR: git seems to think that the deleted topic 'existing-topic' still exists."
fi
