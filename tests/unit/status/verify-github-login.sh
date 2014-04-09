#!/bin/bash

#/**
#* <pre>
#* Feature: 'con status' reports GitHub login (for repo origin)
#*
#* Scenario: 'con status' on a repo cloned from GitHub 
#* Given 'conveyor-workflow' is installed
#*   And the current repository has been cloned from GitHub
#*   And $HOME/.conveyor-workflow/github is in place
#*   And $HOME/.conveyor-workflow/github defines GITHUB_AUTH_TOKEN
#*   And the token has the necessary 'user' scope
#* When I type 'con status'
#* Then I should find the text 'Connected to GitHub as: xxx' in the output
#*   And the script exits with exit code 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../..
TEST_BASE=`realpath $TEST_BASE`
source $TEST_BASE/lib/cli-lib.sh
source $TEST_BASE/../runnable/lib/resty
source $TEST_BASE/../runnable/lib/rest-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
source $TEST_BASE/../runnable/lib/github-hooks.sh
init_github_test_environment `basename $0`
cd $WORKING_REPO_PATH

rm $HOME/.conveyor-workflow/github-login
# 5 words: Connected to Github as: XXX
test_output 'con status' '' '' 0 5

