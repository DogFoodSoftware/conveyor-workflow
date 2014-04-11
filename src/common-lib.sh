list_resources() {
    local RESOURCE="$1"; shift
    local FORMAT
    if [ x"${FLAGS_mark}" == x"${FLAGS_FALSE}" ]; then
	FORMAT='echo -n " "; echo "  %(refname:short)";'
    else
	FORMAT='if [ `git branch | grep "^*" | cut -d" " -f2 ` == %(refname:short) ]; then echo -n "*"; else echo -n " "; fi; BRANCH=%(refname:short); TOPIC=${BRANCH:$((${#RESOURCE} + 1))}; echo " $TOPIC";'
    fi
    local EVAL=`git for-each-ref --shell --format="$FORMAT" refs/heads/$RESOURCE-*`
    eval $EVAL
}

function start_branch() {
    # The 'resource' is guaranteed as the first argument by the parent
    # controller script, so it actually comes before the options.
    local RESOURCE="$1"; shift

    # Process any options
    FLAGS_PARENT="topics"
    DEFINE_boolean 'checkout' false 'Automatically checkout newly created topic branch locally.' 'c'
    FLAGS "$@" || exit $?
    eval set -- "${FLAGS_ARGV}"

    local RESOURCE_NAME="$1"; shift
    local SINGULAR_RESOURCE=`determine_singular_resource "$RESOURCE"`
    local BRANCH_NAME=`verify_branch_inputs "$RESOURCE" "$RESOURCE_NAME"`
    
    # Now we check that the branch name conforms. There's one generic test,
    # then we hand it off to the callback defined in the resource handler
    # script.
    generic_name_tests "$RESOURCE_NAME"

    # And are we going to step on existing branches?
    if has_branch_local "$BRANCH_NAME"; then
	echo "Local branch for topic '$BRANCH_NAME' already exists. Bailng out." >&2
	exit 1
    fi
    if has_branch_origin "$BRANCH_NAME"; then
	echo "Branch for topic '$BRANCH_NAME' already exists on origin. Bailing out." >&2
	exit 1
    fi

    # Now time for the issue check.
    load_hooks

    local VERIFY_MSG=''
    # The method calls 'exit', but since it's running in a backtick,
    # we have to exit ourselves.
    VERIFY_MSG=`check_issue_exists_for "$RESOURCE" "$RESOURCE_NAME"`
    local RESULT=$?
    if [ $RESULT -ne 0 ]; then
	exit $RESULT
    else # then we check assignment
	local ISSUE_NUMBER=`echo $RESOURCE_NAME | cut -d'-' -f1`
	local CURRENT_ASSIGNEE=`get_assignee $ISSUE_NUMBER`
	if [ x"$CURRENT_ASSIGNEE" != x"" ]; then
	    get_login
	    if [ x"$GITHUB_LOGIN" != x"$CURRENT_ASSIGNEE" ]; then
		echo "Issue #$ISSUE_NUMBER exists, but has been assigned to '$CURRENT_ASSIGNEE'." >&2
		exit 1
	    else
		echo "WARNING: You ($CURRENT_ASSIGNEE) are already assigned to this issue." >&2
		# But maybe they're starting a new branch, so we go on.
	    fi
	fi
    fi

    local ORIGINAL_BRANCH=`get_current_branch`
    # The name is acceptable; create the branch.
    git checkout -q -b "$BRANCH_NAME"
    local RESULT=$?
    if [ $RESULT -ne 0 ]; then
	echo "Git reported an error creating topic branch '$BRANCH_NAME'. Bailing out." >&2
	git checkout $ORIGINAL_BRANCH
	exit 3
    fi
    git push -q origin "$BRANCH_NAME"
    git checkout -q $ORIGINAL_BRANCH
    local RESULT=$?
    if [ $RESULT -ne 0 ]; then
	echo "Git reported an error pushing topic branch '$BRANCH_NAME' to origin." >&2
	echo "Deleting local topic branch and bailing out." >&2
	git branch -q -d "$BRANCH_NAME"
	exit 3
    fi
    echo -n "Created $SINGULAR_RESOURCE '$RESOURCE_NAME' on origin."
    if [ x"$VERIFY_MSG" != x"" ]; then
	echo " $VERIFY_MSG"
    else
	echo
    fi

    if [ x"$RESOURCE" == x"topics" ]; then
	set_assignee `echo $RESOURCE_NAME | cut -d'-' -f1`
    fi

    if [ $FLAGS_checkout -eq $FLAGS_FALSE ]; then
	# By default, 'start' only creates the branch on origin, so we remove
	# the local branch. (I looked, but did not find a way to create
	# branches on the remote without creating an intemediate local
	# branch.)
	git branch -q -d "$BRANCH_NAME"

	echo "Use 'con $RESOURCE checkout' to begin working locally. In future, you can use"
	echo "'con $RESOURCE start --checkout' to automatically checkout the branch locally."
    else
	git checkout -q "$BRANCH_NAME"
    fi
}

