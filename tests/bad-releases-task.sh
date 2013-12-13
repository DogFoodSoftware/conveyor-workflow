#!/bin/bash

#/**
#* <pre>
#* Feature: Report bad releases task.
#*
#* Scenario: 'git convey releases foo'
#* Given 'git-convey' is installed
#* When I type 'git convey releases foo'
#* Then text is printed to stdout starting with 'usage: git convey releases'
#* And text is printed to stderr starting with "Unknown task: 'foo'."
#* And the script exits with exit code 1.
#* </pre>
#*/

source `dirname $0`/lib/cli-lib.sh

test_output "git convey releases foo" "usage: git convey releases" "Unknown task: 'foo'." 1
