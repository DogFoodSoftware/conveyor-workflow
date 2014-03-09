#!/bin/bash

#/**
#* <pre>
#* Feature: Report bad releases action.
#*
#* Scenario: 'con releases foo'
#* Given 'conveyor-workflow' is installed
#* When I type 'con releases foo'
#* Then text is printed to stdout starting with 'usage: con releases'
#* And text is printed to stderr starting with "Unknown action: 'foo'."
#* And the script exits with exit code 1.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../..
source $TEST_BASE/lib/cli-lib.sh

test_output "con releases foo" "usage: con releases" "Unknown action: 'foo'." 1
