// Chart/Beatmap loader for Shaka
/// @function Chart
/// @description Constructor for a chart/beatmap
function Chart() constructor {
    // Metadata
    title = "Unknown";
    artist = "Unknown";
    bpm = 120;
    offset_ms = 0;
    audio_file = "";
    
    // Notes array
    notes = [];
    
    // Runtime state
    current_note_index = 0;
    total_notes = 0;
    
    /// @function load_from_json(json_string)
    /// @description Load chart from JSON string
    /// @param {string} json_string The JSON data
    static load_from_json = function(_json_string) {
        try {
            var _data = json_parse(_json_string);
            
            // Load metadata
            if (variable_struct_exists(_data, "metadata")) {
                var _meta = _data.metadata;
                
                if (variable_struct_exists(_meta, "title")) title = _meta.title;
                if (variable_struct_exists(_meta, "artist")) artist = _meta.artist;
                if (variable_struct_exists(_meta, "bpm")) bpm = _meta.bpm;
                if (variable_struct_exists(_meta, "offset_ms")) offset_ms = _meta.offset_ms;
                if (variable_struct_exists(_meta, "audio_file")) audio_file = _meta.audio_file;
            }
            
            // Load notes
            if (variable_struct_exists(_data, "notes")) {
                var _notes_array = _data.notes;
                notes = [];
                
                for (var i = 0; i < array_length(_notes_array); i++) {
                    var _note_data = _notes_array[i];
                    
                    var _note = {
                        beat: _note_data.beat,
                        position: _note_data.position,
                        type: _note_data.type,
                        time_ms: 0,  // Will be calculated
                        hit: false,
                        rating: NOTE_RATING.MISS,
                    };
                    
                    // Calculate timing based on BPM
                    // time = (beat / bpm) * 60000 ms + offset
                    _note.time_ms = (_note.beat / bpm) * 60000 + offset_ms;
                    
                    array_push(notes, _note);
                }
                
                total_notes = array_length(notes);
                
                // Sort notes by time
                array_sort(notes, function(_a, _b) {
                    return _a.time_ms - _b.time_ms;
                });
            }
            
            show_debug_message($"Chart loaded: {title} by {artist}");
            show_debug_message($"BPM: {bpm}, Notes: {total_notes}");
            
            return true;
            
        } catch (_error) {
            show_debug_message($"Error loading chart: {_error.message}");
            return false;
        }
    }
    
    /// @function load_from_file(filename)
    /// @description Load chart from file
    /// @param {string} filename Path to chart file
    static load_from_file = function(_filename) {
        if (!file_exists(_filename)) {
            show_debug_message($"Chart file not found: {_filename}");
            return false;
        }
        
        var _file = file_text_open_read(_filename);
        var _json = "";
        
        while (!file_text_eof(_file)) {
            _json += file_text_readln(_file);
        }
        
        file_text_close(_file);
        
        return load_from_json(_json);
    }
    
    /// @function get_next_note(current_time_ms)
    /// @description Get the next note that should spawn
    /// @param {real} current_time_ms Current song time in milliseconds
    /// @return {struct|undefined} Next note or undefined if none
    static get_next_note = function(_current_time_ms) {
        // Account for approach time - spawn notes before they should be hit
        var _spawn_time = _current_time_ms + (NOTE_APPROACH_TIME * 1000);
        
        while (current_note_index < total_notes) {
            var _note = notes[current_note_index];
            
            if (_note.time_ms <= _spawn_time && !_note.spawned) {
                _note.spawned = true;
                current_note_index++;
                return _note;
            } else {
                break;
            }
        }
        
        return undefined;
    }
    
    /// @function reset()
    /// @description Reset chart to beginning
    static reset = function() {
        current_note_index = 0;
        
        // Reset all notes
        for (var i = 0; i < total_notes; i++) {
            notes[i].hit = false;
            notes[i].spawned = false;
            notes[i].rating = NOTE_RATING.MISS;
        }
    }
    
    /// @function get_progress()
    /// @description Get chart completion progress (0 to 1)
    /// @return {real} Progress from 0 to 1
    static get_progress = function() {
        if (total_notes == 0) return 0;
        return current_note_index / total_notes;
    }
}

