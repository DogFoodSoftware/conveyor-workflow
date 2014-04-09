#!/bin/bash

#/**
#* <pre>
#* Feature: topics start
#*
#* Scenario: 'con topics start 1-foo' is checked against GitHub repo and found to be available.
#*
#* Given 'conveyor-workflow' is installed
#*   And the current repository has been cloned from GitHub
#*   And that repo has an open issue #1
#*   And $HOME/.conveyor-workflow/github is in place
#*   And $HOME/.conveyor-workflow/github defines GITHUB_AUTH_TOKEN
#*   And the token has the necessary 'user' scope
#* When I type 'con topics start 1-foo'
#* Then I should find the text 'Created topic '1-foo' on origin.' in the output
#*   And the issue is assigned to the GITHUB_LOGIN
#*   And the script exits with exit code 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
TEST_BASE=`realpath $TEST_BASE`
source $TEST_BASE/lib/cli-lib.sh
source $TEST_BASE/../runnable/lib/resty
source $TEST_BASE/../runnable/lib/rest-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
source $TEST_BASE/../runnable/lib/github-hooks.sh
init_github_test_environment `basename $0`
TEST_REPO=https://github.com/DogFoodSoftware/test-repo.git
ISSUE_NUMBER=`create_issue "DogFoodSoftware/test-repo" "$0"`
cd $WORKING_REPO_PATH

ISSUE_DESC=`uuidgen`
test_output "con topics start $ISSUE_NUMBER-$ISSUE_DESC" "Created topic '$ISSUE_NUMBER-$ISSUE_DESC' on origin. Issue is verified at $TEST_REPO." '' 0

if [ ! -f $HOME/.conveyor-workflow/github-login ]; then
    echo "ERROR: Did not find expected '\$HOME/.conveyor-workflow/github-login' cache."
else
    source $HOME/.conveyor-workflow/github
    source $HOME/.conveyor-workflow/github-login
    ASSIGNEE=`github_query '["assignee"]["login"]' GET /repos/DogFoodSoftware/test-repo/issues/$ISSUE_NUMBER`
    if [ x"$ASSIGNEE" != x"$GITHUB_LOGIN" ]; then
	echo "ERROR: Expected assignee '$GITHUB_LOGIN', but got '$ASSIGNEE'."
    fi 
fi # $HOME/.conveyor-workflow/github-login exists

