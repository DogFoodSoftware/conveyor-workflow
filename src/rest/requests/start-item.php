<?php
/**
 * <div id="Start-a-Request-Item" class="blurbSummary">
 * <div class="blurbTitle">Start a Request Item</div>
 * <div class="p">
 *   To 'start' a <code>/resources</code> item means to set up the
 *   local environment to begin work on the item. By default, the work
 *   will be advertised and appropriately authorized users may
 *   self-assign the issue as well.
 * </div>
 * <div class="subHeader"><span>Request Spec</span></div>
 * <div class="p">
 * <pre><code>
 * START /requests/:item-id<br />
 * POST  /requests/:item-id?action=START[&amp;...]<br />
 * con requests start :item-id
 * </code></pre>
 *   The <code>:item-id</code> consists of the Conveyor
 *   <code>/projects</code> id followed by an issue identifier (which
 *   is dependent on the <a
 *   href="/documentation/conveyor/workflow/Requests-Resource#Requests-and-Repos">origin
 *   repository associated with the request</a>. E.g.:
 * <pre><code>
 * /dogfoodsoftware.com/conveyor/core/144
 * </code></pre>
 * </div>
 * <table>
 *   <thead><tr><td>Name</td><td>Type</td><td>Description</td></tr></head>
 *   <tbody>
 *     <tr>
 *       <td id="param-advertise"><code>advertise</code></td>
 *       <td>boolean</td>
 *       <td>If true, will attempt to push the local working branch to
 *         the origin repository. Conveyor does not advertise the user
 *         directly, but the information may be accessible through the
 *         origin repository or associated systems. Defaults to
 *         true.</td>
 *     </tr><!-- advertise -->
 *     <tr>
 *       <td id="param-assignee"><code>assignee</code></td>
 *       <td>string (of <code>/users<code> item reference)</td>
 *       <td>User to be assiged to the request. Defaults to the special
 *         <code>/users/self</code>.</td>
 *     </tr><!-- assignee -->
 *     <tr>
 *       <td id="param-branch-qualifier"><code>branch-qualifier</code></td>
 *       <td>string</td>
 *       <td>Qualifier text providing human readable description of
 *         work to be done and distinguishing from parallel work
 *         branches. Defaults to null.</td>
 *     </tr><!-- branch-qualifier -->
 *     <tr>
 *       <td id="param-involved-repos"><code>involved-repos</code></td>
 *       <td>string[] (of repo URLs)</td>
 *       <td>User to be assiged to the request. Defaults to the special
 *         <code>/users/self</code>.</td>
 *     </tr><!-- involved-repos -->
 *     <tr>
 *       <td id="param-source-branch"><code>involved-repos</code></td>
 *       <td>string</td>
 *       <td>Names the source branch to begin work from. The source
 *         branch is assumed to be <code>master</code> if left
 *         unspecified and is generally set in the request definition
 *         if otherwise. The local operator may override, though this
 *         will generate a warning in the merge process and the
 *         changes will be rejected if explanation is not
 *         provided.</td>
 *     </tr><!-- source-branch -->
 *   </tbody>
 * </table>
 * <div class="subHeader"><span>Preconditions</span></div>
 * <div class="p">
 *   The local environment may not be in a production context. It
 *   would be inappropriate to prosecute a request in a production
 *   environment.
 * </div>
 * <div class="p">
 *   In the current implementation, the primary Conveyor and all
 *   involved repositories must be locally cloned before starting an
 *   action. In future versions, the request itself will attempt to
 *   clone any necessary repositories.
 * </div>
 * <div class="p">
 *   The request reference must be resolvable to an issue in the
 *   canonical project repository.
 * </div>
 * <div class="subHeader"><span>Local Setup</span></div>
 * <div class="p">
 *   Local setup always involves setting up a local branch for all
 *   'involved repositories'. The <a
 *   href="/documentation/conveyor/workflow/Requests-Resource#Requests-and-Repos">primary
 *   repository associated with the request</a> is always considered to
 *   be involved. Additional involved repositories are usually defined
 *   in the request, if known before hand. An operator may specify
 *   additional involved repositories in the start request. In the
 *   latter case, a local branch is set up, but the request definition
 *   itself is unchanged. These branches may not ultimately be
 *   committed, but are used by the local system to determine the
 *   requests being <a href="show-active.php">actively prosecuted</a>.
 * </div>
 * <div class="p">
 *   Additional setup may be specified in the request definition. The
 *   current implementation does not go beyond branch management.
 * </div>
 * <div class="subHeader"><span>Advertising Work</span></div>
 * <div class="p">
 *   In order to advertise the work, the
 *   authenticated caller must have privileges to create a branch on
 *   the <a
 *   href="/documentation/conveyor/workflow/Requests-Resource#Requests-and-Repos">primary
 *   repository associated with the request</a>. Unless 
 * </div>
 * <div class="subHeader"><span>Assigning / Reserving the Request</span></div>
 * <div class="p">
 *   A caller with appropriate priviledges may assign an request to
 *   themself. Assigned requests should generally be understood as being
 *   reserved by the assignee. An request may be assigned for many
 *   reasons: exclusive development work, or because there is a
 *   problem with the request. By default, requests are not assigned and
 *   this parameter is null.
 * </div>
 * </div><!-- #Start-a-Request-Item -->
 * <div id="Implementation" class="blurbSummary">
 * <div class="blurbTitle">Implementation</div>
 * <div class="p">
 *   In the current implemntation, which requires that the primary Conveyor 
 *   project repository be locally cloned, we begin by verifying that we 
 *   can locate the repository, along with any secondarily involved 
 *   repositories. Once this is confirmed, we obtain the ultimate origin / 
 *   canonical project repository by following the local origin chain 
 *   (currently, we only support one step) and confirm the existence of the 
 *   issue.
 * </div>
 */
