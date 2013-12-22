#!/bin/bash

#/**
#* <pre>
#* Feature: Report bad topics action.
#*
#* Scenario: 'git convey topics foo'
#* Given 'git-convey' is installed
#* When I type 'git convey topics foo'
#* Then text is printed to stdout starting with 'usage: git convey topics'
#* And text is printed to stderr starting with "Unknown action: 'foo'."
#* And the script exits with exit code 1.
#* </pre>
#*/

source `dirname $0`/../lib/cli-lib.sh

test_output "git convey topics foo" "usage: git convey topics" "Unknown action: 'foo'." 1
