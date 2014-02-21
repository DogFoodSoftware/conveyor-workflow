#!/bin/bash

#/**
#* <pre>
#* Feature: Create a valid topic.
#*
#* Scenario: 'git convey topics join task-foo' from master
#* Given 'git-convey' is installed
#*   And I am on the 'master' branch
#*   And there exists a topic 'existing-topic'
#* When I type 'git convey topics join existing-topic'
#* Then text "Switched to topic 'existing-topic'." is printed to stdout
#*   And I am now on branch 'topic-existing-topic'
#*   And the script exits with exit code 0.
#* </pre>
#*/

set -e

source `dirname $0`/../../lib/cli-lib.sh
setup_path `dirname $0`/../../../runnable
source `dirname $0`/../../lib/environment-lib.sh
source `dirname $0`/../../lib/start-lib.sh
init_test_environment `dirname $0`/../../.. `basename $0`
cd $WORKING_REPO_PATH

git checkout -q master
git branch -q topic-existing-topic
test_output 'git convey topics join existing-topic' "Switched to topic 'existing-topic'." '' 0
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
if [ x"$CURRENT_BRANCH" != x'topic-existing-topic' ]; then
    echo "ERROR: Expected to be on branch 'topic-existing-topic' after joining topic, but instead on '$CURRENT_BRANCH'."
fi
