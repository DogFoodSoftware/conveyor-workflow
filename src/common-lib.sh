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
	git checkout master
	git branch -d "$BRANCH_NAME"
	exit 3
    fi

    echo "Switched to a new $SINGULAR_RESOURCE '$RESOURCE_NAME'."
}

join_branch() {
    RESOURCE="$1"; shift
    RESOURCE_NAME="$1"; shift
    SINGULAR_RESOURCE=`determine_singular_resource "$RESOURCE"`
    BRANCH_NAME=`verify_branch_inputs "$RESOURCE" "$RESOURCE_NAME"`

    if ! has_branch_origin "$BRANCH_NAME"; then
	echo "No such $SINGULAR_RESOURCE '$RESOURCE_NAME' exists on origin." >&2
	exit 1
    fi

    # We are now ready to join the branch.
    git checkout -q $BRANCH_NAME

    git fetch -q
    if ! git merge --no-ff -q origin/"$BRANCH_NAME"; then
	echo "There are local conflicts or other problems merging the update, please resolve and commit with 'git convey commit'."
    else
	echo "Switched to $SINGULAR_RESOURCE '$RESOURCE_NAME'."
    fi
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
	echo "You must supply a branch name when starting a '$RESOURCE' branch." >&2
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
