<?php
function get_next_topics($user) {
    global $home;
    global $user_errors;
    global $user_warnings;
    $next_topics = array();

    if (empty($user['active-projects'])) {
        array_push($user_warnings, "Asked to determine 'next topics', but user has no active projects.");
        return $next_topics;
    }
    // else...
    foreach ($user['active-projects'] as $project) {
        $project_fqn_name = "{$project['domain']}/{$project['name']}";

        if ($project['project-host'] != 'github') {
            array_push($user_errors, "Do not know how to handle project host '{$project['project-host']}' for '{$project_fqn_name}'");
            continue;
        }
        // else...

        require_once("$home/.conveyor/runtime/dogfoodsoftware.com/conveyor-pest/PestJSON.php");
        $pest = new PestJSON("https://api.github.com");
        $milestones = $pest->get("/repos/{$project['project-id']}/milestones",
                                 array('state' => 'open'),
                                 array('user-Agent' => 'DogFoodSoftware/conveyor-workflow'));
        if (empty($milestones)) {
            # TODO: actually, this is OK if there are no open issues.
            array_push($user_warnings, "No milestones found for '{$project_fqn_name}'; skipping.");
            continue;
        }
        // else...
        $ms_names = array_map(function($v) { return $v['title']; }, $milestones);
        $filtered_names = array_filter($ms_names, function($v) { return preg_match('/^v\d+(\.\d)*(-[0-9a-zA-Z])?(pre)?/', $v); });
        if (count($filtered_names) == 0) {
            array_push($user_errors, "Did not find any useable milestones in '{$project_fqn_name}'.");
            continue;
        }
        if (count($ms_names) != count($filtered_names)) {
            array_push($user_warnings, "Unexpected milestone names: ".implode(', ', array_diff($ms_names, $filtered_names)));
        }
        usort($filtered_names, 'version_compare');
        $first_name = $filtered_names[0];
        $top_ms = array_reduce($milestones, function($c, $i) use ($first_name) { return $first_name == $i['title'] ? $i : $c; });

        $issues = $pest->get("/repos/{$project['project-id']}/issues",
                             array("milestone" => $top_ms['number']),
                             array('user-Agent' => 'DogFoodSoftware/conveyor-workflow'));

        array_push($next_topics,
                   array_map(function($v) { return array('title' => $v['title'], 'id' => preg_replace('|https://github.com/|', '', $v['html_url'])); },
                             $issues));
    }

    return $next_topics;
}
?>