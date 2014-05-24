#!/bin/bash

#/**
#* <pre>
#* Feature: Report bad resources/global action.
#*
#* Scenario: 'con foo'
#* Given 'conveyor-workflow' is installed
#*   And 'topics' is set as the implied resource
#* When I type 'con foo'
#* Then text is printed to stdout starting with 'usage: con <resource|global action>'
#* And text is printed to stderr starting with "ERROR: Cannot understand 'foo' as action, resource, or glabal."
#* And the script exits with exit code 1.
#* </pre>
#*/

source `dirname $0`/../../lib/cli-lib.sh

con -s topics >/dev/null
test_output "con foo" "usage: con <resource|global action>" "ERROR: Cannot understand 'foo' as action, resource, or global." 1
con -s >/dev/null
