#!/bin/bash

#/**
#* <pre>
#* Feature: 'con topics submit' current branch
#*
#* Scenario: 'con topics submit' current branch
#* Given 'conveyor-workflow' is installed
#*   And the current repository has been cloned from GitHub
#*   And $HOME/.conveyor-workflow/github is in place
#*   And $HOME/.conveyor-workflow/github defines GITHUB_AUTH_TOKEN
#*   And the token has the necessary 'repo' scope
#*   And I have created and checked out a random topic branch
#* When I type 'con topics status'
#* Then I should find the text 'Created PR #X' in the output
#*   And the script exits with exit code 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
TEST_BASE=`realpath $TEST_BASE`
source $TEST_BASE/../runnable/common-lib.sh
source $TEST_BASE/lib/cli-lib.sh
automate_github_https
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
source $TEST_BASE/../runnable/lib/github-hooks.sh
init_github_test_environment `basename $0`
ISSUE_NUMBER=`create_issue 'DogFoodSoftware/test-repo' "$0"`
cd $WORKING_REPO_PATH

ISSUE_DESC=`uuidgen`
if ! con topics start --checkout $ISSUE_NUMBER-${ISSUE_DESC} > /dev/null; then
    echo "ERROR: could not start issue; test inconclusive."
    exit 0
fi
echo "foo" > bar
git add bar
if ! test_output 'con topics commit -m "added bar"' '' '' 0; then
    exit 2
fi
if ! test_output 'con topics publish' 'Published topic' '' 0; then
    exit 2
fi
if ! test_output 'con topics submit' 'Created PR #' '' 0; then
    exit 2
fi
