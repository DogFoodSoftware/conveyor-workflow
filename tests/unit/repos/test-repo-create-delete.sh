#!/bin/bash

#/**
#* <pre>
#* Feature: 'con repos create-test'
#*
#* Scenario: 'con repos create-test' creates test repo
#* Given 'conveyor-workflow' is installed
#*   And the current repository has been cloned from GitHub
#*   And $HOME/.conveyor-workflow/github is in place
#*   And $HOME/.conveyor-workflow/github defines GITHUB_AUTH_TOKEN
#*   And the token has the necessary 'repo' scope
#* When I type 'con repos create-test'
#* Then I should find the text 'Test directory initialzed."
#*   And a conveyor repo checkout in '$CONVEYOR_WORKFLOW/data/test/manual-test/repo'
#*   And a 'manual-test-repo' on GitHub
#*   And the script exits with exit code 0.
#*
#* Scenario: 'con repos delete-test' removes test repo
#* Given the previous 'con repos create-test' has run successfull
#* When I type 'con repos delete-test'
#* Then directory '$CONVEYOR_WORKFLOW/data/test/manual-test/repo' is gone
#*   And there is no 'manual-test-repo' on GitHub
#*   And the script exits with exit code 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../..
TEST_BASE=`realpath $TEST_BASE`
source $TEST_BASE/../runnable/common-lib.sh
source $TEST_BASE/lib/cli-lib.sh
automate_github_https
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
source $TEST_BASE/../runnable/lib/github-hooks.sh
source $HOME/.conveyor/config
GIT_CONVEY_HOME="$CONVEYOR_HOME/workflow"

ERROR=1 # bash for false
if ! test_output 'con repos create-test' 'Test directory initialized.' '' 0; then
    ERROR=0 # bash for true
fi
if [ ! -d $GIT_CONVEY_HOME/data/test/manual-test-repo ]; then
    echo "ERROR: did not find expected directory '$GIT_CONVEY_HOME/data/test/manual-test-repo'."
    ERROR=0
fi
if ! does_repo_exist 'DogFoodSoftware/manual-test-repo'; then
    echo "ERROR: did not find 'DogFoodSoftware/manual-test-repo' on github."
    ERROR=0
fi

# Since we have to cleanup anyway, this serves as second test. Requires first
# part successful.
if [ $ERROR -eq 0 ]; then
    exit 0
fi
test_output 'con repos delete-test' '' '' 0
if [ -d $GIT_CONVEY_HOME/data/test/manual-test-repo ]; then
    echo "ERROR: Expected '$GIT_CONVEY_HOME/data/test/manual-test-repo' to be deleted."
fi
if does_repo_exist 'DogFoodSoftware/manual-test-repo'; then
    echo "ERROR: Expected 'DogFoodSoftware/manual-test-repo' to be removed."
fi
