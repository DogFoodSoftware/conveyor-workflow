# /**
# * <div id="Implementation" class="grid_12 blurbSummary">
# * <div class="blurbTitle">Implementation</div>
# */
source $HOME/.conveyor/config
source $CONVEYOR_HOME/workflow/runnable/lib/resty
source $CONVEYOR_HOME/workflow/runnable/lib/rest-lib.sh
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
# */
function check_issue_exists_for() {
    local RESOURCE="$1"; shift
    local RESOURCE_NAME="$1"; shift

    local ISSUE_NUMBER=${RESOURCE_NAME:0:$((`expr index "$RESOURCE_NAME" '-'` - 1))}
    set_github_origin_data

    local STATE=`github_query '["state"]' GET /repos/$GITHUB_OWNER/$GITHUB_REPO/issues/$ISSUE_NUMBER 2> /dev/null`
    local RESULT=$?
    if [ `last_rest_status` -eq 404 ]; then
	echo "GitHub reports invalid issue number at $GITHUB_URL." >&2
	exit 1
    elif [ $RESULT -ne 0 ]; then
	echo "ERROR: failed to retrive issue. ($RESULT)" >&2
	exit 2
    fi
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

    # Redirect to hide standard failure messages if repo does not exist.
    local REPO_ID=`github_query '["id"]' GET /repos/$REPO_NAME 2> /dev/null`
    [ x"$REPO_ID" != x"" ]
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

    github_api POST /orgs/$GITHUB_OWNER/repos "{ \"name\":\"$REPO_NAME\" }" >/dev/null
    return $?
}

function delete_repo() {
    local REPO_NAME="$1"; shift

    github_api DELETE "/repos/$REPO_NAME"
    return $?
}

