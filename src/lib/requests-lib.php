<?php
function requests_extract_repository_url_from_item_id($item_id) {
    // For now, we only accept GitHub, and the request ID follows the
    // GitHub issue URL: :owner/:repo/issues/:issue-num
    // To this, we simply prepend 'github/'
    if (preg_match('|^/?github/|', $item_id) {
        return preg_replace('|^/?github/|', '', $item_id);
    }
    else {
        final_result_bad_request("Cannot resolve /requests item ID '$item_id' to an associated repository.");
    }
}
?>