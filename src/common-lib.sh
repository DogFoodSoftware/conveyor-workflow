# shflags does not export the FLAGS_TRUE/FLAGS_FALSE. Maybe should, but till
# then...
source `dirname $0`/../runnable/lib/shflags

list_resources() {
    RESOURCE="$1"; shift
    if [ x"${FLAGS_mark}" == x"${FLAGS_FALSE}" ]; then
	FORMAT='echo -n " "; echo "  %(refname:short)";'
    else
	FORMAT='if [ `git branch | grep "^*" | cut -d" " -f2 ` == %(refname:short) ]; then echo -n "*"; else echo -n " "; fi; BRANCH=%(refname:short); TOPIC=${BRANCH:$((${#RESOURCE} + 1))}; echo " $TOPIC";'
    fi
    EVAL=`git for-each-ref --shell --format="$FORMAT" refs/heads/$RESOURCE-*`
    eval $EVAL
}

start_branch() {
    RESOURCE="$1"; shift
    # Process any options
    FLAGS_PARENT="topics"
    DEFINE_boolean 'checkout' false 'Automatically checkout newly created topic branch locally.' 'c'
    FLAGS "$@" || exit $?
    eval set -- "${FLAGS_ARGV}"

    RESOURCE_NAME="$1"; shift
    SINGULAR_RESOURCE=`determine_singular_resource "$RESOURCE"`
    BRANCH_NAME=`verify_branch_inputs "$RESOURCE" "$RESOURCE_NAME"`
    
    # Now we check that the branch name conforms. There's one generic test,
    # then we hand it off to the callback defined in the resource handler
    # script.
    generic_name_tests "$RESOURCE_NAME"

    # And are we going to step on existing branches?
    if has_branch_local "$BRANCH_NAME"; then
	echo "Local branch for topic '$BRANCH_NAME' already exists."
    fi
    if has_branch_origin "$BRANCH_NAME"; then
	echo "Branch for topic '$BRANCH_NAME' already exists on origin."
    fi

    # The name is acceptable; create the branch.
    git checkout -q -b "$BRANCH_NAME"
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
	echo "Git reported an error creating topic branch '$BRANCH_NAME'. Bailing out." >&2
	exit 3
    fi
    git push -q origin "$BRANCH_NAME"
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
	echo "Git reported an error pushing topic branch '$BRANCH_NAME' to origin." >&2
	echo "Deleting local topic branch and bailing out." >&2
	git checkout -q master
	git branch -q -d "$BRANCH_NAME"
	exit 3
    fi
    if [ $FLAGS_checkout -eq $FLAGS_FALSE ]; then
	# By default, 'start' only creates the branch on origin, so we remove
	# the local branch. (I looked, but did not find a way to create
	# branches on the remote without creating an intemediate local
	# branch.)
	git checkout -q master
	git branch -q -d "$BRANCH_NAME"
    fi
    # Else, nothing to do, we are already on the new branch.

    echo "Created $SINGULAR_RESOURCE '$RESOURCE_NAME' on origin. Use 'git convey checkout'"
    echo "to begin working locally. In future, you can use 'git convey start --checkout'"
    echo "to automatically checkout the branch locally."
}

checkout_branch() {
    RESOURCE="$1"; shift
    RESOURCE_NAME="$1"; shift
    SINGULAR_RESOURCE=`determine_singular_resource "$RESOURCE"`
    BRANCH_NAME=`verify_branch_inputs "$RESOURCE" "$RESOURCE_NAME"`

    if ! has_branch_origin "$BRANCH_NAME"; then
	echo "No such $SINGULAR_RESOURCE '$RESOURCE_NAME' exists on origin." >&2
	exit 1
    fi

    # We are now ready to checkout the branch.
    git checkout -q "$BRANCH_NAME"

    # 'fetch_and_merge' reports any problems itself, so we just need to report
    # on success.
    if fetch_and_merge "$BRANCH_NAME"; then
	echo "Switched to $SINGULAR_RESOURCE '$RESOURCE_NAME'."
    fi
}

function commit_branch() {
    RESOURCE="$1"; shift
    RESOURCE_NAME=`process_default_resource_name "$RESOURCE" "$1"`; shift
    SINGULAR_RESOURCE=`determine_singular_resource "$RESOURCE"`

    if [ x`git status --porcelain` == x'' ]; then
	echo "Nothing to commit."
    else
	check_for_new_files # This forces an exit if new files are found.
	# With no new files, we assume '-a' for git.
	git commit -am "TODO: allow user to pass in commit messege"
	if [ x`git status --porcelain` == x'' ]; then
	    echo "Status unexpectable reports outstanding changes after commit." >&2
	    git status
	    exit 2
	fi
    fi
}

function publish_branch() {
    RESOURCE="$1"; shift
    RESOURCE_NAME=`process_default_resource_name "$RESOURCE" "$1"`; shift
    SINGULAR_RESOURCE=`determine_singular_resource "$RESOURCE"`
    BRANCH_NAME="${RESOURCE}-${RESOURCE_NAME}"

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
    if [ x`git status --porcelain` != x'' ]; then
	echo "Cannot publish $SINGULAR_RESOURCE '$RESOURCE_NAME' due to uncommited changes." >&2
	exit 1
    fi
    # Check that we can sync local branch with origin (if necessary).
    # TODO
    # Push the changes.
    if ! git push -q origin $BRANCH_NAME; then
	echo "Apparent error while attempting to push changes to origin." >&2
	exit 2
    fi
    
    echo "Published $SINGULAR_RESOURCE '$RESOURCE_NAME'."
}

function process_default_resource_name() {
    RESOURCE="$1"; shift
    if [ x"$1" != x"" ]; then
	RESOURCE_NAME="$1"; shift
    else
	BRANCH_NAME=`git rev-parse --abbrev-ref HEAD`
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
    RESOURCE="$1"; shift
    RESOURCE_NAME="$1"; shift

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

    echo "${RESOURCE}-${RESOURCE_NAME}"
}

function generic_name_tests() {
    NAME="$1"; shift

    EXIT=0
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
    BRANCH_NAME="$1"; shift

    git fetch -q
    if ! git merge --no-ff -q origin/"$BRANCH_NAME"; then
	echo "There are local conflicts or other problems merging the update, please resolve and commit with 'git convey commit'."
	exit 1
    fi

    return 0
}

function check_for_new_files() {
    NEW_FILES=`git status --porcelain | grep '^?? '`
    if [ x"$NEW_FILES" != x"" ]; then
	echo "You must explitly add new files with 'git add', add the files to '.gitignore', or remove the files:"
	echo "$NEW_FILES" | perl -ne 's/\?\? //; print " $_"'
	exit 1
    fi

    return 0
}
