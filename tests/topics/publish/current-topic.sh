#!/bin/bash

#/**
#* <pre>
#* Feature: Publish current topic.
#*
#* Scenario: 'git convey topics publish' from topic 'current-topic'
#* Given 'git-convey' is installed
#*   And I am on the 'master' branch
#*   And there exists a topic 'current-topic'
#* When I type 'git convey topic checkout current-topic'
#*   And I type 'git convey topic publish'
#* Then text "Published topic 'current-topic'." is printed to stdout
#*   And I am on branch 'current-topic'
#*   And the script exits with exit code 0.
#* </pre>
#*/

source `dirname $0`/../../lib/cli-lib.sh
setup_path `dirname $0`/../../../runnable
source `dirname $0`/../../lib/environment-lib.sh
init_test_environment `dirname $0`/../../.. `basename $0`
cd $WORKING_REPO_PATH

git checkout -q master
git convey topics start existing-topic >/dev/null
if ! git checkout -q master; then
    echo "ERROR: Could not reset to master; test inconclusive."
fi
if ! git convey checkout current-topic >/dev/null
    echo "ERROR: Could not checkout current-topic; test inconclusive."
fi
test_output 'git convey topics publish' "Published topic 'current-topic'." '' 0
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
if [ x"$CURRENT_BRANCH" != x'current-topic' ]; then
    echo "ERROR: Expected to be on branch 'current-topic' after publishing topic, but instead on '$CURRENT_BRANCH'."
fi