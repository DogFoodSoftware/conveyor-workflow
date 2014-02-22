#!/bin/bash

#/**
#* <pre>
#* Feature: Report lack of local topic on publish.
#*
#* Scenario: 'git convey topics publish no-local-topic'
#* Given 'git-convey' is installed
#*   And their is a topic 'no-local-topic' on origin
#*   And topic 'no-local-topic' does not exist locally
#* When I type 'git convey topics publish no-local-topic'
#* Then no text is printed to stdout
#*   And text is printed to stderr starting with "No such topic 'no-local-topic' exists locally."
#*   And the script exits with exit code 1. 
#* </pre>
#*/

source `dirname $0`/../../lib/cli-lib.sh
setup_path `dirname $0`/../../../runnable
source `dirname $0`/../../lib/environment-lib.sh
source `dirname $0`/../../lib/start-lib.sh
init_test_environment `dirname $0`/../../.. `basename $0`
cd $WORKING_REPO_PATH

git convey start no-local-topic
test_output "git convey topics publish no-local-topic" '' "No such topic 'no-colal-topic' exists locally." 1
