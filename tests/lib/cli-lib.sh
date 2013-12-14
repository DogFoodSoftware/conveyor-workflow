test_output() {
    source `dirname $0`/../runnable/lib/shflags
    FLAGS_PARENT=""

    # We really want 'min-words' but shFlags doesn't like it. Patch?
    DEFINE_integer min_words '' 'minimum number of words' 'm'

    FLAGS "$@" || exit $?
    eval set -- "${FLAGS_ARGV}"


    COMMAND="$1"; shift
    EXPECTED_STDOUT_START="$1"; shift
    if [[ ( x"$EXPECTED_STDOUT_START" == x"") && 
	  ( x"$FLAGS_min_words" == x"" || $FLAGS_min_words -eq 0 ) ]] ; then
	NO_EXPECTED_STDOUT=${FLAGS_TRUE}
    else
	NO_EXPECTED_STDOUT=${FLAGS_FALSE}
    fi
    EXPECTED_STDERR_START="$1"; shift
    if [ x"$EXPECTED_STDERR_START" == x"" ]; then
	NO_EXPECTED_STDERR=${FLAGS_TRUE}
    else
	NO_EXPECTED_STDERR=${FLAGS_FALSE}
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
	[ "$NO_EXPECTED_STDOUT" != "${FLAGS_TRUE}" ]; then
	# Tested this detects failure by exiting immediately from help mode.
	echo "ERROR: '$COMMAND' did not produce any text on stdout as expected."
    elif [ x"$OUTPUT" != x"" ] &&
	[ "$NO_EXPECTED_STDOUT" == "${FLAGS_TRUE}" ]; then
	echo -e "ERROR: '$COMMAND' was not expected to produce output, but got:\n$OUTPUT"
    elif [[ "$OUTPUT" != "$EXPECTED_STDOUT_START"* ]]; then
	# Tested this detects failure by modifying the output of usage,
	# resource_usage, and resource_help.
	echo -e "ERROR: '$COMMAND' output did not start with expected:\n'$EXPECTED_STDOUT_START'; got:\n'$OUTPUT'"
    fi

    if [[ ( x"$FLAGS_min_words" -ne x"" ) && ( ${#OUTPUT} -lt $FLAGS_min_words ) ]]; then
	echo "ERROR: '$COMMAND' output was expected to output at least $FLAGS_min_words, but instead got ${#OUTPUT}." >&2
    fi

    if [ x"$ERROUT" == x"" ] &&
	[ x"$NO_EXPECTED_STDERR" != x"$FLAGS_TRUE" ]; then
	echo "ERROR: '$COMMAND' did not produce any text on stderr as expected."
    elif [ x"$ERROUT" != x"" ] &&
	[ "$NO_EXPECTED_STDERR" == "$FLAGS_TRUE" ]; then
	echo -e "ERROR: '$COMMAND' was not expected to produce error output, but got:\n$ERROUT"
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

test_significant_output() {
    COMMAND="$1"; shift
    test_output -m 5 "$COMMAND"
}
