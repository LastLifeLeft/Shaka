// Active notes (notes currently on screen)
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

// State
is_playing = false;

// Visual feedback
last_rating = NOTE_RATING.MISS;
last_rating_time = 0;
rating_display_duration = 30;  // frames

show_debug_message("Rhythm engine created");


start_game = function() {
    is_playing = true;
    
    // Reset stats
    total_score = 0;
    current_combo = 0;
    max_combo = 0;
    perfect_count = 0;
    good_count = 0;
    ok_count = 0;
    miss_count = 0;
    
    show_debug_message("Rhythm engine started");
}

spawn_note = function(_note_data) {
    var _note_obj = instance_create_depth(0, 0, -100, obj_note);
    _note_obj.note_data = _note_data;
    _note_obj.rhythm_engine = id;
    
    array_push(active_notes, _note_obj);
}

check_input_timing = function(_position, _current_time_ms) {
    var _best_rating = NOTE_RATING.MISS;
    var _best_note = undefined;
    var _best_diff = infinity;
    
    // Find the closest note in this position that hasn't been hit
    for (var i = 0; i < array_length(active_notes); i++) {
        var _note_obj = active_notes[i];
        var _note = _note_obj.note_data;
        
        if (_note.hit) continue;
        if (_note.position != _position) continue;
        
        var _time_diff = abs(_current_time_ms - _note.time_ms);
        
        // Must be within OK window
        if (_time_diff > TIMING_OK) continue;
        
        // Track the closest note
        if (_time_diff < _best_diff) {
            _best_diff = _time_diff;
            _best_note = _note_obj;
            
            // Determine rating
            if (_time_diff <= TIMING_PERFECT) {
                _best_rating = NOTE_RATING.PERFECT;
            } else if (_time_diff <= TIMING_GOOD) {
                _best_rating = NOTE_RATING.GOOD;
            } else {
                _best_rating = NOTE_RATING.OK;
            }
        }
    }
    
    // Register the hit
    if (_best_note != undefined) {
        register_hit(_best_note, _best_rating);
        return true;
    }
    
    return false;
}

register_hit = function(_note_obj, _rating) {
    var _note = _note_obj.note_data;
    
    // Mark as hit
    _note.hit = true;
    _note.rating = _rating;
    
    // Update combo
    if (_rating == NOTE_RATING.MISS) {
        current_combo = 0;
    } else {
        current_combo++;
        max_combo = max(max_combo, current_combo);
    }
    
    // Update statistics
    switch (_rating) {
        case NOTE_RATING.PERFECT: perfect_count++; break;
        case NOTE_RATING.GOOD:    good_count++; break;
        case NOTE_RATING.OK:      ok_count++; break;
        case NOTE_RATING.MISS:    miss_count++; break;
    }
    
    // Calculate score
    var _is_double = (_note.type == "double");
    var _base_score = get_rating_score(_rating, _is_double);
    var _multiplier = get_combo_multiplier(current_combo);
    var _points = _base_score * _multiplier;
    
    total_score += _points;
    
    // Visual feedback
    last_rating = _rating;
    last_rating_time = current_time;
    
    // Create hit effect
    _note_obj.hit_effect = true;
    _note_obj.hit_rating = _rating;
    
    show_debug_message($"Hit! Rating: {get_rating_name(_rating)}, " +
                      $"Points: {_points}, Combo: {current_combo}x");
}

calculate_final_score = function() {
    var _total_notes = global.current_chart.total_notes;
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
}