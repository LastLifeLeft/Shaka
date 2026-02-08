// Player index — set by obj_game_manager at creation
// player_index is set via instance creation variable

// Highway context (set by game manager)
highway_context = new HighwayContext(highway.x, highway.y, highway.highway_radius, highway.mode);

// Active notes tracking
active_notes = [];

// Scoring state
total_score = 0;
current_combo = 0;
max_combo = 0;

// Statistics
perfect_count = 0;
good_count = 0;
ok_count = 0;
miss_count = 0;
total_notes_hit = 0;

// Visual feedback
last_rating = NOTE_RATING.MISS;
last_rating_time = 0;
rating_display_duration = 30;  // frames

// State
is_playing = false;
current_time_ms = 0;
next_note_index = 0;

// Define callback functions that notes will call
rhythm_engine_report_hit = function(_note, _rating) {
	register_hit(_note, _rating);
}

rhythm_engine_report_miss = function(_note) {
	register_miss(_note);
}


start_game = function() {
	if (chart == undefined) {
		show_debug_message($"P{player_index} ERROR: Cannot start - no chart loaded!");
		return;
	}
	
	if (highway_context == undefined) {
		show_debug_message($"P{player_index} ERROR: Cannot start - no highway context!");
		return;
	}
	
	is_playing = true;
	
	// Reset stats
	total_score = 0;
	current_combo = 0;
	max_combo = 0;
	perfect_count = 0;
	good_count = 0;
	ok_count = 0;
	miss_count = 0;
	total_notes_hit = 0;
	
	// Reset chart
	next_note_index = 0;
	chart.reset();
	
	// Clear any existing notes
	for (var i = 0; i < array_length(active_notes); i++) {
		if (instance_exists(active_notes[i])) {
			instance_destroy(active_notes[i]);
		}
	}
	active_notes = [];
	
	show_debug_message($"P{player_index} Rhythm engine started!");
	show_debug_message($"P{player_index} Chart: {chart.total_notes} notes, BPM: {chart.bpm}");
}

stop_game = function() {
	is_playing = false;
	
	for (var i = 0; i < array_length(active_notes); i++) {
		if (instance_exists(active_notes[i])) {
			instance_destroy(active_notes[i]);
		}
	}
	active_notes = [];
	
	show_debug_message($"P{player_index} Rhythm engine stopped");
}

spawn_notes_check = function() {
	var _spawn_time = current_time_ms + (NOTE_APPROACH_TIME * 1000);
	
	while (next_note_index < chart.total_notes) {
		var _note_data = chart.notes[next_note_index];
		
		if (_note_data.time_ms <= _spawn_time && !_note_data.spawned) {
			spawn_note(_note_data);
			next_note_index++;
		} else {
			break;
		}
	}
}

spawn_note = function(_note_data) {
	var _note = instance_create_depth(0, 0, -100, obj_note, {
		note_data: _note_data,
		highway: highway_context,
		rhythm_engine: id,
		player_index: player_index,
	});
	
	_note_data.spawned = true;
	array_push(active_notes, _note);
}

update_active_notes = function() {
	for (var i = array_length(active_notes) - 1; i >= 0; i--) {
		var _note = active_notes[i];
		
		if (!instance_exists(_note)) {
			array_delete(active_notes, i, 1);
			continue;
		}
	}
}

register_hit = function(_note, _rating) {
	var _note_data = _note.note_data;
	
	_note_data.hit = true;
	_note_data.rating = _rating;
	
	if (_rating == NOTE_RATING.MISS) {
		current_combo = 0;
	} else {
		current_combo++;
		max_combo = max(max_combo, current_combo);
		total_notes_hit++;
	}
	
	switch (_rating) {
		case NOTE_RATING.PERFECT: perfect_count++; break;
		case NOTE_RATING.GOOD:	good_count++; break;
		case NOTE_RATING.OK:	  ok_count++; break;
		case NOTE_RATING.MISS:	miss_count++; break;
	}
	
	var _is_double = (_note_data.type == "double");
	var _base_score = get_rating_score(_rating, _is_double);
	var _multiplier = get_combo_multiplier(current_combo);
	var _points = _base_score * _multiplier;
	
	total_score += _points;
	
	last_rating = _rating;
	last_rating_time = current_time;
	
	var _index = array_get_index(active_notes, _note);
	if (_index >= 0) {
		array_delete(active_notes, _index, 1);
	}
	
	show_debug_message($"P{player_index} Hit! Rating: {get_rating_name(_rating)}, " +
					  $"Points: {_points}, Combo: {current_combo}x");
}

register_miss = function(_note) {
	var _note_data = _note.note_data;
	
	_note_data.hit = true;
	_note_data.rating = NOTE_RATING.MISS;
	
	current_combo = 0;
	miss_count++;
	
	last_rating = NOTE_RATING.MISS;
	last_rating_time = current_time;
	
	var _index = array_get_index(active_notes, _note);
	if (_index >= 0) {
		array_delete(active_notes, _index, 1);
	}
	
	show_debug_message($"P{player_index} Note missed!");
}

calculate_final_score = function() {
	var _total_notes = chart.total_notes;
	var _bonus = 0;
	
	if (miss_count == 0 && max_combo == _total_notes) {
		_bonus += BONUS_FULL_COMBO;
		show_debug_message($"P{player_index} FULL COMBO BONUS: {BONUS_FULL_COMBO}");
	}
	else if (miss_count == 0) {
		_bonus += BONUS_NO_MISS;
		show_debug_message($"P{player_index} NO MISS BONUS: {BONUS_NO_MISS}");
	}
	
	if (_total_notes > 0) {
		var _accuracy = perfect_count / _total_notes;
		var _accuracy_bonus = floor(_accuracy * BONUS_ACCURACY_MAX);
		_bonus += _accuracy_bonus;
		show_debug_message($"P{player_index} ACCURACY BONUS: {_accuracy_bonus} ({_accuracy * 100}%)");
	}
	
	total_score += _bonus;
	
	show_debug_message($"=== P{player_index} FINAL RESULTS ===");
	show_debug_message($"Perfect: {perfect_count}");
	show_debug_message($"Good: {good_count}");
	show_debug_message($"OK: {ok_count}");
	show_debug_message($"Miss: {miss_count}");
	show_debug_message($"Max Combo: {max_combo}");
	show_debug_message($"Total Score: {total_score}");
	
	return total_score;
}

check_song_complete = function() {
	return next_note_index >= chart.total_notes && array_length(active_notes) == 0;
}