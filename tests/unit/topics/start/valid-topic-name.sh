#!/bin/bash

#/**
#* <pre>
#* Feature: Create a valid topic.
#*
#* Scenario: 'git convey topics start task-foo' from master
#* Given 'git-convey' is installed
#*   And I am on the 'master' branch'
#* When I type 'git convey topics start task-foo'
#* Then text "Switched to branch 'task-foo'" is printed to stdout
#*   And branch 'task-foo' is not created in the local repository
#*   And branch 'task-foo' is created in the origin repository
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

test_start 'git convey topics start task-foo' 'topics' 'task-foo' "Created topic 'task-foo' on origin." '' 1 0
