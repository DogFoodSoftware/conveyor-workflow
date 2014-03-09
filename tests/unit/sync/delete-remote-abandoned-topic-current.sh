#/**
#* <pre>
#* Feature: sync
#*
#* Scenario: Sync discovers current topic abandoned.
#*
#* Given 'conveyor-workflow' is installed
#*   And I have cloned a conveyor-workflow repository
#*   And I have started topic '1-foo' and published changes
#*   And I am currently on 'topics-1-foo'
#*   And '1-foo' has been deleted, but not merged into master
#* When I type 'con topics sync'
#* Then I remain on the 'topics-1-foo' branch
#*   And the local topic branch remains intact
#*   And "Current topic '1-foo' abandoned on origin. Local branch left intact. Please abandon or re-start." is printed to stdout
#*   And the script exits with 0.
#* </pre>
#*/
TEST_BASE=`dirname $0`/../..
source $TEST_BASE/lib/cli-lib.sh
setup_path $TEST_BASE/../runnable
source $TEST_BASE/lib/environment-lib.sh
init_test_environment `basename $0`
cd $WORKING_REPO_PATH || (echo "ERROR: Did not find working repo."; exit 2)

git checkout -q master
con topics start --checkout 1-foo >/dev/null
touch 'foo'
git add foo > /dev/null
con topics commit -m "added file foo" >/dev/null
con topics publish >/dev/null

cd $ORIGIN_REPO_PATH
git checkout -q master
git branch -q -D topics-1-foo

cd $WORKING_REPO_PATH
test_output 'con sync' "Current topic '1-foo' abandoned on origin. Local branch left intact. Please abandon or re-start." '' 0
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
if [ x"$CURRENT_BRANCH" != x'topics-1-foo' ]; then
    echo "ERROR: Expected to be on branch 'topics-1-foo' after sync, but instead on '$CURRENT_BRANCH'."
fi