function abandon_branch() {
    # The 'resource' is guaranteed as the first argument by the parent
    # controller script, so it actually comes before the options.
    local RESOURCE="$1"; shift

    # Process any options
    FLAGS_PARENT="topics"
    DEFINE_boolean 'confirmed' false 'Skips the confirmation.' 'c'
    FLAGS "$@" || exit $?
    eval set -- "${FLAGS_ARGV}"

    local RESOURCE_NAME="$1"; shift
    local SINGULAR_RESOURCE=`determine_singular_resource "$RESOURCE"`
    local BRANCH_NAME=`verify_branch_inputs "$RESOURCE" "$RESOURCE_NAME"`

    local CLEAR_ASSIGNMENT=1 # '1' means 'nothing to remove' which is true for all non-topics.
    if [ x"$RESOURCE" == x"topics" ]; then
	# We have to deal with the issue assignment.
	load_hooks
	clear_assignee "$RESOURCE_NAME" > /dev/null
	CLEAR_ASSIGNMENT=$?
    fi
    if [ $CLEAR_ASSIGNMENT -eq 0 ]; then
	echo -n "Assignment cleared. "
    fi

    if ! has_branch_local "$BRANCH_NAME" && ! has_branch_origin "$BRANCH_NAME" && [ $CLEAR_ASSIGNMENT -ne 0 ]; then
	# 'bad reference' case
	if [ $CLEAR_ASSIGNMENT -eq 1 ]; then
	    echo "WARNING: Nothing found to abandon for '$RESOURCE_NAME'." >&2
	else
	    echo "ERROR: Found no branches to clear, but could not verify issue assignment." >&2
	fi
	exit 1
    else # It's a good reference somewhere; since we're abandoning it, it
	 # doesn't matter if it's local and remote or just one or the other,
	 # as far as the user is concerned. We just remove it wherever

	if has_branch_local "$BRANCH_NAME"; then
	    # TODO: actually, we should only do this if the current branch is the topic branch we're dropping; but it usually is, so for now...
	    git checkout --quiet master
	    if git branch --quiet -D "$BRANCH_NAME"; then
		echo -n "Local branch deleted. "
	    else
		# $? will be set to the result if 'git --quiet...'
		echo -n "Problem deleting local branch; exit code $?."
	    fi
	else
	    echo -n "No local branch found. "
	fi
	# Note: this has the effect of only removing 'topic' branches if the
	# current user is the assignee for the assiated issue. This means that
	# remote branches are never removed for non-topic branches; e.g.,
	# release branches.
	if has_branch_origin "$BRANCH_NAME" && [ $CLEAR_ASSIGNMENT -eq 0 ]; then
	    git push --quiet origin :"$BRANCH_NAME"
	    echo "Branch closed on origin."
	elif has_branch_origin "$BRANCH_NAME"; then
	    echo "No authority to close branch on origin."
	else
	    echo "Already closed on origin."
	fi
    fi
}

