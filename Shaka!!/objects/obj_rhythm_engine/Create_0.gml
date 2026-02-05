// Highway context (set by game controller or get from obj_note_highway)
highway_context = undefined;

// Chart data (set by game controller)
chart = undefined;

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
next_note_index = 0;  // Index of next note to spawn from chart

// Define callback functions that notes will call
rhythm_engine_report_hit = function(_note, _rating) {
    register_hit(_note, _rating);
}

rhythm_engine_report_miss = function(_note) {
    register_miss(_note);
}

show_debug_message("Rhythm engine created");




start_game = function() {
    if (chart == undefined) {
        show_debug_message("ERROR: Cannot start - no chart loaded!");
        return;
    }
    
    if (highway_context == undefined) {
        show_debug_message("ERROR: Cannot start - no highway context!");
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
    
    show_debug_message("Rhythm engine started!");
    show_debug_message($"Chart: {chart.total_notes} notes, BPM: {chart.bpm}");
}

stop_game = function() {
    is_playing = false;
    
    // Clean up active notes
    for (var i = 0; i < array_length(active_notes); i++) {
        if (instance_exists(active_notes[i])) {
            instance_destroy(active_notes[i]);
        }
    }
    active_notes = [];
    
    show_debug_message("Rhythm engine stopped");
}

spawn_notes_check = function() {
    // Calculate spawn time (notes spawn APPROACH_TIME seconds before hit time)
    var _spawn_time = current_time_ms + (NOTE_APPROACH_TIME * 1000);
    
    // Spawn all notes that are ready
    while (next_note_index < chart.total_notes) {
        var _note_data = chart.notes[next_note_index];
        
        // Check if it's time to spawn this note
        if (_note_data.time_ms <= _spawn_time && !_note_data.spawned) {
            spawn_note(_note_data);
            next_note_index++;
        } else {
            // Notes are sorted by time, so we can stop checking
            break;
        }
    }
}

spawn_note = function(_note_data) {
    // Create the note instance
    var _note = instance_create_depth(0, 0, -100, obj_note);
    
    // Create configuration
    var _config = new NoteInstance(_note_data, highway_context, id);
    
    // Pass config to note
    _note.note_config = _config;
    
    // Mark as spawned
    _note_data.spawned = true;
    
    // Track it
    array_push(active_notes, _note);
    
    show_debug_message($"Spawned note: pos={_note_data.position}, time={_note_data.time_ms}ms");
}

update_active_notes = function() {
    // Check from end to avoid index issues when removing
    for (var i = array_length(active_notes) - 1; i >= 0; i--) {
        var _note = active_notes[i];
        
        // Skip if note doesn't exist (shouldn't happen, but safety check)
        if (!instance_exists(_note)) {
            array_delete(active_notes, i, 1);
            continue;
        }
        
        // Note will check its own deadline and call report_miss if needed
        // We just need to remove destroyed notes from our tracking
        // (This happens automatically when note calls report_miss)
    }
}

register_hit = function(_note, _rating) {
    var _note_data = _note.note_data;
    
    // Mark as hit
    _note_data.hit = true;
    _note_data.rating = _rating;
    
    // Update combo
    if (_rating == NOTE_RATING.MISS) {
        current_combo = 0;
    } else {
        current_combo++;
        max_combo = max(max_combo, current_combo);
        total_notes_hit++;
    }
    
    // Update statistics
    switch (_rating) {
        case NOTE_RATING.PERFECT: perfect_count++; break;
        case NOTE_RATING.GOOD:    good_count++; break;
        case NOTE_RATING.OK:      ok_count++; break;
        case NOTE_RATING.MISS:    miss_count++; break;
    }
    
    // Calculate score
    var _is_double = (_note_data.type == "double");
    var _base_score = get_rating_score(_rating, _is_double);
    var _multiplier = get_combo_multiplier(current_combo);
    var _points = _base_score * _multiplier;
    
    total_score += _points;
    
    // Visual feedback
    last_rating = _rating;
    last_rating_time = current_time;
    
    // Remove from active notes
    var _index = array_get_index(active_notes, _note);
    if (_index >= 0) {
        array_delete(active_notes, _index, 1);
    }
    
    show_debug_message($"Hit registered! Rating: {get_rating_name(_rating)}, " +
                      $"Points: {_points}, Combo: {current_combo}x");
}

register_miss = function(_note) {
    var _note_data = _note.note_data;
    
    // Mark as hit (but with MISS rating)
    _note_data.hit = true;
    _note_data.rating = NOTE_RATING.MISS;
    
    // Reset combo
    current_combo = 0;
    
    // Update statistics
    miss_count++;
    
    // Visual feedback
    last_rating = NOTE_RATING.MISS;
    last_rating_time = current_time;
    
    // Remove from active notes
    var _index = array_get_index(active_notes, _note);
    if (_index >= 0) {
        array_delete(active_notes, _index, 1);
    }
    
    show_debug_message("Note missed!");
}

calculate_final_score = function() {
    var _total_notes = chart.total_notes;
    var _bonus = 0;
    
    // Full Combo Bonus (no misses, combo never broken)
    if (miss_count == 0 && max_combo == _total_notes) {
        _bonus += BONUS_FULL_COMBO;
        show_debug_message("FULL COMBO BONUS: " + string(BONUS_FULL_COMBO));
    }
    // No Miss Bonus (allows OK/Good, but no misses)
    else if (miss_count == 0) {
        _bonus += BONUS_NO_MISS;
        show_debug_message("NO MISS BONUS: " + string(BONUS_NO_MISS));
    }
    
    // Accuracy Bonus (based on perfect note percentage)
    if (_total_notes > 0) {
        var _accuracy = perfect_count / _total_notes;
        var _accuracy_bonus = floor(_accuracy * BONUS_ACCURACY_MAX);
        _bonus += _accuracy_bonus;
        show_debug_message($"ACCURACY BONUS: {_accuracy_bonus} ({_accuracy * 100}%)");
    }
    
    total_score += _bonus;
    
    show_debug_message("=== FINAL RESULTS ===");
    show_debug_message($"Perfect: {perfect_count}");
    show_debug_message($"Good: {good_count}");
    show_debug_message($"OK: {ok_count}");
    show_debug_message($"Miss: {miss_count}");
    show_debug_message($"Max Combo: {max_combo}");
    show_debug_message($"Total Score: {total_score}");
    
    return total_score;
}

check_song_complete = function() {
    // Song is complete when:
    // 1. All notes have been spawned
    // 2. No active notes remain
    return next_note_index >= chart.total_notes && array_length(active_notes) == 0;
}