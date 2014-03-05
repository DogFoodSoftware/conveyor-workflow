#!/bin/bash

#/**
#* <pre>
#* Feature: Report bad releases action.
#*
#* Scenario: 'git convey releases foo'
#* Given 'git-convey' is installed
#* When I type 'git convey releases foo'
#* Then text is printed to stdout starting with 'usage: git convey releases'
#* And text is printed to stderr starting with "Unknown action: 'foo'."
#* And the script exits with exit code 1.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../..
source $TEST_BASE/lib/cli-lib.sh

test_output "git convey releases foo" "usage: git convey releases" "Unknown action: 'foo'." 1
