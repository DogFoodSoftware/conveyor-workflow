function test_start() {
    # Mandatory args
    COMMAND="$1"; shift
    EXPECTED_STDOUT_START="$1"; shift
    EXPECTED_STDERR_START="$1"; shift

    # Optional args.
    if [ $# -ge 1 ]; then
	EXPECTED_EXIT_CODE="$1"; shift
    else
	EXPECTED_EXIT_CODE=0
    fi

    test_output "$COMMAND" "$EXPECTED_STDOUT_START" "$EXPECTED_STDERR_START" $EXPECTED_EXIT_CODE

    echo "ERROR: check local branch created" >&2
    echo "ERROR: check origin branch created" >&2
}
