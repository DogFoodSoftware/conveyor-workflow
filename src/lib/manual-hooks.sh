# /**
# * <div class="subHeader"><span><code>check_issue_exists()</code></span><div>
# * <div class="p">
# *   In the manual hooks, there is no external check, so the issue in effect
# *   always exists.
# * </div>
function check_issue_exists_for() {
    return 0 # that's bash for true
}

function set_assignee() {
    return 0
}
