#!/bin/bash

#/**
#* <pre>
#* Feature: topics abandon
#*
#* Scenario: 'con topics abondon 100-bar' bad reference
#*
#* Given 'conveyor-workflow' is installed
#*   And the current repository has been cloned from GitHub
#*   And that repo has no issue #100
#*   And $HOME/.conveyor-workflow/github is in place
#*   And $HOME/.conveyor-workflow/github defines GITHUB_AUTH_TOKEN
#*   And the token has the necessary 'user' scope
#* When I type 'con topics abandon 100-foo'
#* Then I should find the text "WARNING: Nothing found to abandon for '100-foo'." on stderr
#*   And the script exits with exit code 1.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
TEST_BASE=`realpath $TEST_BASE`
source $TEST_BASE/lib/cli-lib.sh
check_path
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
source $TEST_BASE/../runnable/lib/github-hooks.sh
init_github_test_environment `basename $0`
if [ $? -ne 0 ]; then 
    echo "Could not initialize test environment. Test inconclusive." >&2;
    exit 2
fi
TEST_REPO=https://github.com/DogFoodSoftware/test-repo.git
cd $WORKING_REPO_PATH

ISSUE_DESC=`uuidgen`
test_output "con topics abandon 999999-$ISSUE_DESC" '' "WARNING: Nothing found to abandon for '999999-$ISSUE_DESC'." 1
