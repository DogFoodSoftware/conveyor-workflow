#!/bin/bash

#/**
#* <pre>
#* Feature: topics abandon
#*
#* Scenario: 'con topics abondon 1-bar' local and remote no assignment
#*
#* Given 'conveyor-workflow' is installed
#*   And the current repository has been cloned from GitHub
#*   And that repo has issue #1
#*   And $HOME/.conveyor-workflow/github is in place
#*   And $HOME/.conveyor-workflow/github defines GITHUB_AUTH_TOKEN
#*   And the token has the necessary 'user' scope
#*   And the issue has been cleaned
#* When I type 'con topics abandon 1-foo'
#* Then I should find the text "Local branch deleted. No authority to close branch on origin." on stdout
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
    exit 2
fi
ISSUE_NUMBER=`create_issue 'DogFoodSoftware/test-repo' "$0"`
TEST_REPO=https://github.com/DogFoodSoftware/test-repo.git
cd $WORKING_REPO_PATH

ISSUE_DESC=`uuidgen`
test_output "con topics start --checkout '$ISSUE_NUMBER-$ISSUE_DESC'" '' '' 0 4
source $TEST_BASE/../runnable/lib/github-hooks.sh
clear_assignee "$ISSUE_NUMBER-$ISSUE_DESC" > /dev/null
test_output "con topics abandon $ISSUE_NUMBER-$ISSUE_DESC" "Local branch deleted. No authority to close branch on origin."

