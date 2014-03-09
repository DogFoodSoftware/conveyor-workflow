#!/bin/bash

#/**
#* <pre>
#* Feature: Publish current topic.
#*
#* Scenario: 'con topics publish' from topic 'current-topic'
#* Given 'conveyor-workflow' is installed
#*   And I am on the 'master' branch
#*   And there exists a topic 'current-topic'
#* When I type 'con topic checkout current-topic'
#*   And I type 'con topic publish'
#* Then text "Published topic 'current-topic'." is printed to stdout
#*   And I am on branch 'current-topic'
#*   And the script exits with exit code 0
#*   And the remote branch head matches the current branch head.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
init_test_environment $TEST_BASE/.. `basename $0`
cd $WORKING_REPO_PATH

git checkout -q master
con topics start current-topic >/dev/null
if ! git checkout -q master; then
    echo "ERROR: Could not reset to master; test inconclusive."
fi
if ! con topics checkout current-topic >/dev/null; then
    echo "ERROR: Could not checkout current-topic; test inconclusive."
fi
test_output 'con topics publish' "Published topic 'current-topic'." '' 0
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
if [ x"$CURRENT_BRANCH" != x'topics-current-topic' ]; then
    echo "ERROR: Expected to be on branch 'topics-current-topic' after publishing topic, but instead on '$CURRENT_BRANCH'."
fi
if [ `git rev-parse topics-current-topic` != `git rev-parse remotes/origin/topics-current-topic` ]; then
    echo "ERROR: Expected local and remote 'topics-current-topic' to match, but they did not."
fi
