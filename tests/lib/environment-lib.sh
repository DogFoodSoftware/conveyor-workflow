export GIT_CONVEY_HOME=/home/user/playground/git-convey
export GIT_CONVEY_TEST_DIR=/home/user/playground/git-convey/data/test

function init_test_environment() {
    cd $GIT_CONVEY_HOME 2>/dev/null || (echo "Did not find standard git-convey install." >&2; exit 2)
    mkdir -p data
    cd data
    rm -rf test
    mkdir test
    cd test
    git convey init origin > /dev/null # TODO: we should support '-q/--quiet'
}

function populate_test_environment() {
    cd $GIT_CONVEY_TEST_DIR 2>/dev/null || (echo "Did not find standard git-convey data dir." >&2; exit 2)
    git clone --quiet file:///$GIT_CONVEY_TEST_DIR/origin.git staging
    cd staging
    # Notice we don't use the git-convey porcelain here as we don't want to
    # use what we're trying to test. I guess ideally we wouldn't use git
    # porcelain either, but git plumbing is tedious.
    git checkout --quiet -b task-add-foo
    echo "foo" > foo
    git add foo
    git commit --quiet -am "added foo"
    git push --quiet origin task-add-foo
    git checkout --quiet master
    git checkout --quiet -b task-add-bar
    echo "bar" > bar
    git add bar
    git commit --quiet -am "added bar"
    git push --quiet origin task-add-bar
    cd ..
    rm -rf staging
}
