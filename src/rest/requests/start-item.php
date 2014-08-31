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
 *       <td id="param-assign"><code>assign</code></td>
 *       <td>boolean</td>
 *       <td>Indicates whether to attempt to assign the issue to the
 *         current user. Defaults to false.</td>
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
 *   environment. (Not currently enforced.)
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

# TODO: Check 'not production context' precondition

# Check that all the involved repositories are locally cloned.
$config_path = $_SERVER['HOME'].'/.conveyor/config';
if (is_file($config_path)) {
    $matches = array();
    if (preg_match('/CONVEYOR_PLAYGROUND=["\']?([^"\'\s]+)/s',
                   file_get_contents($config_path),
                   $matches)) {
        $conveyor_base = trim($matches[1]);
        if (empty($conveyor_base)) {
            final_result_internal_error("Could not determine Conveyor install; no value for 'CONVEYOR_PLAYGROUND' found in '$config_path'.");
        }
    }
    else {
        final_result_internal_error("Could not determine Conveyor install; '$config_path' does not seem to define 'CONVEYOR_PLAYGROUND'.");
    }
}
else {
    final_result_internal_error("Could not determine Conveyor install location; no '$config_path'.");
}

$item_id = get_item_id();
$parameters = get_parameters(array('advertise' => 'boolean',
                                   'involved_repos[]' => 'url',
                                   'branch_qualifier' => 'string',
                                   'assign' => 'conveyor-rest-id',
                                   'checkout' => 'boolean'));

if (!isset($parameters['advertise'])) {
    $parameters['advertise'] = TRUE;
}

if (PHP_SAPI == "cli") { 

# If the user is working in a Conveyor project dir and provides an
# item ID with a single path element, we will assume that's the issue 
# ID with the backing store for the current repo. We currently only
# support github, which is easy to check, as it's always just a number.
    if (preg_match('/^\d+$/', $item_id)) {
        final_result_internal_error("Contextual request ID reference not currently supported.");
        # - Need library function to give us the 'current project
        #   base', similar to running 'git config --get
        #   remote.origin.url'.
        # - We'll then appen that project ID to the item ID and pass
        #   along for further processing.
        # - Output message if running in verbose mode.
    } # if (preg_match('/^\d+$/', $item_id))
}

# 1) Check the primary repository has been locally cloned.
# 2) Retrieve the issue from the canonical project reposiotry.
# 3) Determine any involved repos.
# 4) Check that all involved repos have been cloned.

# 1) Check the primary repository has been locally cloned.
$path_bits = explode('/', $item_id);
$primary_clone_path = $conveyor_base;
# Note, to avoid confusing directories with the item name, we assume
# the last path element is the 'issue ID' with the backing store. This
# means that issue IDs cannot currently contain '/'. This may or may
# not be acceptable. If we don't know how many path bits are for the
# issue ID, though, we run into problems with identifying where the
# directory processing should end and a directory named '144' could be
# confused with an issue starting with '144'.
$issue_id = $path_bits[count($path_bits) - 1];
for ($i = 0; is_dir($primary_clone_path.'/'.$path_bits[$i]) && $i < count($path_bits) - 1; $i += 1) {
    # Eat empty bits; i.e., deal with 'foo//bar' and treat as 'foo/bar'
    if (!empty($path_bits[$i])) {
        $primary_clone_path .= '/'. $path_bits[$i]; 
    }
}

if (!is_dir($primary_clone_path.'/'.'.git')) {
    final_result_bad_request("Local repo clone path '$primary_clone_path' does not terminate in a (non-bare) git repository.");
}

# 2) Retrieve the issue from the canonical project reposiotry. For
#    this, we must verify that we know how to contact the canonical
#    backing store, which is currently limited to GitHub repos. To do
#    this, we get the canonical project URL and verify a matching
#    issue exists.

$output = array();
$request_store_url = exec("cd $primary_clone_path && git config --get remote.origin.url", $output, $retval);

if ($retval == 0 && !empty($request_store_url)) {
    # Backing store at github?
    if (preg_match('|\w+://[\w\.-]*github.com|', $request_store_url)) {
        $issue_path = preg_replace('|\w+://[\w\.-]*github.com(:\d+)?/|', '', $request_store_url);
        $issue_path = preg_replace('|\.git$|', '', $issue_path);
        // GitHub repo issues URL: :owner/:repo/issues/:issue-num
        $issue_path = "/repos/{$issue_path}/issues/{$issue_id}";
        $issue_domain = 'api.github.com';
    }
    else {
        final_result_bad_request("Origin repository not a supported type.");
    }
}
else {
    final_result_bad_request("Could not determine backing store URL.");
}

# Now we're ready to do the issue verification.
require_once('/home/user/playground/dogfoodsoftware.com/conveyor/workflow/runnable/lib/requests-lib.php');
$request_data = verify_repo_issue_from_requests_item_id($issue_domain, $issue_path);

# 3) Determine any involved repos.
$involved_repos = $request_data['involved-repos'];
if (isset($parameters['involved-repos'])) {
    if (is_array($parameters['involved-repos'])) {
        push_array($involved_repos, $parameters['involved-repos']);
        $involved_repos = array_unique($involved_repos);
    }
    else {
        final_result_bad_request('Involved repos found, but not expected array.');
    }
}

# 4) Check that all involved repos have been cloned.
if (count($involved_repos) > 0) {
    final_result_internal_error("We do not yet support involved repos.");
}

# Okay, now we're ready to do the actual setup, which for now just
# means adding a branch to all involved repos.

$branch_name = 'requests/'.$item_id;
if (!empty($parameters['branch-qualifier'])) {
    $branch_qualifier = $parameters['branch-qualifier'];
}
else {
    final_result_internal_error("We do not currently support implicit branch qualification; add 'branch-qualifier' parameter to request.");
    # Generate small UUID?
}
# The qualifier must not contain 'path elements'.
if (preg_match('|[/\s]|', $branch_qualifier)) {
    final_result_bad_request("Branch qualifier '$branch_qualifier' contains contains illegal '/' or spaces.");
}
$branch_name .= '/'.$branch_qualifier;

if (isset($parameters['assign'])) {
    final_result_intenal_error("We do not yet support setting the assignee.");
}

require_once('/home/user/playground/dogfoodsoftware.com/conveyor/core/runnable/lib/git-lib.php');
require_once('/home/user/playground/dogfoodsoftware.com/conveyor/core/runnable/lib/git/git-local.php');
if (branch_exists_local("heads/$branch_name")) {
    final_result_bad_request("Branch '$branch_name' exists in local repository; bailing out to be safe.");
}
if (branch_exists_local("remotes/origin/$branch_name")) {
    final_result_bad_request("Branch '$branch_name' exists on origin; bailing out to be safe.");
}

branch_create($primary_clone_path, $branch_name);
foreach ($involved_repos as $repo) {
    branch_create($repo, $branch_name);
}

if ($parameters['advertise'] === TRUE ) {
    exec("cd '$primary_clone_path' && git push -q origin '$branch_name'", $output, $retval);
    if ($retval != 0) {
        # TODO: Actually, more of a warning, yeah?
        final_result_internal_error("Could not push branch '$branch_name' to origin repository.");
    }
}

if (!isset($parameters['checkout']) || $parameter['checkout']) {
    branch_checkout($primary_clone_path, $branch_name);
}
?>
<?php /**
</div><!-- .blurbSummary#Implementation -->
*/ ?>
