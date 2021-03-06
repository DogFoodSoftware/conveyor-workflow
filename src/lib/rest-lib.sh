#/**
#* <div id="Implementation" class="blurbSummary grid_12">
#* <div class="blurbTitle">Implementation</div>
#* <div class="p">
#*   The main idea is to take the excellent <a
#*   href="https://github.com/micha/resty">Resty</a><span
#*   class="note">Actually, we use <a
#*   href="https://github.com/nrocco/resty">this fork</a> because we need the
#*   <code>PATCH</code> verb for GitHub.</span> and wrap that with some error
#*   handling that looks at status codes and (for now) GitHub style feedback.
#* </div>
#*/
source $HOME/.conveyor/config
source $CONVEYOR_HOME/workflow/runnable/lib/resty

# GitHub API wrapper
function github_api {
    local VERB="$1"; shift
    local RESTY_STATUS JSON MESSAGE REST_LIB_STATUS REST_LIB_RATE_LEFT
    local HEADER_OUT="headerout-$RANDOM"
    local STDOUT="stdout-$RANDOM"
    local STDERR="stderr-$RANDOM"
    rm $HOME/.conveyor-workflow/last-rest-data
    source $HOME/.conveyor-workflow/github
    resty https://api.github.com* 2> /dev/null
    if [ $# -eq 1 ]; then
	# We set the agent (-A) per github protocol: https://developer.github.com/v3/#user-agent-required
	$VERB "$@" -D $HEADER_OUT -A 'DogFoodSoftware/conveyor-workflow' -u $GITHUB_AUTH_TOKEN:x-oauth-basic -m 4 > $STDOUT 2> $STDERR
    else 
	$VERB "$@" -H 'Content-Type: application/json' -D $HEADER_OUT -A 'DogFoodSoftware/conveyor-workflow' -u $GITHUB_AUTH_TOKEN:x-oauth-basic > $STDOUT 2> $STDERR
    fi
    RESTY_STATUS=$?

    if [ -f $HEADER_OUT ]; then
	# Extract common data element:
	# - numerical status
	REST_LIB_STATUS=`cat $HEADER_OUT | grep '^Status:' | cut -d' ' -f 2`
	# - remaning calls
	REST_LIB_RATE_LEFT=`cat $HEADER_OUT | grep '^X-RateLimit-Remaining:' | cut -d' ' -f 2`
	echo -e "REST_LIB_STATUS=$REST_LIB_STATUS\nREST_LIB_RATE_LEFT=$REST_LIB_RATE_LEFT" > $HOME/.conveyor-workflow/last-rest-data
	rm $HEADER_OUT
    else
	echo "ERROR: No headers found." >&2
    fi

    if [ $RESTY_STATUS -ne 0 ]; then
	echo "ERROR: REST call failed for '$VERB $@'. ("`last_rest_status`")" >&2
	JSON=`cat $STDERR`
	MESSAGE=`json_extract '["message"]' "$JSON"`
	if [ x"$MESSAGE" == x"" ]; then
	    cat $STDOUT >&2
	    echo "ERROR: No message provided. $JSON" >&2
	else
	    echo "ERROR: $MESSAGE" >&2
	fi
	local LOG_FILE=$HOME/.conveyor-workflow/rest-lib.log
	echo `date +'%Y-%m-%d %H:%M:%S.%N'`" ERROR: REST call failed for '$VERB $@'. ("`last_rest_status`")" >> $LOG_FILE
	echo "---------------" >> $LOG_FILE
	echo "$JSON" >> $LOG_FILE
	echo "---------------" >> $LOG_FILE
    else
	cat $STDOUT
    fi

    if [ -f $STDOUT ]; then
	rm $STDOUT
    fi
    if [ -f $STDERR ]; then
	rm $STDERR
    fi

    return $RESTY_STATUS
}

function github_query {
    local EXTRACT_SPEC="$1"; shift

    local JSON RESULT
    JSON=`github_api "$@"`
    RESULT=$?
    if [ $RESULT -eq 0 ]; then
	json_extract "$EXTRACT_SPEC" "$JSON"
    fi

    return $RESULT
}

function json_extract {
    local EXTRACT_SPEC="$1"; shift
    local JSON="$1"; shift

    local PHP_BIN=$DFS_HOME/third-party/php5/runnable/bin/php
    echo "$JSON" | $PHP_BIN -r '$handle = fopen ("php://stdin","r"); $json = stream_get_contents($handle); $data = json_decode($json, true); print $data'$EXTRACT_SPEC';'
}

function last_rest_status() {
    if [ -f $HOME/.conveyor-workflow/last-rest-data ]; then
	source $HOME/.conveyor-workflow/last-rest-data
	if [ x"$REST_LIB_STATUS" == x"" ]; then
	    REST_LIB_STATUS='-1' # unknown
	fi
	echo $REST_LIB_STATUS
    else
	echo '-1'
    fi
}

#/**
#*</div><!-- #Implementation -->
#*/
