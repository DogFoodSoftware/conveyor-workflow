<?php
function verify_repo_issue_from_requests_item_id($issue_domain, $issue_path) {
    # At the moment, we only support github for the issue domain.
    if ('api.github.com' == $issue_domain) {
        require_once('/home/user/playground/dogfoodsoftware.com/third-party/pest/runnable/PestJSON.php');
        $pest = new PestJSON("https://".$issue_domain);
        try {
            $issue = $pest->get($issue_path, null, array('User-Agent' => 'DogFoodSoftware/conveyor-core'));
            if (!isset($issue['url'])) {
                ob_start();
                var_dump($issue);
                $issue = ob_get_clean();
                final_result_bad_request("Got suspicious response from github; could not extract issue URL\n".$issue);
            }
            else {
                return build_requests_item_from_github_issue($issue);
            }
        }
        catch (Pest_Exception $e) {
            final_result_bad_request("Cannot complete request; problem contacting gigtub at {$issue_domain}/{$issue_path}: ".$e->getMessage());
        }
    }
    else {
        final_result_bad_request("Cannot resolve /requests item ID '$item_id' to an associated repository.");
    }
}

function build_requests_item_from_github_issue($issue) {
    $request_data = array();

    $request_data['involved-repos'] = array();
    $spec_lines = array();
    preg_match_all('/^\s*involved projects\s*:\s*(.+)$/si',
                   $issue['body'], $spec_lines);
    foreach ($spec_lines[1] as $spec_line) {
        $spec_line = preg_replace('^\s*involved projects\s*:\s*', '', $spec_line);
        array_push($request_data['involved-repos'], preg_split('/\s*,\s*/', $spec_line));
    }

    return $request_data;
}
?>