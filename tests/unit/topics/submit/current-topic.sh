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
source $TEST_BASE/../runnable/common-lib.sh
source $TEST_BASE/lib/cli-lib.sh
automate_github_https
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
init_github_test_environment `basename $0`
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
# Cleanup branch.
git push -q origin :topics-1-$ISSUE_DESC
# Close PR
set_github_origin_data
CURL_COMMAND="curl --max-time 4 -s -u $GITHUB_AUTH_TOKEN:x-oauth-basic -X PATCH -d @- https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/pulls/$NUMBER"
cat <<EOF | $CURL_COMMAND > /dev/null
{
  "state" : "closed"
}
EOF

source $TEST_BASE/../runnable/lib/github-hooks.sh
delete_repo 'DogFoodSoftware/test-repo'
