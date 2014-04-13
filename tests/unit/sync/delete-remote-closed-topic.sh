#!/bin/bash

#/**
#* <pre>
#* Feature: sync
#*
#* Scenario: Sync discovers (non-current) topic closed.
#*
#* Given 'conveyor-workflow' is installed
#*   And I have cloned a conveyor-workflow repository
#*   And I have started topic '1-foo' and published changes
#*   And I am currontly on master
#*   And '1-foo' has been deleted, but not merged into master
#* When I type 'con sync --allbranches'
#* Then I remain on the 'master' branch
#*   And the local topic branch remains intact
#*   And "Topic '1-foo' closed." is printed to stdout
#*   And the script exits with 0.
#* </pre>
#*/
TEST_BASE=`dirname $0`/../..
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
init_test_environment `basename $0`
cd $WORKING_REPO_PATH

git checkout -q master
con topics start --checkout 1-foo >/dev/null 2>&1
touch 'foo'
git add foo > /dev/null
con topics commit -m "added file foo" >/dev/null
con topics publish >/dev/null
git checkout -q master

cd $ORIGIN_REPO_PATH
git checkout -q master
git merge -q topics-1-foo
git branch -q -d topics-1-foo

cd $WORKING_REPO_PATH
test_output 'con sync --allbranches' "Topic '1-foo' closed." '' 0
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
if [ x"$CURRENT_BRANCH" != x'master' ]; then
    echo "ERROR: Expected to be on branch 'master' after sync, but instead on '$CURRENT_BRANCH'."
fi
