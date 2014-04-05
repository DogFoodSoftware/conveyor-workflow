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
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
source $TEST_BASE/../runnable/lib/github-hooks.sh

if does_github_repo_exist "temp-test"; then
    echo "ERROR: repo 'temp-test' exists, bailing out; test inconclusive."
    exit 0
fi

if ! create_repo "DogFoodSoftware" "temp-test"; then
    echo "ERROR: could not create repo, bailing out; test inconclusive."
    exit 0
fi

# TODO: should be 'con repo init'; issue already created.
echo A
con init --github temp-test
echo B
RESULT=$?
if [ $RESULT -ne 0 ]; then
    echo "ERROR: 'con repo init --github temp-test' exitted with status '$RESULT'."
else
    echo curl -s -u $GITHUB_AUTH_TOKEN:x-oauth-basic https://api.github.com/repos/DogFoodSoftware/temp-test/labels -d
    LABELS_JSON=`curl -s -u $GITHUB_AUTH_TOKEN:x-oauth-basic https://api.github.com/repos/DogFoodSoftware/temp-test/labels`
    # Spot check
    echo $LABELS_JSON
    EXPECTED_LABELS=('change : bug' 'sched : whenever')
    for LABEL in "${EXPECTED_LABELS[@]}"; do
	echo "I-2: $LABEL"
	if [ `echo $LABELS_JSON | grep "$LABEL" | wc -l` -ne 1 ]; then
	    echo "ERROR: did not find expected label '$LABEL'."
	fi
    done
fi
echo I-3
delete_repo "DogFoodSoftware" "temp-test"
echo J
