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
#* <div class="subHeader"><span><code>has_branch_local()</code></span></div>
#* <div class="p">
#*   Derived from <a
#*   href="http://stackoverflow.com/users/140185/manoj-govindan">Maanoj
#*   Govindan</a>'s <a
#*   href="http://stackoverflow.com/questions/5167957/is-there-a-better-way-to-find-out-if-a-local-git-branch-exists">post</a>
#*   on StackOverflow.
#* </div>
function has_branch_local() {
    BRANCH_NAME="$1"; shift
    # Recall, if there's no explicit return, the return value of the function
    # is the status of the last command.
    git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"
}

#* <div class="subHeader"><span><code>has_branch_origin()</code></span></div>
#* <div class="p">
#*   Derived from <a
#*   href="http://stackoverflow.com/users/133330/darren">Darren</a>'s <a
#*   href="http://stackoverflow.com/questions/8223906/how-to-check-if-remote-branch-exists-on-a-given-remote-repository">post</a>
#*   on StackOverflow.
#* </div>
function has_branch_origin() {
    BRANCH_NAME="$1"; shift
    # Recall, if there's no explicit return, the return value of the function
    # is the status of the last command.
    git ls-remote --exit-code . "origin/$BRANCH_NAME" &> /dev/null
}
#* </div><!-- #Implementation -->
#*/
