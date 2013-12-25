#!/bin/bash

#/**
#* <pre>
#* Feature: Sync/Clone a New Repo
#*
#* Scenario: 'git convey sync' a new repo
#* Given 'git-convey' is installed
#* And an existing repo at file:///($GIT_CONVEY_HOME)/data/test/origin
#* When I type 'git convey sync file:///($GIT_CONVEY_HOME)/data/test/origin'
#* Then text "Sync complete." is printed to stdout
#* And all remote references are created in the local repository
#* And the script exits with exit code 0.
#* </pre>
#*/

source `dirname $0`/../../lib/cli-lib.sh
source `dirname $0`/../../lib/environment-lib.sh
source `dirname $0`/../../lib/start-lib.sh

init_test_environment
populate_test_environment
test_start 'git convey topics start task-foo' "Switched to branch 'task-foo'" '' 0
