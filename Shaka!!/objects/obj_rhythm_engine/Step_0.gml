if (!is_playing) exit;
if (chart == undefined) exit;
if (highway_context == undefined) exit;

// Get current time from game controller
if (instance_exists(obj_game_manager)) {
	current_time_ms = obj_game_manager.current_time_ms;
}

// Spawn notes that are ready
spawn_notes_check();

// Update active notes - check for misses
update_active_notes();