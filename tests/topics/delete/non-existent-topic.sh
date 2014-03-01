#!/bin/bash

#/**
#* <pre>
#* Feature: Report bad topics names on delete.
#*
#* Scenario: 'git convey topics delete bad-topic'
#* Given 'git-convey' is installed
#*   And their is no topic 'bad-topic'
#* When I type 'git convey topics delete bad-topic'
#* Then no text is printed to stdout
#*   And text is printed to stderr starting with "No such topic 'bad-topic' exists on origin."
#*   And the script exits with exit code 1. 
#* </pre>
#*/

source `dirname $0`/../../lib/cli-lib.sh
setup_path `dirname $0`/../../../runnable
source `dirname $0`/../../lib/environment-lib.sh
source `dirname $0`/../../lib/start-lib.sh
init_test_environment `dirname $0`/../../.. `basename $0`
cd $WORKING_REPO_PATH

test_output "git convey topics delete bad-topic" '' "Could not find topic 'bad-topic' in local repository." 1