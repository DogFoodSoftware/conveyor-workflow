# shflags does not export the FLAGS_TRUE/FLAGS_FALSE. Maybe should, but till
# then...
source `dirname $0`/../runnable/lib/shflags

list_resources() {
    RESOURCE="$1"; shift
    if [ x"${FLAGS_mark}" == x"${FLAGS_FALSE}" ]; then
	FORMAT='echo -n " "; echo "  %(refname:short)";'
    else
	FORMAT='if [ `git branch | grep "^*" | cut -d" " -f2 ` == %(refname:short) ]; then echo -n "*"; else echo -n " "; fi; echo " %(refname:short)";'
    fi
    EVAL=`git for-each-ref --shell --format="$FORMAT" refs/heads/$RESOURCE-*`
    eval $EVAL
}

start_branch() {
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
    echo "TODO: need to check that the branch name does not already exist 1) locally and then 2) on the origin server." >&2
    exit 2

    # The name is acceptable; create the branch.
    git checkout -b "$BRANCH_NAME"
    git push origin "$BRANCH_NAME"
}

function generic_name_tests() {
    NAME="$1"; shift

    EXIT=0
    if [[ x"$NAME" == *" "* ]]; then
	echo "Names cannot contain spaces; got '$NAME'." >&2
	EXIT=1
    fi
    if [[ x"$NAME" == *"_"* ]]; then
	echo "Names should use '-' rather than '_'; got '$NAME'" >&2
	EXIT=1
    fi
    
    if [ $EXIT -ne 0 ]; then exit $EXIT; fi
}