checkout_branch() {
    local RESOURCE="$1"; shift
    # TODO: This seems a little off to me; I think it works, but structure
    # seems to imply that '--force' is an option of 'topics' when it is in
    # fact an option for 'checkout'.

    # Process any options
    local FLAGS_PARENT="topics"
    DEFINE_boolean 'force' false 'Force checkout of new branch.' 'f'
    FLAGS "$@" || exit $?
    eval set -- "${FLAGS_ARGV}"

    local RESOURCE_NAME="$1"; shift
    local SINGULAR_RESOURCE=`determine_singular_resource "$RESOURCE"`
    local BRANCH_NAME=`verify_branch_inputs "$RESOURCE" "$RESOURCE_NAME"`

    if [ $FLAGS_force -ne $FLAGS_TRUE ]; then
	ensure_current_branch_committed "checkout $SINGULAR_RESOURCE '$RESOURCE_NAME'"
    fi
    # else the checkout is forced and we skip the commit checks.

    # We always checkin with origin; unless it's master
    if [ x"$BRANCH_NAME" != x"master" ] && ! has_branch_origin "$BRANCH_NAME"; then
	# TODO: Shouldn't this add something to the effect of "Consider abandoning or re-start the topic."
	echo "No such $SINGULAR_RESOURCE '$RESOURCE_NAME' exists on origin." >&2
	exit 1
    fi

    # We are now ready to checkout the branch.
    git checkout -q "$BRANCH_NAME"

    # 'fetch_and_merge' reports any problems itself, so we just need to report
    # on success.
    if fetch_and_merge "$BRANCH_NAME" "$SINGULAR_RESOURCE" "$RESOURCE_NAME"; then
	echo "Switched to $SINGULAR_RESOURCE '$RESOURCE_NAME'."
    fi
}

function commit_branch() {
    local RESOURCE="$1"; shift
    FLAGS_PARENT=""
    DEFINE_string 'message' '' 'Message to include with commit.' 'm'
    FLAGS "$@" || exit $?
    eval set -- "${FLAGS_ARGV}"

    local RESOURCE_NAME=`process_default_resource_name "$RESOURCE" "$1"`; shift
    local SINGULAR_RESOURCE=`determine_singular_resource "$RESOURCE"`

    if [ x"$FLAGS_message" == x'' ]; then
	echo "Commit message required. Use option '-m' after 'commit'." >&2
	exit 1
    fi

    git update-index -q --ignore-submodules --refresh
    if git diff-files --quiet --ignore-submodules -- && git diff-index --cached --quiet HEAD --ignore-submodules --; then
	echo "Nothing to commit."
    else
	check_for_new_files # This forces an exit if new files are found.
	# With no new files, we assume '-a' for git.
	# local MESSAGE=`echo "$FLAGS_message" | sed -e "s/[']/\\&/"`
	# echo "$MESSAGE"
	# git commit -q -am "$MESSAGE"
	git commit -q -am "$FLAGS_message"
    fi
}

function publish_branch() {
    local RESOURCE="$1"; shift
    local RESOURCE_NAME=`process_default_resource_name "$RESOURCE" "$1"`; shift
    local SINGULAR_RESOURCE=`determine_singular_resource "$RESOURCE"`
    local BRANCH_NAME="${RESOURCE}-${RESOURCE_NAME}"

    # Check branch exists on origin. This goes first because it establishes
    # the conanical, fundamental, and necessary existence of the topic branch
    # whereas the local check (up next) is only an accidental check.
    if ! has_branch_origin "$BRANCH_NAME"; then
	echo "Could not find $SINGULAR_RESOURCE '$RESOURCE_NAME' on origin. Perhaps it" >&2
	echo "has been closed or archived. Consider creating a new reference or" >&2
	echo "abandoning changes." >&2
	exit 1
    fi
    # Check that a local resource / branch exists.
    if ! has_branch_local "$BRANCH_NAME"; then
	echo "No such $SINGULAR_RESOURCE '$RESOURCE_NAME' exists locally." >&2
	exit 1
    fi
    # Check all local changes committed.
    ensure_current_branch_committed "publish $SINGULAR_RESOURCE '$RESOURCE_NAME'"
    # Check that we can sync local branch with origin (if necessary).
    # TODO
    # Push the changes.
    if ! git push -q origin "$BRANCH_NAME"; then
	echo "Apparent error while attempting to push changes to origin." >&2
	exit 2
    fi
    
    echo "Published $SINGULAR_RESOURCE '$RESOURCE_NAME'."
}