/// @function chart_load(filename)
/// @description Load a chart from file
/// @param {string} filename Path to chart file
/// @return {Chart|undefined} Loaded chart or undefined if failed
function chart_load(_filename) {
    var _chart = new Chart();
    
    if (_chart.load_from_file(_filename)) {
        return _chart;
    }
    
    return undefined;
}


/// @function get_position_color(position)
/// @description Returns the color for a given position
/// @param {real} position The note position
function get_position_color(_position) {
    switch (_position) {
        case NOTE_POSITION.HIGH_LEFT:   return COLOR_HIGH_LEFT;
        case NOTE_POSITION.HIGH_MID:    return COLOR_HIGH_MID;
        case NOTE_POSITION.HIGH_RIGHT:  return COLOR_HIGH_RIGHT;
        case NOTE_POSITION.LOW_LEFT:    return COLOR_LOW_LEFT;
        case NOTE_POSITION.LOW_MID:     return COLOR_LOW_MID;
        case NOTE_POSITION.LOW_RIGHT:   return COLOR_LOW_RIGHT;
        default:                        return c_white;
    }
}

/// @function get_position_angle(position)
/// @description Returns the angle (in degrees) for a given position
/// @param {real} position The note position
function get_position_angle(_position) {
    // Angles arranged in a circle (0° = right, 90° = up, 180° = left, 270° = down)
    switch (_position) {
        case NOTE_POSITION.HIGH_LEFT:   return 135;  // Upper left
        case NOTE_POSITION.HIGH_MID:    return 90;   // Top
        case NOTE_POSITION.HIGH_RIGHT:  return 45;   // Upper right
        case NOTE_POSITION.LOW_LEFT:    return 225;  // Lower left
        case NOTE_POSITION.LOW_MID:     return 270;  // Bottom
        case NOTE_POSITION.LOW_RIGHT:   return 315;  // Lower right
        default:                        return 0;
    }
}

/// @function get_position_x(position, distance_from_center)
/// @description Returns the X coordinate for a given position at a distance from center
/// @param {real} position The note position
/// @param {real} distance_from_center Distance from center (0 = center, PAD_RADIUS = pad)
function get_position_x(_position, _distance = PAD_RADIUS) {
    var _angle = get_position_angle(_position);
    return CIRCLE_CENTER_X + lengthdir_x(_distance, _angle);
}

/// @function get_position_y(position, distance_from_center)
/// @description Returns the Y coordinate for a given position at a distance from center
/// @param {real} position The note position
/// @param {real} distance_from_center Distance from center (0 = center, PAD_RADIUS = pad)
function get_position_y(_position, _distance = PAD_RADIUS) {
    var _angle = get_position_angle(_position);
    return CIRCLE_CENTER_Y + lengthdir_y(_distance, _angle);
}

/// @function get_combo_multiplier(combo)
/// @description Returns the combo multiplier for a given combo count
/// @param {real} combo Current combo count
function get_combo_multiplier(_combo) {
    if (_combo >= COMBO_TIER4) return 4;
    if (_combo >= COMBO_TIER3) return 3;
    if (_combo >= COMBO_TIER2) return 2;
    return 1;
}

/// @function get_rating_name(rating)
/// @description Returns the string name of a rating
/// @param {real} rating The NOTE_RATING enum value
function get_rating_name(_rating) {
    switch (_rating) {
        case NOTE_RATING.PERFECT: return "PERFECT";
        case NOTE_RATING.GOOD:    return "GOOD";
        case NOTE_RATING.OK:      return "OK";
        case NOTE_RATING.MISS:    return "MISS";
        default:                  return "UNKNOWN";
    }
}

/// @function get_rating_score(rating, is_double)
/// @description Returns the base score for a rating
/// @param {real} rating The NOTE_RATING enum value
/// @param {bool} is_double Whether this is a double note
function get_rating_score(_rating, _is_double) {
    var _base = 0;
    
    switch (_rating) {
        case NOTE_RATING.PERFECT: _base = SCORE_PERFECT; break;
        case NOTE_RATING.GOOD:    _base = SCORE_GOOD; break;
        case NOTE_RATING.OK:      _base = SCORE_OK; break;
        case NOTE_RATING.MISS:    _base = SCORE_MISS; break;
    }
    
    if (_is_double) {
        _base *= SCORE_DOUBLE_MULTIPLIER;
    }
    
    return _base;
}
