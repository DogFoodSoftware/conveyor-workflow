#!/bin/bash

#/**
#* <pre>
#* Feature: Sync/Clone a New Repo
#*
#* Scenario: 'git convey sync' a new repo
#* Given 'git-convey' is installed
#* And a pre-populated test repository
#* When I type 'git convey sync $ORIGIN_REPO_PATH $WORKING_REPO_PATH'
#* Then text "Sync complete." is printed to stdout
#* And all remote references are created in the local repository
#* And the script exits with exit code 0.
#* </pre>
#*/

set -e
export GIT_CONVEY_TEST_MODE=0 # that's bash for true

source `dirname $0`/../lib/cli-lib.sh
setup_path `dirname $0`/../../runnable
source `dirname $0`/../lib/environment-lib.sh
source `dirname $0`/../lib/start-lib.sh
init_test_environment `dirname $0`/../.. `basename $0`
cd $WORKING_REPO_PATH

populate_test_environment

rm -rf $WORKING_REPO_PATH
test_output "git convey sync file:///$ORIGIN_REPO_PATH $WORKING_REPO_PATH" "Sync complete." '' 0
cd $WORKING_REPO_PATH
REFERENCES=`git show-ref -d`
ORIGIN_REF_COUNT=`echo "$REFERENCES" | grep refs/remotes | wc -l`
if [ $ORIGIN_REF_COUNT -ne 4 ]; then
    echo "ERROR: Expected 4 origin refs, but got $ORIGIN_REF_COUNT"
fi
LOCAL_MASTER=`echo "$REFERENCES" | grep refs/heads/master | awk '{print $1}'`
ORIGIN_MASTER=`echo "$REFERENCES" | grep refs/remotes/origin/master | awk '{print $1}'`
if [ x"$LOCAL_MASTER" != x"$ORIGIN_MASTER" ]; then
    echo "ERROR: Expected local and remote master HEADs to match, but they did not."
fi
FOUND_BAR=`echo "$REFERENCES" | grep refs/remotes/origin/task-add-bar | wc -l`
if [ $FOUND_BAR -ne 1 ]; then
    echo "ERROR: did not find 'task-add-bar' in origin branches."
fi
FOUND_BAR=`echo "$REFERENCES" | grep refs/remotes/origin/task-add-foo | wc -l`
if [ $FOUND_BAR -ne 1 ]; then
    echo "ERROR: did not find 'task-add-foo' in origin branches."
fi
