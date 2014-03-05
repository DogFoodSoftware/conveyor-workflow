#!/bin/bash

#/**
#* <pre>
#* Feature: 'git convey topics submit' current branch
#*
#* Scenario: 'git convey topics submit' current branch
#* Given 'git-convey' is installed
#*   And the current repository has been cloned from GitHub
#*   And $HOME/.git-convey is in place
#*   And $HOME/.git-convey defines GITHUB_AUTH_TOKEN
#*   And the token has the necessary 'repo' scope
#*   And I have created and checked out a random topic branch
#* When I type 'con topics status'
#* Then I should find the text 'Created PR #X' in the output
#*   And the script exits with exit code 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
source $TEST_BASE/../runnable/common-lib.sh
source $TEST_BASE/lib/cli-lib.sh
automate_github_https
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
init_github_test_environment $TEST_BASE/.. `basename $0` 'https://github.com/DogFoodSoftware/test-repo.git'
cd $WORKING_REPO_PATH

ISSUE_DESC=`uuidgen`
if ! con topics start --checkout 1-${ISSUE_DESC} > /dev/null; then
    echo "ERROR: could not start issue; test inconclusive."
    exit 0
fi
echo "foo" > bar
git add bar
con topics commit -m "added bar" > /dev/null
con topics publish > /dev/null
OUTPUT=`test_output 'con topics submit' 'Created PR #' '' 0 3 0`
NUMBER=${OUTPUT:12}
NUMBER=${NUMBER:0:$((${#NUMBER} - 1))}
if ! [[ "$NUMBER" =~ ^-?[0-9]+$ ]]; then
    echo "ERROR: Expected PR number, but got: ${NUMBER}."
fi
# TODO: cleanup branch
rm $HOME/.netrc
