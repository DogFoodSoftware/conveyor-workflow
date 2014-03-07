#!/bin/bash

#/**
#* <pre>
#* Feature: Releases resource command line help.
#*
#* Scenario: 'con releases help'
#* Given 'git-convey' is installed
#* When I type 'con releases help'
#* Then text is printed to stdout starting with 'usage: con release'
#* And no text is printed to stdeer
#* And the script exits with exit code 0.
#*
#* Scenario: 'con help releases'
#* Given 'git-convey' is installed
#* When I type 'con help releases'
#* Then text is printed to stdout starting with 'usage: con release'
#* And no text is printed to stdeer
#* And the script exits with exit code 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../..
source $TEST_BASE/lib/cli-lib.sh

test_help "con help releases" "usage: con releases"
test_help "con releases help" "usage: con releases"
