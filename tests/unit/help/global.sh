#!/bin/bash

#/**
#* <pre>
#* Feature: Global conveyor-workflow command line help.
#*
#* Scenario: 'con help'
#* Given 'conveyor-workflow' is installed
#* When I type 'con help'
#* Then text is printed to stdout starting with 'usage: con <resource|global action>'
#* And no text is printed to stdeer
#* And the script exits with exit code 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../..
source $TEST_BASE/lib/cli-lib.sh

test_help "con help" "usage: con <resource|global action>"