function delete_branch() {
    local RESOURCE="$1"; shift
    local RESOURCE_NAME=`process_default_resource_name "$RESOURCE" "$1"`; shift
    local SINGULAR_RESOURCE=`determine_singular_resource "$RESOURCE"`
    local BRANCH_NAME="${RESOURCE}-${RESOURCE_NAME}"

    ensure_has_branch_local "$BRANCH_NAME"
    ensure_can_fetch "delete $SINGULAR_RESOURCE '$RESOURCE_NAME'"
    if [ `git rev-parse "$BRANCH_NAME"` != `git rev-parse "remotes/origin/$BRANCH_NAME"` ]; then
	# We're not quite cooked yet, if the local branch head is in the
	# remote branch history, then it's us that's behind.
	local LOCAL_HASH=`git rev-parse "$BRANCH_NAME"`
	local RESULT=`git branch -r --contains $LOCAL_HASH | grep "origin/$BRANCH_NAME" | wc -l`
	if [ $RESULT -eq 0 ]; then
	    echo "${SINGULAR_RESOURCE^} '$RESOURCE_NAME' has local changes. Please publish or abandon." >&2
	    exit 1
	fi
    fi
    # Notice we use '-D' to force the delete. This is because many branches
    # are deleted while not in master. conveyor-workflow rather insists that
    # (unforced) deletes are instead published back to origin before deleting.
    if ! git branch -q -D "$BRANCH_NAME"; then
	echo "Could not delete branch for $SINGULAR_RESOURCE '$RESOURCE_NAME'; reason unknown."
	exit 2
    fi
    echo "Deleted local $SINGULAR_RESOURCE '$RESOURCE_NAME'."
}

