<?php
function verify_repo_issue_from_requests_item_id($item_id) {
    // For now, we only accept GitHub, and the request ID follows the
    // GitHub issue URL: :owner/:repo/issues/:issue-num
    // To this, we simply prepend 'github/'
    $github_preg = '|^/?github.com/(.+)/(\d+)$|';
    if (preg_match($github_preg, $item_id)) {
        $github_issue_path = preg_replace($github_preg, '/repos/$1/issues/$2', $item_id);
        
        require_once('/home/user/playground/dogfoodsoftware.com/third-party/pest/runnable/PestJSON.php');
        $pest = new PestJSON("https://api.github.com");
        try {
            $issue = $pest->get($github_issue_path, null, array('User-Agent' => 'DogFoodSoftware/conveyor-core'));
            if (!isset($issue['url'])) {
                ob_start();
                var_dump($issue);
                $issue = ob_get_clean();
                final_result_bad_request("Got suspicious response from github; could not extract issue URL\n".$issue);
            }
        }
        catch (Pest_Exception $e) {
            final_result_bad_request("Cannot complete request; problem contacting gigtub: ".$e->getMessage());
        }
    }
    else {
        final_result_bad_request("Cannot resolve /requests item ID '$item_id' to an associated repository.");
    }
}
?>