# Here we follow shflags. Without reliable packaging, we find it easier to
# just make the library self sufficient.
FLAGS_TRUE=0
FLAGS_FALSE=1

setup_path() {
    RUNNABLE_PATH="$1"

    # Git expects to find 'conveyor-workflow' on the PATH. So we check to see if it
    # is, and if not, we add it.
    which conveyor-workflow > /dev/null 2> /dev/null
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
	cd $RUNNABLE_PATH
	RUNNABLE_PATH=`realpath $RUNNABLE_PATH`
	export PATH=$PATH:$RUNNABLE_PATH
    fi
}

test_output() {
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
    if [ $# -ge 1 ]; then
	MIN_WORDS="$1"; shift
    else
	MIN_WORDS=''
    fi
    if [ $# -ge 1 ]; then
	ECHO_OUTPUT="$1"
    else
	ECHO_OUTPUT=1 # Bash for false.
    fi

    # Evaluate whether or not we expect output for stdout and stderr.
    if [[ ( x"$EXPECTED_STDOUT_START" == x"") && 
	  ( x"$MIN_WORDS" == x"" || $MIN_WORDS -eq 0 ) ]] ; then
	NO_EXPECTED_STDOUT=${FLAGS_TRUE}
    else
	NO_EXPECTED_STDOUT=${FLAGS_FALSE}
    fi
    if [ x"$EXPECTED_STDERR_START" == x"" ]; then
	NO_EXPECTED_STDERR=${FLAGS_TRUE}
    else
	NO_EXPECTED_STDERR=${FLAGS_FALSE}
    fi
    TMP_FILE="/tmp/$RANDOM"

#    if ! eval 'OUTPUT=`$COMMAND 2>$TMP_FILE | sed -n 1p`'; then
    eval 'OUTPUT=`$COMMAND 2>$TMP_FILE`'
    RESULT=$?
    if [ $RESULT != $EXPECTED_EXIT_CODE ]; then
	echo "ERROR: expected exit code '$EXPECTED_EXIT_CODE', but got '$RESULT' for '$COMMAND'."
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

    OUTPUT_ARRAY=( $OUTPUT )
    WORD_COUNT=${#OUTPUT_ARRAY[@]}
    if [[ ( x"$MIN_WORDS" != x"" ) && ( $WORD_COUNT -lt $MIN_WORDS ) ]]; then
	echo "ERROR: '$COMMAND' output was expected to output at least ${MIN_WORDS}, but instead got $WORD_COUNT." >&2
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

    if [ $ECHO_OUTPUT -eq 0 ]; then
	echo $OUTPUT
    fi
}

test_help() {
    COMMAND="$1"; shift
    EXPECTED_STDOUT_START="$1"; shift
    test_output "$COMMAND" "$EXPECTED_STDOUT_START" "" 0
}

test_significant_output() {
    COMMAND="$1"; shift
    test_output "$COMMAND" "" "" 0 5
}

#/**
#* Thanks to <a
#* href="http://stackoverflow.com/users/1320169/rintcius">rintcius</a> for his
#* <a
#* href="http://stackoverflow.com/questions/6565357/git-push-requires-username-and-password">answer</a>
#* on StackOverflow.com.
#*/
function automate_github_https() {
    if [ ! -f $HOME/.netrc ]; then
	set_github_origin_data
	cat <<EOF > $HOME/.netrc
machine github.com
   login $GITHUB_AUTH_TOKEN
   password x-oauth-basic
EOF
	trap "{ rm $HOME/.netrc }" EXIT
    fi
}
