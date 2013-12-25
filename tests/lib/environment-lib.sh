export GIT_CONVEY_HOME=/home/user/playground/git-convey

function init_test_environment() {
    cd $GIT_CONVEY_HOME 2>/dev/null || (echo "Did not find standard git-convey install." >&2; exit 2)
    mkdir -p data
    cd data
    rm -rf test
    mkdir test
    cd test
    # set up the 'origin' environment
    mkdir origin.git
    cd origin.git
    git init --bare . >/dev/null || (echo "Could not create bare repository." >&2; exit 2)
}

function populate_test_environment() {
    cd $GIT_CONVEY_HOME/data 2>/dev/null || (echo "Did not find standard git-convey data dir." >&2; exit 2)
    git clone file:///$GIT_CONVEY_HOME/origin.git staging
    cd staging
    git 
    echo "foo" > foo
    git add foo
    git commit -am "added foo"
    git push origin master
    git checkout -b task-add-bar
    echo "bar" > bar
    git add bar
    git commit -am "added bar"
    git push origin m
}
