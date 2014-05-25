#!/bin/bash

#/**
#* <pre>
#* Feature: Set Resource
#*
#* Scenario: Unset resource with long option.
#* Given 'conveyor-workflow' is installed
#*   And the implied resource has been set to topics
#* When I type 'con -s'
#*   And I type 'con start --checkout foo-bar'
#* Then I see error "Unknown resource 'start'.".
#* </pre>
#*/
TEST_BASE=`dirname $0`/../..
source $TEST_BASE/lib/cli-lib.sh
check_path
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
init_test_environment `basename $0`
cd $WORKING_REPO_PATH

con --setresource topics >/dev/null
con -s >/dev/null
test_start 'con topics start --checkout task-foo' 'topics' 'task-foo' "Created topic 'task-foo' on origin." '' 0 0
if ! git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    echo "ERROR: Did not find expected local branch for topic '$BRANCH_NAME' in $WORKING_REPO_PATH."
fi
con -s > /dev/null
