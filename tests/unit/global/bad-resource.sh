#!/bin/bash

#/**
#* <pre>
#* Feature: Report bad resources/global action.
#*
#* Scenario: 'con foo'
#* Given 'conveyor-workflow' is installed
#* When I type 'con foo'
#* Then text is printed to stdout starting with 'usage: con <resource|global action>'
#* And text is printed to stderr starting with "Unknown action 'foo'."
#* And the script exits with exit code 1.
#* </pre>
#*/

source `dirname $0`/../../lib/cli-lib.sh

test_output "con foo" "usage: con <resource|global action>" "Unknown resource: 'foo'." 1
