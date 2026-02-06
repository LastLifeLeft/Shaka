// Get current song time from game controller
var _current_time_ms = 0;
if (instance_exists(obj_game_manager)) {
	_current_time_ms = obj_game_manager.current_time_ms;
}

// Calculate position based on TIME (not frames!)
// This ensures notes stay synced with music even if frames drop
calculate_position_from_time(_current_time_ms);

// Update hit effect
if (hit_effect) {
	hit_effect_timer++;
	
	if (hit_effect_timer >= hit_effect_duration) {
		instance_destroy();
		exit;
	}
}

// Check if past deadline (only if not already hit)
if (!note_data.hit && note_is_past_deadline(current_distance, highway.radius)) {
	// Report miss and destroy
	rhythm_engine.rhythm_engine_report_miss(id);
	instance_destroy();
	exit;
}