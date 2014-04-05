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
    local RESOURCE="$1"; shift
    local RESOURCE_NAME="$1"; shift

    local ISSUE_NUMBER=${RESOURCE_NAME:0:$((`expr index "$RESOURCE_NAME" '-'` - 1))}
    set_github_origin_data

    local ISSUE_JSON=`curl -s -u $GITHUB_AUTH_TOKEN:x-oauth-basic https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/issues/$ISSUE_NUMBER`
    local RESULT=$?
    if [ $RESULT -ne 0 ]; then
	echo "Could not contact github to verify task. Bailing out." >&2
	exit 2
    fi
    # Now we need to extract the status and verify the issue is open.

    local PHP_BIN=$DFS_HOME/third-party/php5/runnable/bin/php
    local MESSAGE=`echo $ISSUE_JSON | $PHP_BIN -r '$handle = fopen ("php://stdin","r"); $json = stream_get_contents($handle); $data = json_decode($json, true); print $data["message"];'`
    if [ "$MESSAGE" == 'Not Found' ]; then
	echo "GitHub reports invalid issue number at $GITHUB_URL." >&2
	exit 1
    fi
    # Else, assume we have an issue
    local STATE=`echo $ISSUE_JSON | $PHP_BIN -r '$handle = fopen ("php://stdin","r"); $json = stream_get_contents($handle); $data = json_decode($json, true); print $data["state"];'`
    case "$STATE" in
	open|OPEN)
	    echo "Issue is verified at $GITHUB_URL."
	    ;;
	closed|CLOSED)
	    echo "Issue has been closed; cannot start topic branch." >&2
	    exit 1
	    ;;
	*)
	    echo "Found issue, but is in unknown state '$STATE'. Cowardly bailing out." >&2
	    exit 2;;
    esac

    return 0
}

function create_repo() {
    local GITHUB_OWNER="$1"; shift
    local REPO_NAME="$1"; shift

    local CURL_COMMAND="curl -X POST -s -u $GITHUB_AUTH_TOKEN:x-oauth-basic https://api.github.com/orgs/$GITHUB_OWNER/repos -d @-"
    local TMP_FILE="/tmp/$RANDOM"
    cat <<EOF | $CURL_COMMAND > $TMP_FILE
{
  "name": "$REPO_NAME"
}
EOF
    local RESULT=$?
    if [ $RESULT -ne 0 ]; then
	echo "Could not contact github." >&2
	return 2
    fi

    JSON=`cat $TMP_FILE`
    if [ `echo $JSON | grep '"name"' | wc -l` -ne 1 ]; then
	local PHP_BIN=$DFS_HOME/third-party/php5/runnable/bin/php
	local MESSAGE=`echo $JSON | $PHP_BIN -r '$handle = fopen ("php://stdin","r"); $json = stream_get_contents($handle); $data = json_decode($json, true); print $data["message"];'`
	echo "Could not create repo: $MESSAGE" >&2
	return 1
    fi

    return 0
}

function delete_repo() {
    local GITHUB_OWNER="$1"; shift
    local REPO_NAME="$1"; shift

    DELETE_JSON=`curl -X DELETE -s -u $GITHUB_AUTH_TOKEN:x-oauth-basic https://api.github.com/repos/$GITHUB_OWNER/$REPO_NAME`
    local RESULT=$?
    if [ $RESULT -ne 0 ]; then
	echo "Could not contact github. Bailing out." >&2
	exit 2
    fi
}
