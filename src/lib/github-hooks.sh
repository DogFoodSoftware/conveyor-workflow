# /**
# * <div id="Implementation" class="grid_12 blurbSummary">
# * <div class="blurbTitle">Implementation</div>

# * <div class="subHeader"><span><code>check_issue_exists()</code></span><div>
# * <div class="p">
# *   TODO: Make configurable; single branch or multi-branch. Default is multi.
# *   For github, the only relevant part of the issue is the issue
# *   number. Topics are not necesarrily exclusive to one branch, however, and
# *   the rest of the resource name is relevant for establishing the unique
# *   resource. In other words, the relationship between issue and topics is
# *   many-to-one.
# * </div>
# */
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

#* <div class="subHeader"><span><code>does_github_repo_exist()</code></span></div>
#* <div class="p">
#*   Tests whether the provided string appears to be a GitHub URL.
#* </div>
function does_repo_exist() {
    local REPO_NAME="$1"; shift

    local GITHUB_RESPONSE=`curl -s -u $GITHUB_AUTH_TOKEN:x-oauth-basic https://api.github.com/repos/$REPO_NAME`
    local RESULT=$?
    if [ $RESULT -ne 0 ]; then
	echo "Could not contact github to verify repo available. Bailing out." >&2
	exit 2
    fi
    [ `echo $GITHUB_RESPONSE | grep '"id":' | wc -l` -eq 1 ]
}

# /**
# * <div class="subHeader"><span><code>create_repo()</code></span><div>
# * <div class="p">
# * </div>
# */
function create_repo() {
    local REPO_NAME="$1"; shift
# For GitHub, the repo name comes in two parts which we need to break up
# because the cannonical repo URL doesn't directly map to how you reference
# the repo in the API.
    local GITHUB_OWNER=`echo "$REPO_NAME" | cut -d'/' -f 1`
    local REPO_NAME=`echo "$REPO_NAME" | cut -d'/' -f 2`

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
    local REPO_NAME="$1"; shift

    DELETE_JSON=`curl -X DELETE -s -u $GITHUB_AUTH_TOKEN:x-oauth-basic https://api.github.com/repos/$REPO_NAME`
    local RESULT=$?
    if [ $RESULT -ne 0 ]; then
	echo "Could not contact github. Bailing out." >&2
	exit 2
    fi
}

function get_login() {
    local FORCE_REFRESH=1 # bash false
    if [ $# -ge 1 ]; then
	FORCE_REFRESH="$1"; shift
    fi

    # This is an internal function, so we trust the arguments.
    if [ $FORCE_REFRESH -eq 0 ] || [ ! -f $HOME/.conveyor-workflow/github-login ]; then
	local USER_JSON=`curl -s -u $GITHUB_AUTH_TOKEN:x-oauth-basic https://api.github.com/user`
	local RESULT=$?
	if [ $RESULT -ne 0 ]; then
	    echo "ERROR: Could not contact github to determine user login." >&2
	    exit 2
	else
	    local PHP_BIN=$DFS_HOME/third-party/php5/runnable/bin/php
	    GITHUB_LOGIN=`echo $USER_JSON | $PHP_BIN -r '$handle = fopen ("php://stdin","r"); $json = stream_get_contents($handle); $data = json_decode($json, true); print $data["login"];'`	    
	    echo "GITHUB_LOGIN=$GITHUB_LOGIN" > $HOME/.conveyor-workflow/github-login
	fi # github connection check
    elif [ -f $HOME/.conveyor-workflow/github-login ]; then
	source $HOME/.conveyor-workflow/github-login
    fi # forced refresh check
}

function set_assignee() {
    local RESOURCE_NAME="$1"; shift
    
    local ISSUE_NUMBER=`echo $RESOURCE_NAME | cut -d'-' -f1`

    set_github_origin_data
    get_login

    if [ x"$GITHUB_LOGIN" != x"" ]; then
	local CURL_COMMAND="curl -X PATCH -s -u $GITHUB_AUTH_TOKEN:x-oauth-basic https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/issues/$ISSUE_NUMBER -d @-"
	local TMP_FILE="/tmp/$RANDOM"
	cat <<EOF | $CURL_COMMAND > $TMP_FILE
{
  "assignee": "$GITHUB_LOGIN"
}
EOF
	local RESULT=$?
	if [ $RESULT -ne 0 ]; then
	    echo "ERROR: Could not contact github, please assign issue manually." >&2
	    exit 2
	fi
	local JSON=`cat $TMP_FILE`
	rm $TMP_FILE
	local PHP_BIN=$DFS_HOME/third-party/php5/runnable/bin/php
	local ASSIGNEE=`echo $JSON | $PHP_BIN -r '$handle = fopen ("php://stdin","r"); $json = stream_get_contents($handle); $data = json_decode($json, true); print $data["assignee"]["login"];'`
	if [ x"$ASSIGNEE" == x"$GITHUB_LOGIN" ]; then
	    echo "Assigned PR #${ISSUE_NUMBER} to $GITHUB_LOGIN."
	else
	    echo $JSON >&2
	    local MESSAGE=`echo $JSON | $PHP_BIN -r '$handle = fopen ("php://stdin","r"); $json = stream_get_contents($handle); $data = json_decode($json, true); print $data["message"];'`
	    echo "ERROR: Assignment seems to have failed. GitHub message: $MESSAGE." >&2
	    exit 2
	fi
    else # GITHUB_LOGIN not set
	echo "Could not set assignee; please update issue manually." >&2
	exit 2
    fi # GITHUB_LOGIN successfully set check
}

function create_issue() {
    local GITHUB_REPO="$1"; shift
    local TITLE="$1"; shift

    local CURL_COMMAND="curl -X POST -s -u $GITHUB_AUTH_TOKEN:x-oauth-basic https://api.github.com/repos/$GITHUB_REPO/issues -d @-"
    local TMP_FILE="/tmp/$RANDOM"
    cat <<EOF | $CURL_COMMAND > $TMP_FILE
{
  "title": "$TITLE"
}
EOF
    local RESULT=$?
    if [ $RESULT -ne 0 ]; then
	echo "Could not contact github." >&2
	return 2
    fi

    JSON=`cat $TMP_FILE`
    if [ `echo $JSON | grep '"title"' | wc -l` -ne 1 ]; then
	local PHP_BIN=$DFS_HOME/third-party/php5/runnable/bin/php
	local MESSAGE=`echo $JSON | $PHP_BIN -r '$handle = fopen ("php://stdin","r"); $json = stream_get_contents($handle); $data = json_decode($json, true); print $data["message"];'`
	echo "Could not create issue: $MESSAGE" >&2
	return 1
    fi
}

# /**
# * </div><!-- #Implementation -->
# */
