#!/bin/bash

#/**
#* <pre>
#* Feature: Checkout
#*
#* Scenario: Switching topics with local changes; specifically new, untracked file.
#* Given 'conveyor-workflow' is installed
#*   And there exists a topic 'existing-topic-a'
#*   And there exists a topic 'existing-topic-b'
#*   And I have checked out 'existing-topic-a'
#*   And there is a new, untracked file in the working directory
#* When I type 'con topics checkout existing-topic-b'
#* Then text "Foo bar" is printed to stderr
#*   And I remain on topic 'existing-topic-a'
#*   And the script exits with exit code 1.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
source `dirname $0`/lib/helpers.sh
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
init_test_environment `basename $0`
cd $WORKING_REPO_PATH

setup_a_b
touch foo
verify_fail_a_b 'existing-topic-b' "Current branch has unknown files; cowardly refusing checkout topic 'existing-topic-b'."
