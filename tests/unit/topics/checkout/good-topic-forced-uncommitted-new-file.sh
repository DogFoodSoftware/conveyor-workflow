#!/bin/bash

#/**
#* <pre>
#* Feature: Force checkout of an existing topic with an uncommitted new file.

#*
#* Scenario: Force checkout of an existing topic with an uncommitted new file.
#*
#* Given 'git-convey' is installed
#*   And there exists a topic 'existing-topic-a'
#*   And there exists a topic 'existing-topic-b'
#*   And I have checked out 'existing-topic-a'
#*   And there is a new, uncommitted file in the working directory
#* When I type 'con topics checkout --force existing-topic-b'
#* Then text "Switched to topic 'existing-topic-b'." is printed to stdout
#*   And I am on branch 'topics-existing-topic-b'
#*   And the script exits with exit code 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
source `dirname $0`/lib/helpers.sh
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
init_test_environment $TEST_BASE/.. `basename $0`
cd $WORKING_REPO_PATH

setup_a_b
touch foo
git add foo
verify_pass_a_b '--force existing-topic-b' "Switched to topic 'existing-topic-b'."
