#!/bin/bash

#/**
#* <pre>
#* Feature: Publish an existing topic.
#*
#* Scenario: 'git convey topics publish existing-topic' from master
#* Given 'git-convey' is installed
#*   And I am on the 'master' branch
#*   And there exists a topic 'existing-topic'
#* When I type 'git convey topics publish existing-topic'
#* Then text "Published topic 'existing-topic'." is printed to stdout
#*   And I am on branch 'master'
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
test_output 'git convey topics publish existing-topic' "Published topic 'existing-topic'." '' 0
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
if [ x"$CURRENT_BRANCH" != x'master' ]; then
    echo "ERROR: Expected to be on branch 'master' after publishing topic, but instead on '$CURRENT_BRANCH'."
fi
