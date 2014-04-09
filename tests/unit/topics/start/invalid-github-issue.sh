#!/bin/bash

#/**
#* <pre>
#* Feature: topics start
#*
#* Scenario: 'con topics start 100-foo' is checked against GitHub repo and found to be a bad issue.
#*
#* Given 'conveyor-workflow' is installed
#*   And the current repository has been cloned from GitHub
#*   And that repo has an open issue #1
#*   And $HOME/.conveyor-workflow/github is in place
#*   And $HOME/.conveyor-workflow/github defines GITHUB_AUTH_TOKEN
#*   And the token has the necessary 'user' scope
#* When I type 'con topics start 100-foo'
#* Then I should find the text 'Created topic '100-foo' on origin.' in the output
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
cd $WORKING_REPO_PATH

ISSUE_DESC=`uuidgen`
test_output "con topics start 9999999-$ISSUE_DESC" "" 'GitHub reports invalid issue number at' 1
