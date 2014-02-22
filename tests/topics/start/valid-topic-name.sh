#!/bin/bash

#/**
#* <pre>
#* Feature: Create a valid topic.
#*
#* Scenario: 'git convey topics start task-foo' from master
#* Given 'git-convey' is installed
#* And I am on the 'master' branch'
#* When I type 'git convey topics start task-foo'
#* Then text "Switched to branch 'task-foo'" is printed to stdout
#* And branch 'task-foo' is created in the local repository
#* And branch 'task-foo' is created in the origin repository
#* And the script exits with exit code 0.
#* </pre>
#*/

source `dirname $0`/../../lib/cli-lib.sh
setup_path `dirname $0`/../../../runnable
source `dirname $0`/../../lib/environment-lib.sh
source `dirname $0`/../../lib/start-lib.sh
init_test_environment `dirname $0`/../../.. `basename $0`
cd $WORKING_REPO_PATH

test_start 'git convey topics start task-foo' 'topics' 'task-foo' "Switched to a new topic 'task-foo'." '' 0
