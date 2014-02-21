function test_start() {
    # Mandatory args
    COMMAND="$1"; shift
    RESOURCE="$1"; shift
    RESOURCE_NAME="$1"; shift
    BRANCH_NAME="${RESOURCE}-${RESOURCE_NAME}"
    EXPECTED_STDOUT_START="$1"; shift
    EXPECTED_STDERR_START="$1"; shift

    # Optional args.
    if [ $# -ge 1 ]; then
	EXPECTED_EXIT_CODE="$1"; shift
    else
	EXPECTED_EXIT_CODE=0
    fi

    test_output "$COMMAND" "$EXPECTED_STDOUT_START" "$EXPECTED_STDERR_START" $EXPECTED_EXIT_CODE

    # Check local branch created.
    git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
	echo "ERROR: Did not find expected local branch for topic '$BRANCH_NAME' in $WORKING_REPO_PATH."
    fi
    git ls-remote --exit-code . "origin/$BRANCH_NAME" > /dev/null
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
	echo "ERROR: Did not find expected remote branch for topic '$BRANCH_NAME' in $WORKING_REPO_PATH."
    fi
}
