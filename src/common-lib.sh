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
    BRANCH_NAME="$1"; shift

    verify_branch_inputs "$RESOURCE" "$BRANCH_NAME"
    
    # Now we check that the branch name conforms. There's one generic test,
    # then we hand it off to the callback defined in the resource handler
    # script.
    generic_name_tests "$BRANCH_NAME"
    if type "check_new_branch_name" >/dev/null 2>&1; then
	check_new_branch_name "$BRANCH_NAME"
    else
	echo "Internal error: resource handler does not define 'check_new_branch_name'." >&2
	exit 2
    fi
    # Thanks to: 
    # http://stackoverflow.com/questions/5167957/is-there-a-better-way-to-find-out-if-a-local-git-branch-exists
    git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"
    RESULT=$?
    if [ $RESULT -eq 0 ]; then
	echo "Local branch for topic '$BRANCH_NAME' already exists."
    fi
    # Thanks to: 
    # http://stackoverflow.com/questions/8223906/how-to-check-if-remote-branch-exists-on-a-given-remote-repository
    git ls-remote --exit-code . "origin/$BRANCH_NAME" &> /dev/null
    RESULT=$?
    if [ $RESULT -eq 0 ]; then
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

    echo "Switched to a new topic branch '$BRANCH_NAME'."
}

join_branch() {
    RESOURCE="$1"; shift
    BRANCH_NAME="$1"; shift

    verify_branch_inputs "$RESOURCE" "$BRANCH_NAME"
    
    # Now we check that the branch name conforms. There's one generic test,
    # then we hand it off to the callback defined in the resource handler
    # script.
    generic_name_tests "$BRANCH_NAME"
    if type "check_new_branch_name" >/dev/null 2>&1; then
	check_new_branch_name "$BRANCH_NAME"
    else
	echo "Internal error: resource handler does not define 'check_new_branch_name'." >&2
	exit 2
    fi
    # Thanks to: 
    # http://stackoverflow.com/questions/5167957/is-there-a-better-way-to-find-out-if-a-local-git-branch-exists
    git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"
    RESULT=$?
    if [ $RESULT -eq 0 ]; then
	echo "Local branch for topic '$BRANCH_NAME' already exists."
    fi
    # Thanks to: 
    # http://stackoverflow.com/questions/8223906/how-to-check-if-remote-branch-exists-on-a-given-remote-repository
    git ls-remote --exit-code . "origin/$BRANCH_NAME" &> /dev/null
    RESULT=$?
    if [ $RESULT -eq 0 ]; then
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

    echo "Switched to a new topic branch '$BRANCH_NAME'."
}

function verify_branch_inputs() {
    RESOURCE="$1"; shift
    BRANCH_NAME="$1"; shift

    if [ x"$RESOURCE" == x"" ]; then
	echo "Internal error; no resource given." >&2
	exit 2
    fi
    case "$RESOURCE" in
	release)
	    ;;
	topic)
	    ;;
	*)
	    echo "Internal error; unknown resource: '$RESOURCE'." >&2
	    exit 2;;
    esac
    if [ x"$BRANCH_NAME" == x"" ]; then
	echo "You must supply a branch name when starting a '$RESOURCE' branch." >&2
	exit 1
    fi
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
