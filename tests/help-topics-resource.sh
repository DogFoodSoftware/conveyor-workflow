#!/bin/bash

#/**
#* <pre>
#* Feature: Topics resource command line help.
#*
#* Scenario: 'git convey topics help'
#* Given 'git-convey' is installed
#* When I type 'git convey topics help'
#* Then text is printed to stdout starting with 'usage: git convey topics'
#* And the script exits with exit code 0.
#*
#* Scenario: 'git convey help topics'
#* Given 'git-convey' is installed
#* When I type 'git convey help topics'
#* Then text is printed to stdout starting with 'usage: git convey topics'
#* And the script exits with exit code 0.
#* </pre>
#*/

source `dirname $0`/lib/help-lib.sh

test_help "git convey help topics" "usage: git convey topics"
test_help "git convey topics help" "usage: git convey topics"
