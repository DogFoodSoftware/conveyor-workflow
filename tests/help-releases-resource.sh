#!/bin/bash

#/**
#* <pre>
#* Feature: Releases resource command line help.
#*
#* Scenario: 'git convey releases help'
#* Given 'git-convey' is installed
#* When I type 'git convey releases help'
#* Then text is printed to stdout starting with 'usage: git convey release'
#* And no text is printed to stdeer
#* And the script exits with exit code 0.
#*
#* Scenario: 'git convey help releases'
#* Given 'git-convey' is installed
#* When I type 'git convey help releases'
#* Then text is printed to stdout starting with 'usage: git convey release'
#* And no text is printed to stdeer
#* And the script exits with exit code 0.
#* </pre>
#*/

source `dirname $0`/lib/cli-lib.sh

test_help "git convey help releases" "usage: git convey releases"
test_help "git convey releases help" "usage: git convey releases"
