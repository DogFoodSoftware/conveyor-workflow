#/**
#* <div id="Overview" class="blurbSummary">
#* <div class="p">
#*   Collection of shell functions useful in the git-convey code and unit
#*   tests. Implements basic checks regarding git branches so the code can
#*   enforce and verify expectations.
#* </div>
#* </div><!-- #Overview -->
#* <div id="Implementation" class="blurbSummary">
#* <div class="blurbTitle">Implementation</div>
#* <div id="has_branch_local" class="subHeader"><span><code>has_branch_local()</code></span></div>
#* <div class="p">
#*   Derived from <a
#*   href="http://stackoverflow.com/users/140185/manoj-govindan">Maanoj
#*   Govindan</a>'s <a
#*   href="http://stackoverflow.com/questions/5167957/is-there-a-better-way-to-find-out-if-a-local-git-branch-exists">post</a>
#*   on StackOverflow.
#* </div>
function has_branch_local() {
    local BRANCH_NAME="$1"; shift
    # Recall, if there's no explicit return, the return value of the function
    # is the status of the last command.
    git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"
}

#* <div class="blurbTitle">Implementation</div>
#* <div class="subHeader"><span><code>ensure_has_branch_local()</code></span></div>
#* <div class="p">
#*   Calls <a href="#has_branch_local"><code>has_branch_local()</code></a> and
#*   emits a standard error message and forces exit if the result is
#*   <code>false</code>.
#* </div>
function ensure_has_branch_local() {
    if ! has_branch_local "$@"; then
	echo "No such $SINGULAR_RESOURCE '$RESOURCE_NAME' exists locally." >&2
	exit 1
    fi
}

#* <div class="subHeader"><span><code>has_branch_origin()</code></span></div>
#* <div class="p">
#*   Derived from <a
#*   href="http://stackoverflow.com/users/133330/darren">Darren</a>'s <a
#*   href="http://stackoverflow.com/questions/8223906/how-to-check-if-remote-branch-exists-on-a-given-remote-repository">post</a>
#*   on StackOverflow.
#* </div>
function has_branch_origin() {
    local BRANCH_NAME="$1"; shift
    # Recall, if there's no explicit return, the return value of the function
    # is the status of the last command.
    if ! git fetch -p -q; then # To update our knowledge of origin branches.
	echo "Could not update local repository from origin. Bailing out." >&2
	exit 2
    fi
    git ls-remote --exit-code . "origin/$BRANCH_NAME" &> /dev/null
}

function ensure_can_fetch() {
    local ACTION_MSG="$1"; shift
    if ! git fetch -q; then
	echo "Could not fetch origin updates to check if local changed published; cowardly refusing to $ACTION_MSG." >&2
	exit 2
    fi
}
#* <div class="subHeader"><span><code>is_github_clone()</code></span></div>
#* <div class="p">
#*   Looks at the repository's origin URL to determine whether this repo was
#*   cloned from a GitHub repository.
#* </div>
function is_github_clone() {
    ORIGIN_URL=`git config --get remote.origin.url`
    [[ "$ORIGIN_URL" == 'https://github.com'* ]]
}

#* <div class="subHeader"><span><code>ensure_current_branch_committed()</code></span></div>
#* <div class="p">
#*   Checks to see if the current branch is committed and if not, emits error
#*   message and forces the process to exit. Credit to <a
#*   href="http://stackoverflow.com/users/6309/vonc">vonc</a> for his
#*   StackOverflow <a
#*   href="http://stackoverflow.com/questions/3878624/how-do-i-programmatically-determine-if-there-are-uncommited-changes">answer</a>.
#* </div>
function ensure_current_branch_committed() {
    ACTION_MSG="$1"; shift
    # Update the index... I'm curious why the index would be out of sync, but
    # can't hurt and so we follow the original code.
    git update-index -q --ignore-submodules --refresh

    # Check for new files.
    if [ `git ls-files --exclude-standard --others | wc -l` -gt 0 ]; then
	echo "Current branch has unknown files; cowardly refusing $ACTION_MSG." >&2
	exit 1
    fi

    # Check for unstaged changes in tracked files in the working tree.
    if ! git diff-files --quiet --ignore-submodules --; then
        echo "Current branch has unstaged changes; cowardly refusing to $ACTION_MSG." >&2
	exit 1
    fi

    # Cherk for uncommitted changes in the cache.
    if ! git diff-index --cached --quiet HEAD --ignore-submodules --; then
        echo "Current branch has unncommitted changes; cowardly refusing to $ACTION_MSG." >&2
	exit 1
    fi
}

#* <div class="subHeader"><span><code>is_github_configured()</code></span></div>
#* <div class="p">
#*   Checks whether or not the <code>GITHUB_AUTH_TOKEN</code> is configured. If
#*   so, silently returns 0. If not, emits descriptive message to
#*   <code>STDERR</code> and return 1.
#* </div>
function is_github_configured() {
    if [ ! -f $HOME/.git-convey/github ]; then
	echo "Could not find '~/.git-convey/github' configuration necessary to check GitHub" >&2
	echo "connectivity." >&2	    
	return 1
    else
	source $HOME/.git-convey/github
	if [ x"$GITHUB_AUTH_TOKEN" == x"" ]; then
	    echo "GitHub authorization token not defined in '~/.git-convey/github. Cannot" >&2
	    echo "check GitHub connectivity." >&2
	    return 1
	fi
    fi
}

#* </div><!-- #Implementation -->
#*/
