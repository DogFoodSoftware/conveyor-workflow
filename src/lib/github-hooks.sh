# /**
# * <div class="subHeader"><span><code>check_issue_exists()</code></span><div>
# * <div class="p">
# *   TODO: Make configurable; single branch or multi-branch. Default is multi.
# *   For github, the only relevant part of the issue is the issue
# *   number. Topics are not necesarrily exclusive to one branch, however, and
# *   the rest of the resource name is relevant for establishing the unique
# *   resource. In other words, the relationship between issue and topics is
# *   many-to-one.
# * </div>
function check_issue_exists_for() {
    RESOURCE="$1"; shift
    RESOURCE_NAME="$1"; shift

    # TODO: I keep going back and forth thinking we need something like this
    # an then thinknig that user level is sufficient. If we stick with this
    # dichotomy, move it to a library.
    REPO_BASE="$(git rev-parse --show-toplevel)"
    if [ -f $REPO_BASE/.git-convey ]; then
	source $REPO_BASE/.git-convey
    elif [ -f $HOME/.git-convey ]; then
	source $HOME/.git-convey
    fi
    $ISSUE_NUMBER=${RESOURCE_NAME:0:`expr index "$RESOURCE_NAME" '-'`}

    curl -u $GITHUB_AUTH_TOKEN:x-oauth-basic https://api.github.com/repos/DogFoodSoftware/git-convey/issues/$ISSUE_NUMBER
}
