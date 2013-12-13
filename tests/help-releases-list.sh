#!/bin/bash

#/**
#* <pre>
#* Feature: Commandline help for the git-convey 'releases list' command.
#*
#* Scenario: 'git convey releases list help'
#* Given 'git-convey' is installed
#* When I type 'git convey releases list help'
#* Then text is printed to stdout starting with 'Lists the topic branches'
#* And the script exits with exit code 0.
#*
#* Scenario: 'git convey help releases list'
#* Given 'git-convey' is installed
#* When I type 'git convey help releases list'
#* Then text is printed to stdout starting with 'Lists the topic branches'
#* And the script exits with exit code 0.
#* </pre>
#*/

source `dirname $0`/lib/help-lib.sh

test_help "git convey help releases list" 'Lists the release branches'
test_help "git convey releases help list" 'Lists the release branches'
