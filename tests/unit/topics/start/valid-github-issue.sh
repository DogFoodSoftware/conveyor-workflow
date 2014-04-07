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
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
init_github_test_environment `basename $0`
TEST_REPO=https://github.com/DogFoodSoftware/test-repo.git
cd $WORKING_REPO_PATH

ISSUE_DESC=`uuidgen`
test_output "con topics start 1-$ISSUE_DESC" "Created topic '1-$ISSUE_DESC' on origin. Issue is verified at $TEST_REPO." '' 0

if [ ! -f $HOME/.conveyor-workflow/github-login ]; then
    echo "ERROR: Did not find expected '\$HOME/.conveyor-workflow/github-login' cache."
else
    source $HOME/.conveyor-workflow/github
    source $HOME/.conveyor-workflow/github-login
    
    JSON=`curl -s -u $GITHUB_AUTH_TOKEN:x-oauth-basic https://api.github.com/repos/DogFoodSoftware/test-repo/issues/1`
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
	echo "ERROR: Could not get issue from github; test inonclusive."
    else
	PHP_BIN=$DFS_HOME/third-party/php5/runnable/bin/php
	ASSIGNEE=`echo $JSON | $PHP_BIN -r '$handle = fopen ("php://stdin","r"); $json = stream_get_contents($handle); $data = json_decode($json, true); print $data["assignee"]["login"];'`
	if [ x"$ASSIGNEE" != x"$GITHUB_LOGIN" ]; then
	    echo "ERROR: Expected assignee '$GITHUB_LOGIN', but got '$ASSIGNEE'."
	fi 
    fi
fi # $HOME/.conveyor-workflow/github-login exists

# Cleanup branch.
git push -q origin :topics-1-$ISSUE_DESC

source $TEST_BASE/../runnable/lib/github-hooks.sh
delete_repo 'DogFoodSoftware/test-repo'
