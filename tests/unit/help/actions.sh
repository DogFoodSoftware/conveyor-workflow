#!/bin/bash

#/**
#* <pre>
#* Feature: Commandline help for the conveyor-workflow topics actions.
#*
#* Scenario Outline: conveyor-workflow action help
#* Given 'conveyor-workflow' is installed
#* When I type 'con <action help>'
#* Then significant text is printed to stdout 
#* And the script exits with exit code 0.
#*
#* Example:
#* | action help            |
#* | topics help list       |
#* | help topics list       |
#* | topics help start      |
#* | help topics start      |
#* | topics help checkout   |
#* | help topics checkout   |
#* | topics help commit     |
#* | help topics commit     |
#* | topics help submit     |
#* | help topics submit     |
#* | topics help abandon    |
#* | help topics abandon    |
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
#* | releases help archive  |
#* | help releases archive  |
#* | releases help help     |
#* | help releases help     |
#* </pre>
#*/

TEST_BASE=`dirname $0`/../..
source $TEST_BASE/lib/cli-lib.sh

test_significant_output "con help topics list"
test_significant_output "con topics help list"
test_significant_output "con help topics start"
test_significant_output "con topics help start"
test_significant_output "con help topics checkout"
test_significant_output "con topics help checkout"
test_significant_output "con help topics commit"
test_significant_output "con topics help commit"
test_significant_output "con help topics submit"
test_significant_output "con topics help submit"
test_significant_output "con help topics abandon"
test_significant_output "con topics help abandon"
test_significant_output "con help topics delete"
test_significant_output "con topics help delete"
test_significant_output "con help topics help"
test_significant_output "con topics help help"

test_significant_output "con help releases list"
test_significant_output "con releases help list"
test_significant_output "con help releases start"
test_significant_output "con releases help start"
test_significant_output "con help releases checkout"
test_significant_output "con releases help checkout"
test_significant_output "con help releases delete"
test_significant_output "con releases help delete"
test_significant_output "con help releases archive"
test_significant_output "con releases help archive"
test_significant_output "con releases help help"
