<?php
function get_next_topics($user) {
    global $user_errors;
    global $user_warnings;
    $next_topics = array();


    if (empty($user['active-projects'])) {
        array_push($user_warnings, "Asked to determine 'next topics', but user has no active projects.");
        return $next_topics;
    }

    return $next_topics;
}
?>