#!/bin/bash

#/**
#* <pre>
#* Feature: 'con issues next'
#*
#* Scenario: 'con issues next' single repo
#* Given 'conveyor-workflow' is installed
#*   And the current repository has been cloned from GitHub
#*   And $HOME/.conveyor-workflow/github is in place
#*   And $HOME/.conveyor-workflow/github defines GITHUB_AUTH_TOKEN
#*   And the token has the necessary 'repo' scope
#*   And two issues with label 'when : next' have been created
#* When I type 'con issues next'
#* Then I should see two issues reported on the command line
#*   And the script exits with exit code 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../..
TEST_BASE=`realpath $TEST_BASE`
source $TEST_BASE/../runnable/common-lib.sh
source $TEST_BASE/lib/cli-lib.sh
automate_github_https
check_path
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
source $TEST_BASE/../runnable/lib/github-hooks.sh
init_github_test_environment `basename $0`
ISSUE_NUMBER1=`create_issue 'DogFoodSoftware/test-repo' "$0 - 1" --labels='"when : now"'`
ISSUE_NUMBER2=`create_issue 'DogFoodSoftware/test-repo' "$0 - 2" --labels='"when : now"'`
cd $WORKING_REPO_PATH

RESULTS=`con issues next`
LINE_COUNT=`echo "$RESULTS" | wc -l`
if [ $LINE_COUNT -ne 2 ]; then
    echo "ERROR: Expected 2 issues / lines; got $LINE_COUNT."
fi
# Issues should be in order of creation.
TEST_ISSUE_NUMBER1=`echo "$RESULTS" | sed -n '1p' | awk '{print $1}'`
if [ x"$TEST_ISSUE_NUMBER1" != x"$ISSUE_NUMBER1" ]; then
    echo "ERROR: Expected first issue number '$ISSUE_NUMBER1', got '$TEST_ISSUE_NUMBER1'."
fi
TEST_ISSUE_NUMBER2=`echo "$RESULTS" | sed -n '2p' | awk '{print $1}'`
if [ x"$TEST_ISSUE_NUMBER2" != x"$ISSUE_NUMBER2" ]; then
    echo "ERROR: Expected second issue number '$ISSUE_NUMBER2', got '$TEST_ISSUE_NUMBER2'."
fi
# Cleanup the issues.
close_issue 'DogFoodSoftware/test-repo' "$ISSUE_NUMBER1" > /dev/null
close_issue 'DogFoodSoftware/test-repo' "$ISSUE_NUMBER2" > /dev/null
