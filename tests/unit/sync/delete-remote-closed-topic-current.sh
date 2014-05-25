#!/bin/bash

#/**
#* <pre>
#* Feature: sync
#*
#* Scenario: Sync discovers current topic closed.
#*
#* Given 'conveyor-workflow' is installed
#*   And I have cloned a conveyor-workflow repository
#*   And I have started topic '1-foo' and published changes
#*   And '1-foo' has been fully merged into master on the remote
#* When I type 'con topics sync'
#* Then the current topic is switched to the 'master' branch
#*   And the local topic branch is deleted
#*   And "Current topic '1-foo' closed. Switched to master release.' is printed to stdout
#*   And the script exits with 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../..
source $TEST_BASE/lib/cli-lib.sh
check_path
source $TEST_BASE/lib/environment-lib.sh
init_test_environment `basename $0`
cd $WORKING_REPO_PATH

git checkout -q master
con topics start --checkout 1-foo >/dev/null
touch 'foo'
git add foo > /dev/null
con topics commit -m "added file foo" >/dev/null
con topics publish >/dev/null

cd $ORIGIN_REPO_PATH
git checkout -q master
git merge -q topics-1-foo
git branch -q -d topics-1-foo

cd $WORKING_REPO_PATH
test_output 'con sync' "Current topic '1-foo' closed. Switched to master release." '' 0
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
if [ x"$CURRENT_BRANCH" != x'master' ]; then
    echo "ERROR: Expected to be on branch 'master' after sync, but instead on '$CURRENT_BRANCH'."
fi
