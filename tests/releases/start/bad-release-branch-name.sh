#!/bin/bash

#/**
#* <pre>
#* Feature: Report bad releases branch names.
#*
#* Scenario: 'git convey releases start "foo bar"'
#* Given 'git-convey' is installed
#* When I type 'git convey releases start "foo bar"'
#* Then no text is printed to stdout
#* And text is printed to stderr starting with "Branch name 'foo bar' cannot contain spaces."
#* And the script exits with exit code 1.
#* </pre>
#*/

source `dirname $0`/../../lib/cli-lib.sh

test_output "git convey releases start 'foo bar'" '' "Branch name 'foo bar' cannot contain spaces." 1
