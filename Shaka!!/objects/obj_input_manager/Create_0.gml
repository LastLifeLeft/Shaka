// Player index — set by obj_game_manager at creation
// Input 10 uses this to route to the correct device automatically:
//   Player 0 → Keyboard/Mouse OR Gamepad 0
//   Player 1 → Gamepad 1
// player_index is set via instance creation variable

// Input calibration (can be adjusted per input method)
input_offset_ms = 0;

// Input state tracking (for debug)
last_input_position = -1;
last_input_time = 0;

// Anti-spam (prevent double-hits from one keypress)
input_cooldown_ms = 50;
last_hit_time = array_create(7, 0);  // 6 positions + shake


check_position_input = function(_position, _verb, _current_time_ms) {
	// Input 10 routes to the correct device for this player automatically!
	if (!InputPressed(_verb, player_index)) return;
		
	// Check cooldown (anti-spam)
	if (_current_time_ms - last_hit_time[_position] < input_cooldown_ms) {
		return;
	}
	
	// Find closest note at this position
	var _closest_note = find_closest_note(_position, _current_time_ms);
	
	if (_closest_note != noone) {
		var _time_diff = _current_time_ms - _closest_note.note_data.time_ms;
		var _rating = calculate_note_rating(_time_diff);
		
		if (_rating != NOTE_RATING.MISS) {
			_closest_note.trigger_hit(_rating);
			
			last_hit_time[_position] = _current_time_ms;
			last_input_position = _position;
			last_input_time = _current_time_ms;
			
			show_debug_message($"P{player_index} Hit! Position: {_position}, Rating: {get_rating_name(_rating)}, Diff: {_time_diff}ms");
		} else {
			show_debug_message($"P{player_index} Miss! Position: {_position}, Diff: {_time_diff}ms (outside window)");
		}
	}
}

check_shake_input = function(_current_time_ms) {
	if (!InputPressed(INPUT_VERB.SHAKE, player_index)) return;
	
	// TODO: Implement shake note detection
	show_debug_message($"P{player_index} Shake input detected!");
}

find_closest_note = function(_position, _current_time_ms) {
	var _closest = noone;
	var _closest_diff = TIMING_OK + 1;
	
	for (var i = 0; i < array_length(rhythm_engine.active_notes); i++) {
		var _note = rhythm_engine.active_notes[i];
		
		if (_note.note_data.position != _position) continue;
		if (_note.note_data.hit) continue;
		
		var _time_diff = abs(_current_time_ms - _note.note_data.time_ms);
		
		if (_time_diff <= TIMING_OK && _time_diff < _closest_diff) {
			_closest = _note;
			_closest_diff = _time_diff;
		}
	}
	
	return _closest;
}

set_calibration_offset = function(_offset_ms) {
	input_offset_ms = _offset_ms;
	show_debug_message($"P{player_index} Input calibration offset set to: {_offset_ms}ms");
}