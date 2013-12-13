test_output() {
    COMMAND="$1"; shift
    EXPECTED_STDOUT_START="$1"; shift
    if [ x"$EXPECTED_STDOUT_START" == x"" ]; then
	NO_EXPECTED_STDOUT=${FLAGS_TRUE}
    fi
    EXPECTED_STDERR_START="$1"; shift
    if [ x"$EXPECTED_STDERR_START" == x"" ]; then
	NO_EXPECTED_STDERR=${FLAGS_TRUE}
    fi
    EXPECTED_EXIT_CODE="$1"; shift
    if [ x"$EXPECTED_EXIT_CODE" == x"" ]; then
	EXPECTED_EXIT_CODE=0
    fi
    TMP_FILE="/tmp/$RANDOM"

    if ! eval 'OUTPUT=`$COMMAND 2>$TMP_FILE | sed -n 1p`'; then
	# We checked this detects failure by adding 'exit 2' to the 'usage',
	# 'resource_usage', and 'resource_help' functions.
	echo "ERROR: '$COMMAND' exitted with non-zero status."
    fi
    ERROUT=`cat $TMP_FILE | sed -n 1p`

    if [ x"$OUTPUT" == x"" ] &&
	[ x"$NO_EXPECTED_STDOUT" != x"$FLAGS_TRUE" ]; then
	# Tested this detects failure by exiting immediately from help mode.
	echo "ERROR: '$COMMAND' did not produce any text on stdout as expected."
    elif [[ "$OUTPUT" != "$EXPECTED_STDOUT_START"* ]]; then
	# Tested this detects failure by modifying the output of usage,
	# resource_usage, and resource_help.
	echo -e "ERROR: '$COMMAND' output did not start with expected:\n'$EXPECTED_STDOUT_START'; got:\n'$OUTPUT'"
    fi

    if [ x"$ERROUT" == x"" ] &&
	[ x"$NO_EXPECTED_STDERR" != x"$FLAGS_TRUE" ]; then
	echo "ERROR: '$COMMAND' did not produce any text on stderr as expected."
    elif [[ "$ERROUT" != "$EXPECTED_STDERR_START"* ]]; then
	echo -e "ERROR: '$COMMAND' stderr output did not start with expected:\n'$EXPECTED_STDERR_START'; got:\n'$ERROUT'"
    fi

    rm $TMP_FILE
}

test_help() {
    COMMAND="$1"; shift
    EXPECTED_STDOUT_START="$1"; shift
    test_output "$COMMAND" "$EXPECTED_STDOUT_START" "" 0
}
