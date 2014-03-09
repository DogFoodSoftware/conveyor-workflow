#!/bin/bash

#/**
#* <pre>
#* Feature: Multi-feature
#*
#* Scenario: repo-a and repo-b each track each others work through shared branch
#* Given 'conveyor-workflow' is installed
#*   And a there is a local origin repo
#*   And there is a local working repo-a
#*   And there is a local working repo-b
#* When user executes 'con topics start --checkout 1-test-topic' from repo-a
#*   And user executes 'con topic checkeut 1-test-topic' from repo-b
#* Then repo-a HEAD should match repo-b HEAD
#* When user executes 'touch foo; git add foo; con topics commit -m "added foo"; con topics publish' in repo-a
#*   And user executes 'con sync' from repo-b
#* Then repo-a HEAD should match repo-b HEAD
#*   And the value should be different than the last check
#* When user executes 'touch bar; git add bar; con topics commit -m "added bar"; con topics publish' in repo-b
#*   And user executes 'con sync' from repo-a
#* Then repo-a HEAD should match repo-b HEAD
#*   And the value should be different than the last check
#* </pre>
#*/

TEST_BASE=`dirname $0`/..
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
init_test_environment $TEST_BASE/.. `basename $0`

WORKING_REPO_PATH_B="$WORKING_REPO_PATH/.."
WORKING_REPO_PATH_B=`realpath $WORKING_REPO_PATH_B`/repo_b
con sync "file://$ORIGIN_REPO_PATH" "$WORKING_REPO_PATH_B" > /dev/null

function check_heads() {
    MSG="$1"; shift

    cd $WORKING_REPO_PATH
    local HEAD_A=`git rev-parse HEAD`
    cd $WORKING_REPO_PATH_B
    local HEAD_B=`git rev-parse HEAD`
    if [ x"$HEAD_A" != x"$HEAD_B" ]; then
	echo "ERROR: repo-a and repo-b HEADS do not match ${MSG}."
	exit
    fi
    if [ x"$PREVIOUS_HEAD" != x"" ]; then
	if [ $PREVIOUS_HEAD == $HEAD_A ]; then
	    echo "ERROR: Repo-a HEAD unchanged ${MSG}."
	    exit
	fi
    fi
    PREVIOUS_HEAD=$HEAD_A
}

function add_file() {
    NAME="$1"; shift
    touch $NAME
    git add $NAME
    con topics commit -m "added $NAME" > /dev/null
    con topics publish > /dev/null
}

cd $WORKING_REPO_PATH
con topics start --checkout 1-test-topic > /dev/null
cd $WORKING_REPO_PATH_B
con topics checkout 1-test-topic > /dev/null
check_heads "after b checkout"
cd $WORKING_REPO_PATH
add_file foo
cd $WORKING_REPO_PATH_B
con sync > /dev/null
check_heads "after a update and b sync"
add_file bar
cd $WORKING_REPO_PATH
con sync > /dev/null
check_heads "after b update and a sync"
