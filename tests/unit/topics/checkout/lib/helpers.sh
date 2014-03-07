function setup_a_b() {
    git checkout -q master
    con topics start --checkout existing-topic-a >/dev/null
    con topics start existing-topic-b >/dev/null
    CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
    # Paranoid check.
    if [ x"$CURRENT_BRANCH" != x'topics-existing-topic-a' ]; then
	echo "ERROR: Expected to be on branch 'topics-existing-topic-a'; test inconclusive, but instead on '$CURRENT_BRANCH'."
    fi
}

function verify_fail_a_b() {
    POST_CHECKOUT_COMMAND="$1"; shift
    EXPECTED_ERR="$1"; shift

    test_output "con topics checkout $POST_CHECKOUT_COMMAND" '' "$EXPECTED_ERR" 1
    CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
    if [ x"$CURRENT_BRANCH" != x'topics-existing-topic-a' ]; then
	echo "ERROR: Expected to be on branch 'topics-existing-topic-a' after failed checkout, but instead on '$CURRENT_BRANCH'."
    fi
}

function verify_pass_a_b() {
    POST_CHECKOUT_COMMAND="$1"; shift
    EXPECTED_OUT="$1"; shift
    EXPECTED_BRANCH='topics-existing-topic-b'

    test_output "con topics checkout $POST_CHECKOUT_COMMAND" "$EXPECTED_OUT" '' 0
    CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
    if [ x"$CURRENT_BRANCH" != x"$EXPECTED_BRANCH" ]; then
	echo "ERROR: Expected to be on branch '$EXPECTED_BRANCH' after seemingly successful checkout, but instead on '$CURRENT_BRANCH'."
    fi
}
