#!/bin/bash

#/**
#* <pre>
#* Feature: Report bad topics action.
#*
#* Scenario: 'con topics foo'
#* Given 'conveyor-workflow' is installed
#* When I type 'con topics foo'
#* Then text is printed to stdout starting with 'usage: con topics'
#* And text is printed to stderr starting with "Unknown action: 'foo'."
#* And the script exits with exit code 1.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../..
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable

test_output "con topics foo" "usage: con topics" "Unknown action: 'foo'." 1
