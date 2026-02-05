if (note_config != undefined && !initialized) {
	note_data = note_config.note_data;
	highway = note_config.highway;
	rhythm_engine = note_config.engine;
    
	// Get current time
	if (instance_exists(obj_game_controller)) {
		spawn_time_ms = obj_game_controller.current_time_ms;
	}
    
	// Store hit time
	hit_time_ms = note_data.time_ms;
    
	// Visual setup
	note_color = get_position_color(note_data.position);
	note_alpha = 1.0;
    
	// Mark as initialized
	initialized = true;
}