function submit_branch() {
    local RESOURCE="$1"; shift
    local RESOURCE_NAME=`process_default_resource_name "$RESOURCE" "$1"`; shift
    local SINGULAR_RESOURCE=`determine_singular_resource "$RESOURCE"`
    local BRANCH_NAME="${RESOURCE}-${RESOURCE_NAME}"

    ensure_has_branch_local "$BRANCH_NAME"
    ensure_can_fetch "submit $SINGULAR_RESOURCE '$RESOURCE_NAME'"
    if [ `git rev-parse "$BRANCH_NAME"` != `git rev-parse "remotes/origin/$BRANCH_NAME"` ]; then
	# For submission, we require the local and remote branches to be
	# exactly the same, but we do distinguish which is out of sync with
	# witch in order to give the user better feedback.
	local LOCAL_HASH=`git rev-parse "$BRANCH_NAME"`
	local RESULT=`git branch -r --contains $LOCAL_HASH | grep "origin/$BRANCH_NAME" | wc -l`
	if [ $RESULT -eq 0 ]; then
	    echo "${SINGULAR_RESOURCE^} '$RESOURCE_NAME' has local changes. You must 'publish' before submitting." >&2
	    exit 1
	else # Then local is ahead of the remote.
	    echo "${SINGULAR_RESOURCE^} '$RESOURCE_NAME' is out of date. You must 'sync' before submitting." >&2
	    exit 1
	fi
    fi # if <local and remote branch heads out of sync>
    # else, everything is in sync.

    # Next step is to preview the merge, which we'll handle locally. Really,
    # the easiest way to do that is to just perform locally. To do this, we
    # ensure everything is committed on the local branch, switch to master,
    # update it, branch a test branch, and then merge the original
    # branch. This can fail at any point in the process, in which case we give
    # up and throw it back to the operator.
    ensure_current_branch_committed "submit $SINGULAR_RESOURCE '$RESOURCE_NAME'"
    git checkout -q master
    if git rev-parse --verify -q _test-merge >/dev/null; then
	git branch -q -D _test-merge
    fi
    git checkout -q -b _test-merge
    if fetch_and_merge master "$SINGULAR_RESOURCE" "$RESOURCE_NAME"; then
	# We're good to generate the PR.
	git checkout -q "$BRANCH_NAME"
	# OK, it's possible that the remote branch has been updated since we
	# first checked, but that will always be the case. We don't try to be
	# thread safe.
	if is_github_clone; then
	    # Now check that we have the necessary connection inf.
	    if ! is_github_configured; then exit 1; fi
	    # Okay, now ready to do this thing.
	    local ISSUE_NUMBER=${RESOURCE_NAME:0:$((`expr index "$RESOURCE_NAME" '-'` - 1))}
	    source $GIT_CONVEY_DIR/lib/github-hooks.sh
	    set_github_origin_data
	    
	    local CURL_COMMAND="curl -X POST -s -u $GITHUB_AUTH_TOKEN:x-oauth-basic https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/pulls -d @-"
	    local TMP_FILE="/tmp/$RANDOM"
	    cat <<EOF | $CURL_COMMAND > $TMP_FILE
{
  "title": "Pull request for issue #$ISSUE_NUMBER",
  "body": "Fixes #${ISSUE_NUMBER}. Generated by conveyor-workflow.",
  "head": "$BRANCH_NAME",
  "base": "master"
}
EOF
	    local PR_JSON=`cat $TMP_FILE`
	    rm $TMP_FILE
	    local PHP_BIN=$DFS_HOME/third-party/php5/runnable/bin/php
	    local PR_NUMBER=`echo $PR_JSON | $PHP_BIN -r '$handle = fopen ("php://stdin","r"); $json = stream_get_contents($handle); $data = json_decode($json, true); print $data["number"];'`
	    echo "Created PR #${PR_NUMBER}."
	else
	    echo "Do not yet know how to submit work for non-GitHub repositories. Come back later..." >&2
	    exit 2
	fi
    fi # if fetch_and_merge master...;
    # If that fais, then there's nothing for us to do.
}

function process_default_resource_name() {
    local RESOURCE="$1"; shift
    local RESOURCE_NAME;
    if [ x"$1" != x"" ]; then
	RESOURCE_NAME="$1"; shift
    else
	local BRANCH_NAME=`git rev-parse --abbrev-ref HEAD`
	# Defaut to current branch, which must match the stated resource.
	if [[ "$BRANCH_NAME" != "${RESOURCE}-"* ]]; then
	    echo "Mis-matched resource on default target. Cannot operate on branch '$BRANCH' as '$RESOURCE' resource." >&2
	    exit 1
	fi
	RESOURCE_NAME="${BRANCH_NAME:$((${#RESOURCE} + 1))}"
    fi
    echo "$RESOURCE_NAME"
}

function verify_branch_inputs() {
    local RESOURCE="$1"; shift
    local RESOURCE_NAME="$1"; shift

    if [ x"$RESOURCE" == x"" ]; then
	echo "Internal error; no resource given." >&2
	exit 2
    fi
    case "$RESOURCE" in
	releases)
	    ;;
	topics)
	    ;;
	*)
	    echo "Internal error; unknown resource: '$RESOURCE'." >&2
	    exit 2;;
    esac
    if [ x"$RESOURCE_NAME" == x"" ]; then
	echo "No resource name supplied." >&2
	exit 1
    fi

    # There is one special case
    if [ x"$RESOURCE" == x"releases" ] && [ x"$RESOURCE_NAME" == x"master" ]; then
	echo "master"
    else # Standard naming convention for everything else.
	echo "${RESOURCE}-${RESOURCE_NAME}"
    fi
}

