<?php

Rewrite to just do it; we will redirect here from the POST handler, not the other way around. This allows us to do multi-step activities with one call rather than reduce everything to a series of transitions, which is too limiting.

/**
 * <div class="blurbTitle">Implementation</div>
 */
require_once('/home/user/playground/dogfoodsoftware.com/conveyor/core/runnable/lib/conveyor-request-lib.php');

extract_request_parameters();

$branch_name = 'requests-'.$item_id;
if (isset($parameters['branch-label'])) {
    $branch_name .= '-'.$parameters['branch-label'];
    unset($parameters['branch-label']);
}
$parameters['branch-name'] = $branch_name;

if (!isset($parameters['assignee'])) {
    if (PHP_SAPI == "cli") {
        $parameters['assignee'] = 'zanerock';
    }
    else {
        invalid_request();
    }
}
if (!isset($parameters['repo'])) {
    if (PHP_SAPI == "cli") {
        # Then we check that the current working directory is a within a
        # local git repo and add that and the origin repo to the
        # request.

        # At time of writing, the '-q' only works with '--verify'
        # which requires one parameter so is incompatible with our
        # command here. Thus, we have to redirect expected error (if we
        # are not in a git repo) to /dev/null.
        $path = system('git rev-parse --show-toplevel 2>/dev/null', $retval);
        if ($retval != 0 || $path == null || trim($path) == "") {
            final_result_bad_request("Must either explicitly specify repos with one or more 'repo[]' parameters or execute command from a git repository.");
        }
        # else '$path' retrieved.
        $origin_url = system('git config --get remote.origin.url', $retval);
        if ($retval != 0 || $origin_url == null || trim($origin_url) == "") {
            final_result_bad_request("Local git repo '$path' has no 'origin URL' configured; cannot proceed with request.");
        }
        # else, good to go
        $parameters['repo'] = array($path, $origin_url);
    }
    # else if not operating in a CLI context, then we can leave it to
    # the PATCH to handle problems.
}
require("patch-item.php");
?>
<?php /**
</div><!-- .blurbSummary#Implementation -->
*/ ?>
