#!/bin/bash

#/**
#* <pre>
#* Feature: Manage (GitHub) repos
#*
#* Scenario: 'con repos init --github temp-test' configures repo
#* Given 'conveyor-workflow' is installed
#*   And repo 'temp-test' does not exist
#*   And $HOME/.conveyor-workflow/github is in place
#*   And $HOME/.conveyor-workflow/github defines GITHUB_AUTH_TOKEN
#*   And the token has the necessary 'repo' scope
#*   And we initialize repo 'temp-test' on GitHub under DogFoodSoftware
#* When I type 'con repo init --github temp-test'
#* Then I should find the text 'Configured 'temp-test' for conveyor-workflow'
#*   And the script exits with exit code 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
source $HOME/.conveyor/config
source $HOME/.conveyor-workflow/github
source $TEST_BASE/../runnable/common-lib.sh
source $TEST_BASE/../runnable/common-checks.sh
source $TEST_BASE/lib/cli-lib.sh
automate_github_https
check_path
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
source $TEST_BASE/../runnable/lib/github-hooks.sh

if does_repo_exist "DogFoodSoftware/temp-test"; then
    echo "ERROR: repo 'temp-test' exists, bailing out; test inconclusive."
    exit 0
fi

if ! create_repo "DogFoodSoftware/temp-test"; then
    echo "ERROR: could not create repo, bailing out; test inconclusive."
    exit 0
fi

# TODO: should be 'con repo init'; issue already created.
con repos init --github DogFoodSoftware/temp-test > /dev/null
RESULT=$?
if [ $RESULT -ne 0 ]; then
    echo "ERROR: 'con repo init --github temp-test' exitted with status '$RESULT'."
else
    LABELS_JSON=`curl -s -u $GITHUB_AUTH_TOKEN:x-oauth-basic https://api.github.com/repos/DogFoodSoftware/temp-test/labels`
    source $TEST_BASE/../src/lib/standard-issue-labels.sh
    for LABEL in "${LABELS[@]}"; do
	LABEL=`echo $LABEL | cut -d'#' -f1`
	if [ `echo $LABELS_JSON | grep "$LABEL" | wc -l` -ne 1 ]; then
	    echo "ERROR: did not find expected label '$LABEL'."
	fi
    done
    # Now verify that only the standard labels are present.
    EXPECTED_COUNT=${#LABELS[@]}
    ACTUAL_COUNT=`echo $LABELS_JSON | grep -o '"name":' | wc -l`
    if [ $EXPECTED_COUNT -ne $ACTUAL_COUNT ]; then
	echo "ERROR: expected $EXPECTED_COUNT labels but found $ACTUAL_COUNT."
    fi
fi
delete_repo "DogFoodSoftware/temp-test"
