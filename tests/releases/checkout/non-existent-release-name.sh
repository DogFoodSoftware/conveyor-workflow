#!/bin/bash

#/**
#* <pre>
#* Feature: Report bad release names on join.
#*
#* Scenario: 'git convey releases join bad-release'
#* Given 'git-convey' is installed
#*   And their is no release 'foo-bar'
#* When I type 'git convey releases checkout bad-release'
#* Then no text is printed to stdout
#*   And text is printed to stderr starting with "No such release 'bad-release'."
#*   And the script exits with exit code 1. 
#* </pre>
#*/

source `dirname $0`/../../lib/cli-lib.sh
setup_path `dirname $0`/../../../runnable
source `dirname $0`/../../lib/environment-lib.sh
source `dirname $0`/../../lib/start-lib.sh
init_test_environment `dirname $0`/../../.. `basename $0`
cd $WORKING_REPO_PATH

test_output "git convey releases checkout bad-release" '' "No such release 'bad-release' exists on origin." 1
