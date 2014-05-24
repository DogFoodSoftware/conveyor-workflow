#!/bin/bash

#/**
#* <pre>
#* Feature: Informs user they cannot delete a local topic with unpublished
#* changes.
#*
#* Scenario: 'con topics delete changed-topic' from master
#* Given 'conveyor-workflow' is installed
#*   And I am on the 'master' branch
#*   And there exists a topic 'changed-topic'
#*   And the topic has unpublished changes
#* When I type 'con topics delete changed-topic'
#* Then text "Topic 'changed-topic' has local changes; cannot delete." is printed to stdout
#*   And I am on branch 'master'
#*   And the script exits with exit code 1.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
source $TEST_BASE/lib/cli-lib.sh
check_path
source $TEST_BASE/lib/environment-lib.sh
init_test_environment `basename $0`
cd $WORKING_REPO_PATH

git checkout -q master
if ! con topics start --checkout changed-topic >/dev/null; then
    echo "ERROR: could not start topic 'changed-topic'; test inconclusive."
    exit
fi
touch foo
git add foo
git commit -q -m "added file foo"
if ! git checkout -q master; then
    echo "ERROR: Could not reset to master; test inconclusive."
fi
test_output 'con topics delete changed-topic' '' "Topic 'changed-topic' has local changes. Please publish or abandon." 1
if ! git rev-parse --verify -q topics-changed-topic > /dev/null; then
    echo "ERROR: Looks like the topic branch was erroneously deleted."
fi
