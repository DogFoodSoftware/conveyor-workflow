#!/bin/bash

#/**
#* <pre>
#* Feature: Checkout
#*
#* Scenario: Switching topics with local changes; specifically new, untracked file.
#* Given 'git-convey' is installed
#*   And there exists a topic 'existing-topic-a'
#*   And there exists a topic 'existing-topic-b'
#*   And I have checked out 'existing-topic-a'
#*   And there is a new, untracked file in the working directory
#* When I type 'git convey topics checkout existing-topic-b'
#* Then text "Foo bar" is printed to stderr
#*   And I remain on topic 'existing-topic-a'
#*   And the script exits with exit code 1.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
init_test_environment $TEST_BASE/.. `basename $0`
cd $WORKING_REPO_PATH

git checkout -q master
git convey topics start --checkout existing-topic-a >/dev/null
git convey topics start existing-topic-b >/dev/null
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
if [ x"$CURRENT_BRANCH" != x'topics-existing-topic-a' ]; then
    echo "ERROR: Expected to be on branch 'topics-existing-topic-a'; test inconclusive, but instead on '$CURRENT_BRANCH'."
fi
touch foo
test_output 'git convey topics checkout existing-topic-b' '' "Current branch has unknown files; cowardly refusing checkout topic 'existing-topic-b'." 1
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
if [ x"$CURRENT_BRANCH" != x'topics-existing-topic-a' ]; then
    echo "ERROR: Expected to be on branch 'topics-existing-topic-a' after failed checkout, but instead on '$CURRENT_BRANCH'."
fi
