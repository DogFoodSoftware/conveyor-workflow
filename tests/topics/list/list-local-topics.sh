#!/bin/bash

#/**
#* <pre>
#* Feature: List current local topics.
#*
#* Scenario: 'git convey topics list' from any branch
#* Given 'git-convey' is installed
#* And a pre-populated test repository
#* And I am on the 'master' branch'
#* When I type 'git convey list'
#* Then lines 'add-bar' and 'add-foo' are printed to stdout
#* And the script exits with exit code 0.
#* </pre>
#*/

set -e

source `dirname $0`/../../lib/cli-lib.sh
setup_path `dirname $0`/../../../runnable
source `dirname $0`/../../lib/environment-lib.sh
source `dirname $0`/../../lib/start-lib.sh
init_test_environment `dirname $0`/../../.. `basename $0`
cd $WORKING_REPO_PATH

populate_test_environment

git checkout -q master

test_output 'git convey topics' "  add-bar
  add-foo" '' 0
test_output 'git convey topics list' "  add-bar
  add-foo" '' 0
