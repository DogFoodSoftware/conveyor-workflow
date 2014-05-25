#!/bin/bash

#/**
#* <pre>
#* Feature: Checkout
#*
#* Scenario: Switching topics with local changes; spec. uncommitted existing file changes.
#* Given 'conveyor-workflow' is installed
#*   And there exists a topic 'existing-topic-a'
#*   And there exists a topic 'existing-topic-b'
#*   And I have checked out 'existing-topic-a'
#*   And there are is a uncommitted changes to an existing file in the working directory
#* When I type 'con topics checkout existing-topic-b'
#* Then text "Foo bar" is printed to stderr
#*   And I remain on topic 'existing-topic-a'
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
con topics start --checkout existing-topic-a >/dev/null
con topics start existing-topic-b >/dev/null
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
if [ x"$CURRENT_BRANCH" != x'topics-existing-topic-a' ]; then
    echo "ERROR: Expected to be on branch 'topics-existing-topic-a'; test inconclusive, but instead on '$CURRENT_BRANCH'."
fi
echo "blah" >> README.repo
test_output 'con topics checkout existing-topic-b' '' "Current branch has unstaged changes; cowardly refusing to checkout topic 'existing-topic-b'." 1
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
if [ x"$CURRENT_BRANCH" != x'topics-existing-topic-a' ]; then
    echo "ERROR: Expected to be on branch 'topics-existing-topic-a' after failed checkout, but instead on '$CURRENT_BRANCH'."
fi
