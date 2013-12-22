#!/bin/bash

#/**
#* <pre>
#* Feature: Create a valid topic.
#*
#* Scenario: 'git convey topics start task-foo' from master
#* Given 'git-convey' is installed
#* And I am on the 'master' branch'
#* When I type 'git convey topics start task-foo'
#* Then text "Switched to branch 'task-foo'" is printed to stdout
#* And branch 'task-foo' is created in the local and origin repository.
#* And the script exits with exit code 0. 
#* </pre>
#*/

source `dirname $0`/../../lib/cli-lib.sh

test_start 'git convey topics start task-foo' "Switched to branch 'task-foo'" '' 0
