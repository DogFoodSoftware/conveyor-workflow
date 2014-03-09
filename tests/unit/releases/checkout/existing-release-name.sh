#!/bin/bash

#/**
#* <pre>
#* Feature: Create a valid release.
#*
#* Scenario: 'con releases checkout existing-release' from master
#* Given 'conveyor-workflow' is installed
#*   And I am on the 'master' branch
#*   And there exists a release 'existing-release'
#* When I type 'con releases checkout existing-release'
#* Then text "Switched to release 'existing-release'." is printed to stdout
#*   And I am now on branch 'releases-existing-release'
#*   And the script exits with exit code 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
init_test_environment `basename $0`
cd $WORKING_REPO_PATH

git checkout -q master
con releases start existing-release >/dev/null
if ! git checkout -q master; then
    echo "ERROR: Could not reset to master; test inconclusive."
fi
test_output 'con releases checkout existing-release' "Switched to release 'existing-release'." '' 0
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
if [ x"$CURRENT_BRANCH" != x'releases-existing-release' ]; then
    echo "ERROR: Expected to be on branch 'releases-existing-release' after checking out release, but instead on '$CURRENT_BRANCH'."
fi
