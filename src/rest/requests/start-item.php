<?php
/**
 * <div id="Request-Spec" class="blurbSummary">
 * <div class="
 * </div>
 * <div id="Implementation" class="blurbSummary">
 * <div class="blurbTitle">Implementation</div>
 */
require_once('/home/user/playground/dogfoodsoftware.com/conveyor/core/runnable/lib/conveyor-request-lib.php');

extract_request_parameters();

# Verify issue exists.
bar();

$branch_name = 'requests-'.$item_id;
if (isset($parameters['branch-label'])) {
    $branch_name .= '-'.$parameters['branch-label'];
    unset($parameters['branch-label']);
}

if (!isset($parameters['assignee'])) {
    if (PHP_SAPI == "cli") {
        $parameters['assignee'] = 'zanerock';
    }
    else {
        final_result_bad_request("Must specify assignee.");
    }
}

if (!isset($parameters['primary-repo'])) {
    if (PHP_SAPI == "cli") {
        $repo_url = system('git config --get remote.origin.url', $retval);
        if ($retval == 0 && $repo_url != null && trim($repo_url) != "") {
            $parameters['primary-repo'] = $repo_url;
        }
    }
    else {
        final_result_bad_request("Must specify 'primary-repo'.");
    }
}

if (!isset($parameters['additional-repos']) && PHP_SAPI == "cli") {
    # At time of writing, the '-q' only works with '--verify'
    # which requires one parameter so is incompatible with our
    # command here. Thus, we have to redirect expected error (if we
    # are not in a git repo) to /dev/null.
    $repo_path = system('git rev-parse --show-toplevel 2>/dev/null', $retval);
    if ($retval == 0 && $repo_path != null && trim($repo_path) ! "") {
        $parameters['additional-repos'] = array($repo_path);
    }
}

# The branch name must conform to the work branch spec so that it
# can be tied to the request.
foo();

branch_create($parameters['primary-repo'], $branch_name);
foreach ($parameters['additional-repos'] as $repo) {
    branch_create($repo, $branch_name);
}
?>
<?php /**
</div><!-- .blurbSummary#Implementation -->
*/ ?>
