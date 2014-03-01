#!/bin/bash

#/**
#* <pre>
#* Feature: Delete existing (local) topic.
#*
#* Scenario: 'git convey topics delete existing-topic' from master
#* Given 'git-convey' is installed
#*   And I am on the 'master' branch
#*   And there exists a topic 'existing-topic'
#* When I type 'git convey topics delete existing-topic'
#* Then text "Deleted local topic 'existing-topic'." is printed to stdout
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
test_output 'git convey topics delete existing-topic' "Deleted local topic 'existing-topic'." '' 0
if git rev-parse --verify -q existing-topic; then
    echo "ERROR: git seems to think that the deleted topic 'existing-topic' still exists."
fi
