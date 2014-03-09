#!/bin/bash

#/**
#* <pre>
#* Feature: Set Resource
#*

#* Scenario: Implied resource is cleared when non-resource action or another
#* resource indicated.
#*
#* Given 'conveyor-workflow' is installed
#*   And the implied resource has been set to topics
#*   And I invoke 'con' with a valid resource or global action
#* When I type 'con checkout foo'
#* Then I see error "Unknown resource 'checkout'.".
#* </pre>
#*/
TEST_BASE=`dirname $0`/../..
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
init_test_environment $TEST_BASE/.. `basename $0`
cd $WORKING_REPO_PATH

con --setresource topics >/dev/null
if ! con releases start foo > /dev/null; then
    echo "ERROR: 'con' execution failed; test inconclusive."
fi
test_output 'con checkout task-foo' 'usage: con' "Unknown resource: 'checkout'." 1

con --setresource topics >/dev/null
if ! con status > /dev/null; then
    echo "ERROR: 'con' execution failed; test inconclusive."
fi
test_output 'con checkout task-foo' 'usage: con' "Unknown resource: 'checkout'." 1
