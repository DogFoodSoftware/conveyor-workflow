#!/bin/bash

#/**
#* <pre>
#* Feature: Create a valid topic and checks it out.
#*
#* Scenario: 'git convey topics start --checkout task-foo' from master
#* Given 'git-convey' is installed
#*   And I am on the 'master' branch'
#* When I type 'git convey topics start task-foo'
#* Then text "Switched to branch 'task-foo'" is printed to stdout
#*   And branch 'task-foo' is created in the local repository
#*   And branch 'task-foo' is created in the origin repository
#*   And the current local branch is 'task-foo'
#*   And the script exits with exit code 0.
#* </pre>
#*/

source `dirname $0`/../../lib/cli-lib.sh
setup_path `dirname $0`/../../../runnable
source `dirname $0`/../../lib/environment-lib.sh
source `dirname $0`/../../lib/start-lib.sh
init_test_environment `dirname $0`/../../.. `basename $0`
cd $WORKING_REPO_PATH

test_start 'git convey topics start --checkout task-foo' 'topics' 'task-foo' "Created topic 'task-foo' on origin." '' 0 0
if ! git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    echo "ERROR: Did not find expected local branch for topic '$BRANCH_NAME' in $WORKING_REPO_PATH."
fi
