#!/bin/bash

#/**
#* <pre>
#* Feature: topics abandon
#*
#* Scenario: 'con topics abondon 1-bar' remote only
#*
#* Given 'conveyor-workflow' is installed
#*   And the current repository has been cloned from GitHub
#*   And that repo has issue #1
#*   And $HOME/.conveyor-workflow/github is in place
#*   And $HOME/.conveyor-workflow/github defines GITHUB_AUTH_TOKEN
#*   And the token has the necessary 'user' scope
#*   And the #1 issue has been started
#*   And the local branch has been closed
#*   And the issue assignment has been cleared
#* When I type 'con topics abandon 1-foo'
#* Then I should find the text "No local branch found. No authority to close branch on origin." on stdout
#*   And the script exits with exit code 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
TEST_BASE=`realpath $TEST_BASE`
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
init_github_test_environment `basename $0`
if [ $? -ne 0 ]; then 
    echo "Could not initialize test environment. Test inconclusive." >&2;
    delete_repo 'DogFoodSoftware/test-repo'
    exit 2
fi
cd $WORKING_REPO_PATH

ISSUE_DESC=`uuidgen`
test_output "con topics start --checkout '1-$ISSUE_DESC'" '' '' 0 4
source $TEST_BASE/../runnable/lib/github-hooks.sh
clear_assignee "1-$ISSUE_DESC" > /dev/null
git checkout --quiet master
git branch --quiet -D topics-1-$ISSUE_DESC
test_output "con topics abandon 1-$ISSUE_DESC" "No local branch found. No authority to close branch on origin."

delete_repo 'DogFoodSoftware/test-repo'