require_once('/home/user/playground/dogfoodsoftware.com/conveyor/core/runnable/lib/conveyor-request-lib.php');

$item_id = get_item_id();
$parameters = get_parameters();
if (PHP_SAPI == "cli") {
    // We will use this in a few places.
    $repo_url = exec('git config --get remote.origin.url', $output = array(), $retval);
    // If the user is working in a cloned repository and the item ID
    // is just a number, we'll assume they mean the request associated
    // with the origin repository.
    if (preg_match('/^\d+$/', $item_id)) {
        if ($retval == 0 && $repo_url != null && trim($repo_url) != "") {
            if (preg_match('|\w+://[\w\.-]*github.com|', $repo_url)) { # The home URL is GitHub.
                $request_path = preg_replace('|\w+://[\w\.-]*github.com(:\d+)?/|', '', $repo_url);
                $request_path = preg_replace('|(.\.git$|', '', $request_path);
                $item_id = "github.com/{$request_path}/{$item_id}";
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

# Verify issue exists. Note: Conveyor deals with 'requests' but most
# project systems deal with 'issues'; our initial targets of GitHub and
# Jira both talk of issues, so we talk of 'repository issues' in the
# backend.  verify_repo_issue_from_requests_item_id($item_id);

$branch_name = 'requests/'.$item_id;
if (isset($parameters['branch-label'])) {
    $branch_name .= '/'.$parameters['branch-label'];
    unset($parameters['branch-label']);
}
# The branch name must conform to the work branch spec so that it
# can be tied to the request.
$bits = explode('/', $branch_name);
$bits_problem = "";
if ('requests' != $bits[0]) {
    $bits_problem = "is missing request qualifier";
}
if (empty($bits_problem) && $bits[1] == 'github.com') { # Github issue ID check
    if (empty($bits[2]) || empty($bits[3]) || empty($bits[4])) {
        $bits_problem = 
            "is missing expected GitHub issue ID: '<owner>/<repo>/<number>'";
    }
    elseif (!preg_match('/^\d+$/', $bits[4])) {
        $bits_problem = "fifth element should be an integer number (got: '".$bits[4]."')";
    }
    if (count($bits) > 6) {
        $bits_problem .= (empty($bits_problem)?"": " and ").
            "has too many path segments; expect five or six for github.com based issues";
    }
}
else {
    $bits_problem = "indicates unsupported issue domain '".$bits[1]."'";
}
if (!empty($bits_problem)) {
    final_result_bad_request("Branch '$branch_name' {$bits_problem}. Should match '/requests/<repo domain>/<repo issue ID segment(s)>[/<optional descriptor>]");
}

/* TODO
if (!isset($parameters['assignee'])) {
    if (PHP_SAPI == "cli") {
        $parameters['assignee'] = 'zanerock';
    }
    else {
        final_result_bad_request("Must specify assignee.");
    }
}
*/

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

if (isset($parameters['involved-repos']) && 
        !is_array($parameters['involved-repos'])) {
    final_result_bad_request('Involved repos found, but not expected array.');
}
/* TODO
if (!isset($parameters['involved-repos'])) {
    // check request text for involved repos
}
*/
require_once('/home/user/playground/dogfoodsoftware.com/conveyor/core/runnable/lib/git-lib.php');
require_once('/home/user/playground/dogfoodsoftware.com/conveyor/core/runnable/lib/git/git-local.php');
if (branch_exists_local("heads/$branch")) {
    final_result_bad_request("Branch '$branch' exists in local repository; bailing out to be safe.");
}
// The remote branch will be checked by the branch create.

branch_create($parameters['primary-repo'], $branch_name);
if (isset($parameters['involved-repos'])) {
    foreach ($parameters['involved-repos'] as $repo) {
        branch_create($repo, $branch_name);
    }
}
?>
<?php /**
</div><!-- .blurbSummary#Implementation -->
*/ ?>
