#!/bin/bash

#/**
#* <pre>
#* Feature: Report bad resources/global task.
#*
#* Scenario: 'git convey foo'
#* Given 'git-convey' is installed
#* When I type 'git convey foo'
#* Then text is printed to stdout starting with 'usage: git convey <resource|global task>'
#* And text is printed to stderr starting with "Unknown task 'foo'."
#* And the script exits with exit code 1.
#* </pre>
#*/

source `dirname $0`/lib/cli-lib.sh

test_output "git convey foo" "usage: git convey <resource|global task>" "Unknown resource: 'foo'." 1
