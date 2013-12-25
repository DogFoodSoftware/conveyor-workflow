export GIT_CONVEY_HOME=/home/user/playground/git-convey

function init_test_environment() {
    cd $GIT_CONVEY_HOME 2>/dev/null || (echo "Did not find standard git-convey install." >&2; exit 2)
    mkdir -p data
    cd data
    rm -rf test
    mkdir test
    cd test
    git convey init origin.git
}

function populate_test_environment() {
    cd $GIT_CONVEY_HOME/data 2>/dev/null || (echo "Did not find standard git-convey data dir." >&2; exit 2)
    git clone file:///$GIT_CONVEY_HOME/origin.git staging
    cd staging
    # Notice we don't use the git-convey porcelain here as we don't want to
    # use what we're trying to test. I guess ideally we wouldn't use git
    # porcelain either, but that's tedious.
    git checkout -b task-add-foo
    echo "foo" > foo
    git add foo
    git commit -am "added foo"
    git push origin task-add-foo
    git checkout master
    git checkout -b task-add-bar
    echo "bar" > bar
    git add bar
    git commit -am "added bar"
    git push origin task-add-bar
    cd ..
    rm -rf staging
}
