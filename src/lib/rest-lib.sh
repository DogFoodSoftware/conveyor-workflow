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

# Override the Resty 'verb' methods to implement the error handling.
function HEAD() {
    common_resty_handler HEAD "$@"
}

function OPTIONS() {
    common_resty_handler OPTIONS "$@"
}

function GET() {
    common_resty_handler GET "$@"
}

function POST() {
    common_resty_handler POST "$@"
}

function PUT() {
    common_resty_handler PUT "$@"
}

function DELETE() {
    common_resty_handler DELETE "$@"
}

function PATCH() {
    common_resty_handler PATCH "$@"
}

function common_resty_handler() {
    local VERB="$1"; shift
    
    local HEADER_OUT="headerout-$RANDOM"

    # Everything from '-D' on gets passed to curl. Some of the $@ may get
    # passed to curl to.
    resty $VERB "$@" -D $HEADER_OUT -A 'DogFoodSoftware/conveyor-workflow'
    local RESTY_STATUS=$?

    if [ -f $HEADER_OUT ]; then
	# Extract common data element:
	# - numerical status
	REST_LIB_STATUS=`cat $HEADER_OUT | grep '^Status:' | cut -d' ' -f 2`
	# - remaning calls
	REST_LIB_RATE_LEFT=`cat $HEADER_OUT | grep '^X-RateLimet-Remaining:' | cut -d: -f 2`
	rm $HEADER_OUT
    else
	echo "ERROR: No headers found." >&2
    fi

    if [ $RESTY_STATUS -ne 0 ]; then
	echo "ERROR: REST call failed for '$@'." >&2
    fi

    return $RESTY_STATUS
}

# Git Specific wrapper
function github_api {
    resty https://api.github.com 2> /dev/null
    local VERB="$1"; shift
    local STDOUT="stdout-$RANDOM"
    source $HOME/.conveyor-workflow/github
    $VERB "$@" -u $GITHUB_AUTH_TOKEN:x-oauth-basic > $STDOUT
    local RESTY_STATUS=$?
    
    if [ $RESTY_STATUS -ne 0 ]; then
	local JSON=`cat $STDOUT`
	local MESSAGE=`json_extract '["message"]' $JSON`
	if [ x"$MESSAGE" == x"" ]; then
	    echo "ERROR: No message provided." >&2
	else
	    echo "ERROR: $MESSAGE" >&2
	fi
    else
	cat $STDOUT
    fi
    
    rm $STDOUT

    return $RESTY_STATUS
}

function github_query {
    local EXTRACT_SPEC="$1"; shift

    local JSON=`github_api "$@"`
    if [ $? -eq 0 ]; then
	json_extract "$EXTRACT_SPEC" "$JSON"
    fi
}

function json_extract {
    local EXTRACT_SPEC="$1"; shift
    local JSON="$1"; shift

    local PHP_BIN=$DFS_HOME/third-party/php5/runnable/bin/php
    echo $JSON | $PHP_BIN -r '$handle = fopen ("php://stdin","r"); $json = stream_get_contents($handle); $data = json_decode($json, true); print $data'$EXTRACT_SPEC';'
}

#/**
#*</div><!-- #Implementation -->
#*/
