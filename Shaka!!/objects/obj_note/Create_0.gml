// player_index is set via instance creation variable (from rhythm engine)

// Timing (for time-based positioning)
spawn_time_ms = obj_game_manager.current_time_ms;
hit_time_ms = note_data.time_ms;

// Position (calculated from time each frame)
current_distance = 0;

// Visual state
note_color = get_position_color(note_data.position);
note_alpha = 1.0;

// Hit feedback
hit_effect = false;
hit_rating = NOTE_RATING.MISS;
hit_effect_timer = 0;
hit_effect_duration = 15;  // frames

calculate_position_from_time = function(_current_time_ms) {
	var _time_elapsed = _current_time_ms - spawn_time_ms;
	var _total_travel_time = NOTE_APPROACH_TIME * 1000;
	var _progress = _time_elapsed / _total_travel_time;
	_progress = clamp(_progress, 0, 2);
	
	var _start_distance = NOTE_SPAWN_DISTANCE;
	var _end_distance = highway.radius;
	current_distance = lerp(_start_distance, _end_distance, _progress);
}

trigger_hit = function(_rating) {
	if (note_data.hit) return;
	
	hit_effect = true;
	hit_rating = _rating;
	hit_effect_timer = 0;
	
	rhythm_engine.rhythm_engine_report_hit(id, _rating);
	
	show_debug_message($"P{player_index} Note hit! Rating: {get_rating_name(_rating)}");
}