#!/bin/bash

#/**
#* <pre>
#* Feature: Global git-convey command line help.
#*
#* Scenario: 'git convey help'
#* Given 'git-convey' is installed
#* When I type 'git convey help'
#* Then text is printed to stdout starting with 'usage: git convey <resource|global task>'
#* And the script exits with exit code 0.
#* </pre>
#*/

source `dirname $0`/lib/help-lib.sh

test_help "git convey help" "usage: git convey <resource|global task>"

