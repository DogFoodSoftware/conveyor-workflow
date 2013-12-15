#!/bin/bash

#/**
#* <pre>
#* Feature: Commandline help for the git-convey topics actions.
#*
#* Scenario Outline: git-convey action help
#* Given 'git-convey' is installed
#* When I type 'git convey <action help>'
#* Then significant text is printed to stdout 
#* And the script exits with exit code 0.
#*
#* Example:
#* | action help            |
#* | topics help list       |
#* | help topics list       |
#* | topics help start      |
#* | help topics start      |
#* | topics help join       |
#* | help topics join       |
#* | topics help commit     |
#* | help topics commit     |
#* | topics help done       |
#* | help topics done       |
#* | topics help delete     |
#* | help topics delete     |
#* | topics help help       |
#* | help topics help       |
#* | releases help list     |
#* | help releases list     |
#* | releases help start    |
#* | help releases start    |
#* | releases help checkout |
#* | help releases checkout |
#* | releases help delete   |
#* | help releases delete   |
#* | releases help promote  |
#* | help releases promote  |
#* | releases help sunset   |
#* | help releases sunset   |
#* | releases help help     |
#* | help releases help     |
#* </pre>
#*/

source `dirname $0`/../lib/cli-lib.sh

test_significant_output "git convey help topics list"
test_significant_output "git convey topics help list"
test_significant_output "git convey help topics start"
test_significant_output "git convey topics help start"
test_significant_output "git convey help topics join"
test_significant_output "git convey topics help join"
test_significant_output "git convey help topics commit"
test_significant_output "git convey topics help commit"
test_significant_output "git convey help topics done"
test_significant_output "git convey topics help done"
test_significant_output "git convey help topics delete"
test_significant_output "git convey topics help delete"
test_significant_output "git convey help topics help"
test_significant_output "git convey topics help help"

test_significant_output "git convey releases help list"
test_significant_output "git convey releases help list"
test_significant_output "git convey releases help start"
test_significant_output "git convey releases help start"
test_significant_output "git convey releases help checkout"
test_significant_output "git convey releases help checkout"
test_significant_output "git convey releases help delete"
test_significant_output "git convey releases help delete"
test_significant_output "git convey releases help promote"
test_significant_output "git convey releases help promote"
test_significant_output "git convey releases help sunset"
test_significant_output "git convey releases help sunset"
test_significant_output "git convey releases help help"
test_significant_output "git convey releases help help"
