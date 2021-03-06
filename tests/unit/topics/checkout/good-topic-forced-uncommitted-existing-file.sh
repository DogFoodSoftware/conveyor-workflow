#!/bin/bash

#/**
#* <pre>
#* Feature: Checkout
#*
#* Scenario: Force checkout of an existing topic with tracked file modifications.
#*
#* Given 'conveyor-workflow' is installed
#*   And there exists a topic 'existing-topic-a'
#*   And there exists a topic 'existing-topic-b'
#*   And I have checked out 'existing-topic-a'
#*   And there are modifications to an existing file in the working directory
#* When I type 'con topics checkout --force existing-topic-b'
#* Then text "Switched to topic 'existing-topic-b'." is printed to stdout
#*   And I am on branch 'topics-existing-topic-b'
#*   And the script exits with exit code 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
source `dirname $0`/lib/helpers.sh
source $TEST_BASE/lib/cli-lib.sh
check_path
source $TEST_BASE/lib/environment-lib.sh
init_test_environment `basename $0`
cd $WORKING_REPO_PATH

setup_a_b
echo "bah" >> README.repo
verify_pass_a_b '--force existing-topic-b' "Switched to topic 'existing-topic-b'."
