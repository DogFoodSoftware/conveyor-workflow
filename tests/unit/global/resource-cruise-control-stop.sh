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
#*   And I invoke 'con' with a valid resource action
#* When I type 'con checkout foo'
#* Then I see error "ERROR: Unknown resource 'checkout'." on stderr.
#* </pre>
#*/
TEST_BASE=`dirname $0`/../..
source $TEST_BASE/lib/cli-lib.sh
check_path
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
init_test_environment `basename $0`
cd $WORKING_REPO_PATH

con --setresource topics >/dev/null
if ! con releases start foo > /dev/null 2>/dev/null; then
    echo "ERROR: 'con' execution failed; test inconclusive."
fi
test_output 'con checkout task-foo' 'usage: con' "ERROR: Unknown resource: 'checkout'." 1

con --setresource topics >/dev/null
if ! con  releases list > /dev/null 2>/dev/null; then
    echo "ERROR: 'con' execution failed; test inconclusive."
fi
test_output 'con checkout task-foo' 'usage: con' "ERROR: Unknown resource: 'checkout'." 1
con -s > /dev/null
