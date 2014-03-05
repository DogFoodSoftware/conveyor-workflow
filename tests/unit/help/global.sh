#!/bin/bash

#/**
#* <pre>
#* Feature: Global git-convey command line help.
#*
#* Scenario: 'git convey help'
#* Given 'git-convey' is installed
#* When I type 'git convey help'
#* Then text is printed to stdout starting with 'usage: git convey <resource|global action>'
#* And no text is printed to stdeer
#* And the script exits with exit code 0.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../..
source $TEST_BASE/lib/cli-lib.sh

test_help "git convey help" "usage: git convey <resource|global action>"

