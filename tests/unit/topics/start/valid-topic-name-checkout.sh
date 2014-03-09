#!/bin/bash

#/**
#* <pre>
#* Feature: Create a valid topic and checks it out.
#*
#* Scenario: 'con topics start --checkout task-foo' from master
#* Given 'conveyor-workflow' is installed
#*   And I am on the 'master' branch'
#* When I type 'con topics start task-foo'
#* Then text "Switched to branch 'task-foo'" is printed to stdout
#*   And branch 'task-foo' is created in the local repository
#*   And branch 'task-foo' is created in the origin repository
#*   And the current local branch is 'task-foo'
#*   And the script exits with exit code 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
init_test_environment $TEST_BASE/.. `basename $0`
cd $WORKING_REPO_PATH

test_start 'con topics start --checkout task-foo' 'topics' 'task-foo' "Created topic 'task-foo' on origin." '' 0 0
if ! git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    echo "ERROR: Did not find expected local branch for topic '$BRANCH_NAME' in $WORKING_REPO_PATH."
fi
