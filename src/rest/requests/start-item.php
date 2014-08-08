<?php
/**
 * <div id="Start-a-Request-Item" class="blurbSummary">
 * <div class="blurbTitle">Start a Request Item</div>
 * <pre><code>
 * START /requests/:item-id<br />
 * POST  /requests/:item-id?action=START[&amp;...]<br />
 * con requests start :item-id
 * </code></pre>
 * <div class="p">
 *   'Starting' a request prepares the staging repo (typically, the
 *   current working director in the CLI context) to begin work on the
 *   request, along with any associated repositories specified in the
 *   <code>/request</code> item data or by the <code>START</code> API
 *   request. The caller must have privileges to create a branch on
 *   the <a
 *   href="/documentation/conveyor/workflow/Requests-Resource#Requests-and-Repos">primary
 *   repository associated with the issue</a>. The issue may
 *   optionally be assigned to a user in the same step.
 * </div>
 * <div class="subHeader"><span>Input</span></div>
 * <table>
 *   <thead><tr><td>Name</td><td>Type</td><td>Description</td></tr></head>
 *   <tbody>
 *     <tr>
 *       <td>branch-qualifier</td>
 *       <td>string</td>
 *       <td>Qualifier text providing human readable description of
 *         work to be done and distinguishing from parallel work
 *         branches.</td>
 *     </tr><!-- branch-qualifier -->
 *     <tr>
 *       <td>assignee</td>
 *       <td><code>/users<code> item reference</td>
 *       <td>User to be assiged to the issue. Defaults to the special
 *         <code>/users/self</code>.</td>
 *     </tr><!-- assignee -->
 *   </tbody>
 * </table>
 * </div><!-- #Start-a-Request-Item -->
 * <div id="Implementation" class="blurbSummary">
 * <div class="blurbTitle">Implementation</div>
 */
require_once('/home/user/playground/dogfoodsoftware.com/conveyor/core/runnable/lib/conveyor-request-lib.php');

$item_id = get_item_id();
$parameters = get_parameters();
if (PHP_SAPI == "cli") {
    // We will use this in a few places.
    $repo_url = exec('git config --get remote.origin.url', $output = array(), $retval);
    // If the user is working in a cloned repository and the item ID
    // is just a number, we'll assume they mean the issue associated
    // with the origin repository.
    if (preg_match('/^\d+$/', $item_id)) {
        if ($retval == 0 && $repo_url != null && trim($repo_url) != "") {
            if (preg_match('|\w+://[\w\.-]*github.com|', $repo_url)) { # The home URL is GitHub.
                $issue_path = preg_replace('|\w+://[\w\.-]*github.com(:\d+)?/|', '', $repo_url);
                $issue_path = preg_replace('|(.\.git$|', '', $issue_path);
                $item_id = "github/{$issue_path}/{$item_id}";
            }
            else {
                final_result_bad_request("Could not identify current working repository origin as a type we can construct the /requests URL. Please change working directory provide full /requests item ID.");
            }
        }
        else {
            final_result_bad_request("Could not determine working repository to associate with /requests item. Please change working direcotry or provide full /requests item ID.");
        }
    } # if (preg_match('/^\d+$/', $item_id))
    # else assume it's a full /requests ID
}

require_once('/home/user/playground/dogfoodsoftware.com/conveyor/workflow/runnable/lib/requests-lib.php');

# Verify issue exists.
$repo_url = requests_extract_url_repository_from_item_id($item_id);
foo();

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
        if ($repo_url != null && trim($repo_url) != "") {
            $parameters['primary-repo'] = $repo_url;
        }
        else {
            final_result_bad_request("Parameter 'primary-repo' was not specified and cannot be automatically determined.");
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
    $repo_path = exec('git rev-parse --show-toplevel 2>/dev/null', $output = array(), $retval);
    if ($retval == 0 && $repo_path != null && trim($repo_path) != "") {
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
