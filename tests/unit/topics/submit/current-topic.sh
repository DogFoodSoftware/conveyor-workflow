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
con topics commit -m "added bar" > /dev/null
con topics publish > /dev/null
OUTPUT=`test_output 'con topics submit' 'Created PR #' '' 0 3 0`
PR_NUMBER=${OUTPUT:12}
PR_NUMBER=${PR_NUMBER:0:$((${#PR_NUMBER} - 1))}
if ! [[ "$PR_NUMBER" =~ ^-?[0-9]+$ ]]; then
    echo "ERROR: Expected PR number, but got: ${PR_NUMBER}."
fi
# Cleanup branch.
git push -q origin :topics-$ISSUE_NUMBER-$ISSUE_DESC
# Close PR and Issue
set_github_origin_data
github_api PATCH /repos/$GITHUB_OWNER/$GITHUB_REPO/pulls/$PR_NUMBER '{"state" : "closed"}' > /dev/null
github_api PATCH /repos/$GITHUB_OWNER/$GITHUB_REPO/issues/$ISSUE_NUMBER '{"state" : "closed"}' > /dev/null
