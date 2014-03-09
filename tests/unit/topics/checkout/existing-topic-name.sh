#!/bin/bash

#/**
#* <pre>
#* Feature: Checkout an existing topic.
#*
#* Scenario: 'con topics checkout existing-topic' from master
#* Given 'conveyor-workflow' is installed
#*   And I am on the 'master' branch
#*   And there exists a topic 'existing-topic'
#* When I type 'con topics checkout existing-topic'
#* Then text "Switched to topic 'existing-topic'." is printed to stdout
#*   And I am on branch 'topics-existing-topic'
#*   And the script exits with exit code 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
init_test_environment `basename $0`
cd $WORKING_REPO_PATH

git checkout -q master
con topics start existing-topic >/dev/null
if ! git checkout -q master; then
    echo "ERROR: Could not reset to master; test inconclusive."
fi
test_output 'con topics checkout existing-topic' "Switched to topic 'existing-topic'." '' 0
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
if [ x"$CURRENT_BRANCH" != x'topics-existing-topic' ]; then
    echo "ERROR: Expected to be on branch 'topics-existing-topic' after checking out topic, but instead on '$CURRENT_BRANCH'."
fi
