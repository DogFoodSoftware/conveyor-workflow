#!/bin/bash

#/**
#* <pre>
#* Feature: Report bad topics branch names.
#*
#* Scenario: 'git convey topics start "foo bar"'
#* Given 'git-convey' is installed
#* When I type 'git convey topics start "foo bar"'
#* Then no text is printed to stdout
#* And text is printed to stderr starting with "Branch name 'foo bar' cannot contain spaces."
#* And the script exits with exit code 1. 
#* </pre>
#*/

set -e

source `dirname $0`/../../lib/cli-lib.sh
setup_path `dirname $0`/../../../runnable
source `dirname $0`/../../lib/environment-lib.sh
source `dirname $0`/../../lib/start-lib.sh
init_test_environment `dirname $0`/../../.. `basename $0`
cd $WORKING_REPO_PATH

test_output "git convey topics start 'foo bar'" '' "Resource names cannot contain spaces; got 'foo bar'." 1
