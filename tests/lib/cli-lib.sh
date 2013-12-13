test_help() {
    COMMAND="$1"; shift
    EXPECTED_OUTPUT_START="$1"; shift
    TMP_FILE="/tmp/$RANDOM"

    if ! eval 'OUTPUT=`$COMMAND 2>$TMP_FILE | sed -n 1p`'; then
	# We checked this detects failure by adding 'exit 2' to the 'usage',
	# 'resource_usage', and 'resource_help' functions.
	echo "ERROR: '$COMMAND' exitted with non-zero status."
    fi
    if [ x"$OUTPUT" == x"" ]; then
	# Tested this detects failure by exiting immediately from help mode.
	echo "ERROR: '$COMMAND' did not produce any text on stdout."
    elif [[ "$OUTPUT" != "$EXPECTED_OUTPUT_START"* ]]; then
	# Tested this detects failure by modifying the output of usage,
	# resource_usage, and resource_help.
	echo -e "ERROR: '$COMMAND' output did not start with expected '$EXPECTED_OUTPUT_START'; got:\n$OUTPUT"
    fi
    if [ -f $TMP_FILE ] && [ -s $TMP_FILE ]; then
	# Tested this detects failure by echoing to stderr in usage,
	# resource_usage, and resource_help.
	echo -e "ERROR: '$COMMAND' resulted in output to stderr:\n"
	cat $TMP_FILE
    fi

    rm $TMP_FILE
}
