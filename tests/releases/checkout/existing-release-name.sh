#!/bin/bash

#/**
#* <pre>
#* Feature: Create a valid release.
#*
#* Scenario: 'git convey releases checkout existing-release' from master
#* Given 'git-convey' is installed
#*   And I am on the 'master' branch
#*   And there exists a release 'existing-release'
#* When I type 'git convey releases checkout existing-release'
#* Then text "Switched to release 'existing-release'." is printed to stdout
#*   And I am now on branch 'releases-existing-release'
#*   And the script exits with exit code 0.
#* </pre>
#*/

source `dirname $0`/../../lib/cli-lib.sh
setup_path `dirname $0`/../../../runnable
source `dirname $0`/../../lib/environment-lib.sh
init_test_environment `dirname $0`/../../.. `basename $0`
cd $WORKING_REPO_PATH

git checkout -q master
git convey releases start existing-release >/dev/null
if ! git checkout -q master; then
    echo "ERROR: Could not reset to master; test inconclusive."
fi
test_output 'git convey releases checkout existing-release' "Switched to release 'existing-release'." '' 0
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
if [ x"$CURRENT_BRANCH" != x'releases-existing-release' ]; then
    echo "ERROR: Expected to be on branch 'releases-existing-release' after checking out release, but instead on '$CURRENT_BRANCH'."
fi
