#!/bin/bash

#/**
#* <pre>
#* Feature: Set Resource
#*
#* Scenario: Set resource with long option.
#* Given 'git-convey' is installed
#* When I type 'con -s topics'
#*   And I type 'con start --checkout foo-bar'
#* Then the topic is correctly started.
#* </pre>
#*/
TEST_BASE=`dirname $0`/../..
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
init_test_environment $TEST_BASE/.. `basename $0`
cd $WORKING_REPO_PATH

con -s topics >/dev/null
test_start 'con start --checkout task-foo' 'topics' 'task-foo' "Created topic 'task-foo' on origin." '' 0 0
if ! git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    echo "ERROR: Did not find expected local branch for topic '$BRANCH_NAME' in $WORKING_REPO_PATH."
fi
