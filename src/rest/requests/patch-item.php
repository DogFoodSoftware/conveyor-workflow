<?php
/**
 * <div class="blurbTitle">Implementation</div>
 */
require_once('/home/user/playground/dogfoodsoftware.com/conveyor/core/runnable/lib/conveyor-request-lib.php');

extract_request_parameters();

# Does the request add a branch?
if (isset($parameters('branch-name'))) {
    # The branch name must conform to the work branch spec so that it
    # can be tied to the request.
    foo();

    # Must define the involved repos.
    if (!isset($parameters['repos'])) {
        final_result_bad_request("Must specify involved repositories with one or more 'repo[]' parameters.")
    }

    foreach ($parameters['repos'] as $repo) {
        branch_create($repo, $branch_name);
    }
} # if (isset($parameters['branch-name']))
?>
<?php /**
</div><!-- .blurbSummary#Implementation -->
*/ ?>
