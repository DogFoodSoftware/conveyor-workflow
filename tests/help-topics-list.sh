#!/bin/bash

#/**
#* <pre>
#* Feature: Commandline help for the git-convey 'topics list' command.
#*
#* Scenario: 'git convey topics list help'
#* Given 'git-convey' is installed
#* When I type 'git convey topics list help'
#* Then text is printed to stdout starting with 'Lists the topic branches'
#* And the script exits with exit code 0.
#*
#* Scenario: 'git convey help topics list'
#* Given 'git-convey' is installed
#* When I type 'git convey help topics list'
#* Then text is printed to stdout starting with 'Lists the topic branches'
#* And the script exits with exit code 0.
#* </pre>
#*/

source `dirname $0`/lib/cli-lib.sh

test_help "git convey help topics list" 'Lists the topic branches'
test_help "git convey topics help list" 'Lists the topic branches'

