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

    REPO_BASE="$(git rev-parse --show-toplevel)"

    ISSUE_NUMBER=${RESOURCE_NAME:0:`expr index "$RESOURCE_NAME" '-'`}
    # We need the github owner and repo, which we can get by dissectin the
    # origin url.
    GITHUB_OWNER=`eval echo \`git config --get remote.origin.url\` | cut -d/ -f4`
    GITHUB_REPO=`eval echo \`git config --get remote.origin.url\` | cut -d/ -f5`
    # The URL includes the '.git', which isn't part of the name but an
    # underlying git convention. We want to drop it for the API calls.
    GITHUB_REPO=${GITHUB_REPO:0:$((${#GITHUB_REPO} - 4))}

    ISSUE_JSON=`curl -u $GITHUB_AUTH_TOKEN:x-oauth-basic https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/issues/$ISSUE_NUMBER`
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
	echo "Could not contact github to verify task. Bailing out." >&2
	exit 2
    fi
    # Now we need to extract the status and verify the issue is open.
    echo "Implement me." >&2
    exit 2
}
