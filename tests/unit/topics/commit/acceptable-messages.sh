#!/bin/bash

#/**
#* <pre>
#* Feature: 'con topics commit'
#*
#* Scenario: 'con topics commit' requires message
#* Given 'conveyor-workflow' is installed
#*   And I have started work on and checkoud out task-foo
#*   And I have made changes in the working directory
#* When I type 'con topics commit'
#* Then text "Commit message required." is printed to stderr
#*   And the script exits with exit code 1.
#* </pre>
#*/

TEST_BASE=`dirname $0`/../../..
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
source $TEST_BASE/lib/start-lib.sh
init_test_environment `basename $0`
cd $WORKING_REPO_PATH

con topics start --checkout task-foo > /dev/null
touch 'foo'
git add foo
test_output 'con topics commit' '' 'Commit message required.' 1

#/**
#* <pre>
#* Feature: 'con topics commit'
#*
#* Scenario: 'con topics commit' with message
#* Given 'conveyor-workflow' is installed
#*   And I have started work on and checkoud out task-foo
#*   And I have made changes in the working directory
#* When I type 'con topics commit -m "<message>"'
#* Then the script exits with exit code 0.
#*
#* Examples:
#*  |      message     |
#*  | a message        |
#*  | do-wop           |
#*  | t's thing        |
#*  | something "neat" |
#*  | "bad grammar     |
#* </pre>
#*/

test_output 'con topics commit -m "a message"' '' '' 0
touch bar; git add bar
test_output 'con topics commit -m "do-wop"' '' '' 0
touch baz; git add baz
test_output 'con topics commit -m "t'"'"'s thing"' '' '' 0
touch wing; git add wing
test_output 'con topics commit -m '"'"'something "neat"'"'" '' '' 0
touch nut; git add nut
test_output 'con topics commit -m '"'"'"bad grammar'"'" '' '' 0