function get_login() {
    local FORCE_REFRESH=1 # bash false
    if [ $# -ge 1 ]; then
	FORCE_REFRESH="$1"; shift
    fi

    # This is an internal function, so we trust the arguments.
    if [ $FORCE_REFRESH -eq 0 ] || [ ! -f $HOME/.conveyor-workflow/github-login ]; then
	GITHUB_LOGIN=`github_query '["login"]' GET /user`
	local QUERY_STATUS=$?
	if [ $QUERY_STATUS -eq 0 ]; then
	    echo "GITHUB_LOGIN=$GITHUB_LOGIN" > $HOME/.conveyor-workflow/github-login
	fi
	return $QUERY_STATUS
    elif [ -f $HOME/.conveyor-workflow/github-login ]; then
	source $HOME/.conveyor-workflow/github-login
    fi # forced refresh check
}

# Attempts self-verification.
function set_assignee() {
    local ISSUE_NUMBER="$1"; shift
    set_github_origin_data
    if [ $# -gt 0 ]; then
	local GITHUB_ACCOUNT_TO_ASSIGN="$1"; shift
    else
	get_login
	local GITHUB_ACCOUNT_TO_ASSIGN="$GITHUB_LOGIN"
    fi

    if [ x"$GITHUB_ACCOUNT_TO_ASSIGN" != x"" ]; then
	local CURL_COMMAND="curl -X PATCH -s -u $GITHUB_AUTH_TOKEN:x-oauth-basic https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/issues/$ISSUE_NUMBER -d @-"
	local TMP_FILE="/tmp/$RANDOM"
	cat <<EOF | $CURL_COMMAND > $TMP_FILE
{
  "assignee": "$GITHUB_ACCOUNT_TO_ASSIGN"
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
	if [ x"$ASSIGNEE" == x"$GITHUB_ACCOUNT_TO_ASSIGN" ]; then
	    echo "Assigned PR #${ISSUE_NUMBER} to $GITHUB_ACCOUNT_TO_ASSIGN."
	else
	    local MESSAGE=`echo $JSON | $PHP_BIN -r '$handle = fopen ("php://stdin","r"); $json = stream_get_contents($handle); $data = json_decode($json, true); print $data["message"];'`
	    echo "ERROR: Assignment seems to have failed. GitHub message: $MESSAGE." >&2
	    exit 2
	fi
    else # GITHUB_LOGIN not set
	echo "No assignee could be determined; please update issue manually." >&2
	exit 2
    fi # GITHUB_LOGIN successfully set check
}

function get_assignee() {
    local RESOURCE_NAME="$1"; shift
    local ISSUE_NUMBER=`echo $RESOURCE_NAME | cut -d'-' -f1`
    set_github_origin_data    

    local ISSUE_JSON=`curl -s -u $GITHUB_AUTH_TOKEN:x-oauth-basic https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/issues/$ISSUE_NUMBER`
    local RESULT=$?
    if [ $RESULT -ne 0 ]; then
	echo "ERROR: Could not contact github, please assign issue manually." >&2
	return 2
    fi
    local PHP_BIN=$DFS_HOME/third-party/php5/runnable/bin/php
    local ASSIGNEE=`echo $ISSUE_JSON | $PHP_BIN -r '$handle = fopen ("php://stdin","r"); $json = stream_get_contents($handle); $data = json_decode($json, true); print $data["assignee"]["login"];'`
    # TODO: should check for warning.
    echo "$ASSIGNEE"
}

function clear_assignee() {
    local RESOURCE_NAME="$1"; shift
    local ISSUE_NUMBER=`echo $RESOURCE_NAME | cut -d'-' -f1`
    local ASSIGNEE=`get_assignee $RESOURCE_NAME`
    local RESULT=$?
    if [ $RESULT -ne 0 ]; then
	exit $RESULT
    fi
    
    set_github_origin_data
    get_login
    
    if [ x"$ASSIGNEE" != x"$GITHUB_LOGIN" ]; then
	return 1 # bash for false / failure
    else
	local CURL_COMMAND="curl -X PATCH -s -u $GITHUB_AUTH_TOKEN:x-oauth-basic https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/issues/$ISSUE_NUMBER -d @-"
	local TMP_FILE="/tmp/$RANDOM"
	cat <<EOF | $CURL_COMMAND > $TMP_FILE
{
  "assignee": ""
}
EOF
	local RESULT=$?
	if [ $RESULT -ne 0 ]; then
	    echo "ERROR: Could not contact github; clear issue assignment as necessary." >&2
	    exit 2
	fi
	local JSON=`cat $TMP_FILE`
	rm $TMP_FILE
	local PHP_BIN=$DFS_HOME/third-party/php5/runnable/bin/php
	local ASSIGNEE=`echo $JSON | $PHP_BIN -r '$handle = fopen ("php://stdin","r"); $json = stream_get_contents($handle); $data = json_decode($json, true); print $data["assignee"]["login"];'`
	if [ `echo $JSON | grep '"title"' | wc -l` -eq 1 ] && [ x"$ASSIGNEE" == x"" ]; then
	    echo "Assignment cleared for issue #${ISSUE_NUMBER}."
	    return 0
	else
	    local MESSAGE=`echo $JSON | $PHP_BIN -r '$handle = fopen ("php://stdin","r"); $json = stream_get_contents($handle); $data = json_decode($json, true); print $data["message"];'`
	    echo $JSON >&2
	    echo "ERROR: Assignment clear seems to have failed. GitHub message: $MESSAGE." >&2
	    exit 2
	fi
    fi
}

function create_issue() {
    local GITHUB_REPO="$1"; shift
    local TITLE="$1"; shift

    NUMBER=`github_query '["number"]' POST /repos/$GITHUB_REPO/issues "{\"title\": \"$TITLE\"}"`
    local API_RESULT=$?
    if [ $API_RESULT -ne 0 ]; then
	return $API_RESULT
    fi
    echo $NUMBER
}

function set_github_origin_data() {
    source $HOME/.conveyor-workflow/github
    # We need the github owner and repo, which we can get by dissectin the
    # origin url.
    GITHUB_URL=`git config --get remote.origin.url`
    GITHUB_OWNER=`echo $GITHUB_URL | cut -d/ -f4`
    GITHUB_REPO=`echo $GITHUB_URL | cut -d/ -f5`
    # The URL includes the '.git', which isn't part of the name but an
    # underlying git convention. We want to drop it for the API calls.
    GITHUB_REPO=${GITHUB_REPO:0:$((${#GITHUB_REPO} - 4))}
}

# /**
# * </div><!-- #Implementation -->
# */
