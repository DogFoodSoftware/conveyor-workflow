#!/bin/bash

#/**
#* <pre>
#* Feature: Topics resource command line help.
#*
#* Scenario: 'con topics help'
#* Given 'conveyor-workflow' is installed
#* When I type 'con topics help'
#* Then text is printed to stdout starting with 'usage: con topics'
#* And the script exits with exit code 0.
#*
#* Scenario: 'con help topics'
#* Given 'conveyor-workflow' is installed
#* When I type 'con help topics'
#* Then text is printed to stdout starting with 'usage: con topics'
#* And the script exits with exit code 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../..
source $TEST_BASE/lib/cli-lib.sh

test_help "con help topics" "usage: con topics"
test_help "con topics help" "usage: con topics"