function generic_name_tests() {
    local NAME="$1"; shift

    local EXIT=0
    if [[ x"$NAME" == *" "* ]]; then
	echo "Resource names cannot contain spaces; got '$NAME'." >&2
	EXIT=1
    fi
    if [[ x"$NAME" == *"_"* ]]; then
	echo "Resource names should use '-' rather than '_'; got '$NAME'." >&2
	EXIT=1
    fi
    
    if [ $EXIT -ne 0 ]; then exit $EXIT; fi
}

function determine_singular_resource() {
    echo ${RESOURCE:0:$((${#RESOURCE} - 1))}
}

function fetch_and_merge() {
    local BRANCH_NAME="$1"; shift
    local SINGULAR_RESOURCE="$1"; shift
    local RESOURCE_NAME="$1"; shift

    git fetch -q
    if ! git merge --no-ff -q origin/"$BRANCH_NAME"; then
	echo "There are local conflicts or other problems merging the local and remote $SINGULAR_RESOURCE '$RESOURCE_NAME';" >&2
	echo "please resolve and commit with 'con commit'." >&2
	return 1
    fi

    return 0
}

function check_for_new_files() {
    local NEW_FILES=`git status --porcelain | grep '^?? '`
    if [ x"$NEW_FILES" != x"" ]; then
	echo "You must explitly add new files with 'git add', add the files to '.gitignore', or remove the files:"
	echo "$NEW_FILES" | perl -ne 's/\?\? //; print " $_"'
	exit 1
    fi

    return 0
}

function figure_resource_from_branch() {
    local BRANCH="$1"; shift

    if [[ x"$BRANCH" == xtopics-* ]]; then
	echo "topics"
    elif [[ x"$BRANCH" == xreleases-* ]] || [[ x"$BRANCH" == x"master" ]]; then
	echo "releases"
    else
	echo "Internal error; unexpected branch name: '$BRANCH'." >&2
	exit 2
    fi
}

function figure_resource_name_from_branch() {
    local BRANCH="$1"; shift

    if [[ x"$BRANCH" == xtopics-* ]]; then
	echo ${BRANCH#topics-}
    elif [[ x"$BRANCH" == xreleases-* ]] || [[ x"$BRANCH" == x"master" ]]; then
	echo ${BRANCH#releases-}
    else
	echo "Internal error; unexpected branch name: '$BRANCH'." >&2
	exit 2
    fi
}

function get_current_branch() {
    local ORIGINAL_BRANCH=$(git symbolic-ref -q HEAD)
    ORIGINAL_BRANCH=${ORIGINAL_BRANCH##refs/heads/}
    ORIGINAL_BRANCH=${ORIGINAL_BRANCH:-HEAD}
    echo "$ORIGINAL_BRANCH"
}

function load_hooks() {
    local HOOKS='manual' # Set default hooks.
    if is_github_clone; then
	HOOKS='github'
    fi
    local HOOKS_LIB="$CONVEYOR_HOME/workflow/runnable/lib/${HOOKS}-hooks.sh"
    if [ ! -f "$HOOKS_LIB" ]; then
	echo "ERROR: Could not find hooks library." >&2
	exit 2
    fi
    source "$HOOKS_LIB"
}

function do_clone() {
    local TMP_FILE="/tmp/$RANDOM"
    git clone --quiet $@ 2> $TMP_FILE
    local CLONE_RESULT=$?
    local TRIES=1
    while [ $CLONE_RESULT -ne 0 ] && [ $TRIES -lt 10 ]; do
	sleep $TRIES
	git clone --quiet $@ 2> $TMP_FILE
	CLONE_RESULT=$?
	TRIES=$(($TRIES + 1))
    done
    if [ $CLONE_RESULT -ne 0 ]; then
	echo "Unable to clone repo at: '$CLONE_URL'." >&2
	cat $TMP_FILE >&2
	rm $TMP_FILE
	return 1
    fi
    rm $TMP_FILE
}
