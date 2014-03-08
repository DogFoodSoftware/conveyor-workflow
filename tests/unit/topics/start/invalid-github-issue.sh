#!/bin/bash

#/**
#* <pre>
#* Feature: topics start
#*
#* Scenario: 'con topics start 100-foo' is checked against GitHub repo and found to be a bad issue.
#*
#* Given 'git-convey' is installed
#*   And the current repository has been cloned from GitHub
#*   And that repo has an open issue #1
#*   And $HOME/.git-convey is in place
#*   And $HOME/.git-convey defines GITHUB_AUTH_TOKEN
#*   And the token has the necessary 'user' scope
#* When I type 'con topics start 100-foo'
#* Then I should find the text 'Created topic '100-foo' on origin.' in the output
#*   And the script exits with exit code 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
TEST_REPO='https://github.com/DogFoodSoftware/test-repo.git'
init_github_test_environment $TEST_BASE/.. `basename $0` "$TEST_REPO"
cd $WORKING_REPO_PATH

ISSUE_DESC=`uuidgen`
test_output "con topics start 100-$ISSUE_DESC" "" 'GitHub reports invalid issue number at' 1
# Cleanup branch; actually not necessary if things function right, but just in case.
git push -q origin :topics-1-$ISSUE_DESC 2>/dev/null
