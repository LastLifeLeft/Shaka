/// @function get_position_color(position)
/// @description Returns the color for a given position
/// @param {real} position The note position
function get_position_color(_position) {
	switch (_position) {
		case NOTE_POSITION_SHAKATTO.HIGH_LEFT:		return COLOR_HIGH_LEFT;
		case NOTE_POSITION_SHAKATTO.HIGH_MID:		return COLOR_HIGH_MID;
		case NOTE_POSITION_SHAKATTO.HIGH_RIGHT:		return COLOR_HIGH_RIGHT;
		case NOTE_POSITION_SHAKATTO.LOW_LEFT:		return COLOR_LOW_LEFT;
		case NOTE_POSITION_SHAKATTO.LOW_MID:		return COLOR_LOW_MID;
		case NOTE_POSITION_SHAKATTO.LOW_RIGHT:		return COLOR_LOW_RIGHT;
		default:									return c_white;
	}
}

/// @function get_position_angle(position, mode)
/// @description Returns the angle (in degrees) for a given position
/// @param {real} position The note position
/// @param {real} mode The game mode (GAME_MODE.SAMBA or GAME_MODE.SHAKATTO)
function get_position_angle(_position, _mode = GAME_MODE.SAMBA) {
	// Angles arranged based on mode (0° = right, 90° = up, 180° = left, 270° = down)
	
	if (_mode == GAME_MODE.SAMBA) {
		// SAMBA: Vertical symmetry (left/right mirror)
		 switch (_position) {
			case NOTE_POSITION_SAMBA.HIGH_LEFT:			return 135;
			case NOTE_POSITION_SAMBA.MID_LEFT:			return 180;
			case NOTE_POSITION_SAMBA.LOW_LEFT:			return 225;
			case NOTE_POSITION_SAMBA.HIGH_RIGHT:		return 45; 
			case NOTE_POSITION_SAMBA.MID_RIGHT:			return 0;  
			case NOTE_POSITION_SAMBA.LOW_RIGHT:			return 315;
		}
	} else {
		// SHAKATTO: Horizontal symmetry (top/bottom mirror)
		switch (_position) {
			case NOTE_POSITION_SHAKATTO.HIGH_LEFT:		return 135;  // Upper left
			case NOTE_POSITION_SHAKATTO.HIGH_MID:		return 90;   // Top
			case NOTE_POSITION_SHAKATTO.HIGH_RIGHT:		return 45;   // Upper right
			case NOTE_POSITION_SHAKATTO.LOW_LEFT:		return 225;  // Lower left
			case NOTE_POSITION_SHAKATTO.LOW_MID:		return 270;  // Bottom
			case NOTE_POSITION_SHAKATTO.LOW_RIGHT:		return 315;  // Lower right
			default:									return 0;
		}
	}
}

/// @function get_position_x(position, distance_from_center, center_x, mode)
/// @description Returns the X coordinate for a given position at a distance from center
/// @param {real} position The note position
/// @param {real} distance_from_center Distance from center (0 = center, PAD_RADIUS = pad)
/// @param {real} center_x Center X coordinate (default: CIRCLE_CENTER_X)
/// @param {real} mode Game mode (default: GAME_MODE.SAMBA)
function get_position_x(_position, _distance = PAD_RADIUS, _center_x = CIRCLE_CENTER_X, _mode = GAME_MODE.SAMBA) {
	var _angle = get_position_angle(_position, _mode);
	return _center_x + lengthdir_x(_distance, _angle);
}

/// @function get_position_y(position, distance_from_center, center_y, mode)
/// @description Returns the Y coordinate for a given position at a distance from center
/// @param {real} position The note position
/// @param {real} distance_from_center Distance from center (0 = center, PAD_RADIUS = pad)
/// @param {real} center_y Center Y coordinate (default: CIRCLE_CENTER_Y)
/// @param {real} mode Game mode (default: GAME_MODE.SAMBA)
function get_position_y(_position, _distance = PAD_RADIUS, _center_y = CIRCLE_CENTER_Y, _mode = GAME_MODE.SAMBA) {
	var _angle = get_position_angle(_position, _mode);
	return _center_y + lengthdir_y(_distance, _angle);
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
		case NOTE_RATING.GOOD:	return "GOOD";
		case NOTE_RATING.OK:	  return "OK";
		case NOTE_RATING.MISS:	return "MISS";
		default:				  return "UNKNOWN";
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
		case NOTE_RATING.GOOD:	_base = SCORE_GOOD; break;
		case NOTE_RATING.OK:	  _base = SCORE_OK; break;
		case NOTE_RATING.MISS:	_base = SCORE_MISS; break;
	}
	
	if (_is_double) {
		_base *= SCORE_DOUBLE_MULTIPLIER;
	}
	
	return _base;
}











/// @description Chart/Beatmap loader for Shaka - Updated with Mode & Difficulty Support
/// Loads and parses JSON chart files with multiple difficulty levels

/// @function Chart
/// @description Constructor for a chart/beatmap
function Chart() constructor {
	// Metadata
	title = "Unknown";
	artist = "Unknown";
	bpm = 120;
	offset_ms = 0;
	audio_file = "";
	mode = GAME_MODE.SHAKATTO;  // Default mode
	
	// Difficulty data
	difficulties = {
		easy: undefined,
		normal: undefined,
		hard: undefined,
		crazy: undefined
	};
	
	available_difficulties = [];  // Array of DIFFICULTY enums that exist
	
	// Currently selected difficulty
	current_difficulty = DIFFICULTY.NORMAL;
	
	// Notes array (from selected difficulty)
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
				
				// Load mode
				if (variable_struct_exists(_meta, "mode")) {
					var _mode_str = string_upper(_meta.mode);
					if (_mode_str == "SAMBA") {
						mode = GAME_MODE.SAMBA;
					} else if (_mode_str == "SHAKATTO") {
						mode = GAME_MODE.SHAKATTO;
					}
				}
			}
			
			// Load difficulties
			if (variable_struct_exists(_data, "difficulties")) {
				var _diffs = _data.difficulties;
				
				available_difficulties = [];
				
				// Load Easy
				if (variable_struct_exists(_diffs, "easy")) {
					difficulties.easy = load_difficulty_data(_diffs.easy);
					array_push(available_difficulties, DIFFICULTY.EASY);
				}
				
				// Load Normal
				if (variable_struct_exists(_diffs, "normal")) {
					difficulties.normal = load_difficulty_data(_diffs.normal);
					array_push(available_difficulties, DIFFICULTY.NORMAL);
				}
				
				// Load Hard
				if (variable_struct_exists(_diffs, "hard")) {
					difficulties.hard = load_difficulty_data(_diffs.hard);
					array_push(available_difficulties, DIFFICULTY.HARD);
				}
				
				// Load Crazy
				if (variable_struct_exists(_diffs, "crazy")) {
					difficulties.crazy = load_difficulty_data(_diffs.crazy);
					array_push(available_difficulties, DIFFICULTY.CRAZY);
				}
				
				// Set default difficulty (prefer Normal, fallback to first available)
				if (has_difficulty(DIFFICULTY.NORMAL)) {
					set_difficulty(DIFFICULTY.NORMAL);
				} else if (array_length(available_difficulties) > 0) {
					set_difficulty(available_difficulties[0]);
				}
			}
			
			show_debug_message($"Chart loaded: {title} by {artist}");
			show_debug_message($"Mode: {mode == GAME_MODE.SAMBA ? "SAMBA" : "SHAKATTO"}");
			show_debug_message($"BPM: {bpm}");
			show_debug_message($"Available difficulties: {array_length(available_difficulties)}");
			
			return true;
			
		} catch (_error) {
			show_debug_message($"Error loading chart: {_error.message}");
			return false;
		}
	}
	
	/// @function load_difficulty_data(diff_struct)
	/// @description Parse difficulty data from JSON
	/// @param {struct} diff_struct Difficulty data from JSON
	/// @return {struct} Difficulty data structure
	static load_difficulty_data = function(_diff_struct) {
		var _diff_data = {
			rating: 1,
			notes: []
		};
		
		// Load rating (1-12)
		if (variable_struct_exists(_diff_struct, "rating")) {
			_diff_data.rating = clamp(_diff_struct.rating, RATING_MIN, RATING_MAX);
		}
		
		// Load notes
		if (variable_struct_exists(_diff_struct, "notes")) {
			var _notes_array = _diff_struct.notes;
			
			for (var i = 0; i < array_length(_notes_array); i++) {
				var _note_json = _notes_array[i];
				
				var _note = {
					beat: _note_json.beat,
					position: _note_json.position,
					type: _note_json.type,
					time_ms: 0,  // Will be calculated
					hit: false,
					spawned: false,
					rating: NOTE_RATING.MISS,
				};
				
				// Calculate timing based on BPM
				_note.time_ms = (_note.beat / bpm) * 60000 + offset_ms;
				
				array_push(_diff_data.notes, _note);
			}
			
			// Sort notes by time
			array_sort(_diff_data.notes, function(_a, _b) {
				return _a.time_ms - _b.time_ms;
			});
		}
		
		return _diff_data;
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
	
	/// @function set_difficulty(difficulty)
	/// @description Select which difficulty to use
	/// @param {real} difficulty DIFFICULTY enum value
	/// @return {bool} True if difficulty exists and was set
	static set_difficulty = function(_difficulty) {
		if (!has_difficulty(_difficulty)) {
			show_debug_message($"Difficulty not available: {get_difficulty_name(_difficulty)}");
			return false;
		}
		
		current_difficulty = _difficulty;
		
		// Load notes from selected difficulty
		var _diff_data = get_difficulty_data(_difficulty);
		notes = _diff_data.notes;
		total_notes = array_length(notes);
		
		// Reset playback state
		current_note_index = 0;
		
		show_debug_message($"Difficulty set: {get_difficulty_name(_difficulty)} (Rating: {_diff_data.rating}, Notes: {total_notes})");
		
		return true;
	}
	
	/// @function has_difficulty(difficulty)
	/// @description Check if a difficulty level exists
	/// @param {real} difficulty DIFFICULTY enum value
	/// @return {bool} True if difficulty exists
	static has_difficulty = function(_difficulty) {
		for (var i = 0; i < array_length(available_difficulties); i++) {
			if (available_difficulties[i] == _difficulty) {
				return true;
			}
		}
		return false;
	}
	
	/// @function get_difficulty_data(difficulty)
	/// @description Get difficulty data structure
	/// @param {real} difficulty DIFFICULTY enum value
	/// @return {struct} Difficulty data or undefined
	static get_difficulty_data = function(_difficulty) {
		switch (_difficulty) {
			case DIFFICULTY.EASY: return difficulties.easy;
			case DIFFICULTY.NORMAL: return difficulties.normal;
			case DIFFICULTY.HARD: return difficulties.hard;
			case DIFFICULTY.CRAZY: return difficulties.crazy;
		}
		return undefined;
	}
	
	/// @function get_difficulty_rating(difficulty)
	/// @description Get rating for a specific difficulty
	/// @param {real} difficulty DIFFICULTY enum value (optional, defaults to current)
	/// @return {real} Rating (1-12)
	static get_difficulty_rating = function(_difficulty = current_difficulty) {
		var _data = get_difficulty_data(_difficulty);
		return _data != undefined ? _data.rating : 1;
	}
	
	/// @function reset()
	/// @description Reset chart to beginning
	static reset = function() {
		current_note_index = 0;
		
		// Reset all notes in current difficulty
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

/// @function get_difficulty_name(difficulty)
/// @description Get string name of difficulty
/// @param {real} difficulty DIFFICULTY enum value
/// @return {string} Difficulty name
function get_difficulty_name(_difficulty) {
	switch (_difficulty) {
		case DIFFICULTY.EASY: return "EASY";
		case DIFFICULTY.NORMAL: return "NORMAL";
		case DIFFICULTY.HARD: return "HARD";
		case DIFFICULTY.CRAZY: return "CRAZY";
	}
	return "UNKNOWN";
}

/// @function get_difficulty_color(difficulty)
/// @description Get color for difficulty display
/// @param {real} difficulty DIFFICULTY enum value
/// @return {real} Color
function get_difficulty_color(_difficulty) {
	switch (_difficulty) {
		case DIFFICULTY.EASY: return c_lime;	 // Green
		case DIFFICULTY.NORMAL: return c_yellow;  // Yellow
		case DIFFICULTY.HARD: return c_orange;   // Orange
		case DIFFICULTY.CRAZY: return c_red;	 // Red
	}
	return c_white;
}











/// @function NoteData(beat, position, type)
/// @description Data structure for a note from the chart
/// @param {real} beat Musical beat (e.g., 4.0, 4.5)
/// @param {real} position NOTE_POSITION enum value (0-5)
/// @param {string} type Note type ("normal", "double", "shake")
function NoteData(_beat, _position, _type) constructor {
	beat = _beat;					// Musical beat
	position = _position;			// Which pad (0-5)
	type = _type;					// "normal", "double", "shake"
	time_ms = 0;					 // Calculated from BPM (set by chart loader)
	
	// State tracking
	spawned = false;				 // Has this note been spawned as an instance?
	hit = false;					 // Was this note hit?
	rating = NOTE_RATING.MISS;	   // What rating did it get?
	
	/// @function calculate_time(bpm, offset_ms)
	/// @description Calculate the time_ms from beat and BPM
	static calculate_time = function(_bpm, _offset_ms = 0) {
		time_ms = (beat / _bpm) * 60000 + _offset_ms;
	}
}

/// @function HighwayContext(center_x, center_y, radius, mode)
/// @description Context information about the highway this note belongs to
/// @param {real} center_x X coordinate of highway center
/// @param {real} center_y Y coordinate of highway center
/// @param {real} radius Distance from center to pads
/// @param {real} mode GAME_MODE enum value
function HighwayContext(_center_x, _center_y, _radius, _mode) constructor {
	center_x = _center_x;
	center_y = _center_y;
	radius = _radius;
	mode = _mode;
	
	/// @function get_pad_x(position)
	/// @description Get the X coordinate of a pad
	static get_pad_x = function(_position) {
		return get_position_x(_position, radius, center_x, mode);
	}
	
	/// @function get_pad_y(position)
	/// @description Get the Y coordinate of a pad
	static get_pad_y = function(_position) {
		return get_position_y(_position, radius, center_y, mode);
	}
}

// ============================================================================
// RHYTHM ENGINE → NOTE INTERFACE
// ============================================================================

/// @function note_init(note_instance)
/// @description Initialize a note instance (called by rhythm engine after creation)
/// @param {NoteInstance} note_instance Configuration data
/// 
/// USAGE IN obj_note Create Event:
/// note_config = undefined;  // Will be set by engine
/// 
/// if (note_config != undefined) {
///	 note_init(note_config);
/// }
function note_init(_config) {
	// Store references (called from obj_note)
	note_data = _config.note_data;
	highway = _config.highway;
	rhythm_engine = _config.engine;
	
	// Calculate movement
	current_distance = NOTE_SPAWN_DISTANCE;
	target_distance = highway.radius;
	approach_speed = (target_distance - current_distance) / (NOTE_APPROACH_TIME * game_get_speed(gamespeed_fps));
	
	// Visual setup
	note_color = get_position_color(note_data.position);
	note_alpha = 1.0;
	
	// State
	initialized = true;
}


// ============================================================================
// NOTE → RHYTHM ENGINE INTERFACE
// ============================================================================

/// @function rhythm_engine_report_hit(note_instance, rating)
/// @description Called by obj_note when it gets hit
/// @param {instance} note_instance The note instance reporting
/// @param {real} rating NOTE_RATING enum value
///
/// USAGE IN obj_rhythm_engine:
/// rhythm_engine_report_hit = function(_note, _rating) {
///	 register_hit(_note, _rating);
/// }
function rhythm_engine_report_hit(_note, _rating) {
	// This is called from obj_note to report a hit
	// Implementation in obj_rhythm_engine
	show_debug_message($"Note hit: {get_rating_name(_rating)}");
}

/// @function rhythm_engine_report_miss(note_instance)
/// @description Called when a note passes without being hit
/// @param {instance} note_instance The note instance reporting
///
/// USAGE IN obj_rhythm_engine:
/// rhythm_engine_report_miss = function(_note) {
///	 register_miss(_note);
/// }
function rhythm_engine_report_miss(_note) {
	// This is called from obj_note when it goes past deadline
	// Implementation in obj_rhythm_engine
	show_debug_message("Note missed");
}


// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/// @function note_is_past_deadline(note_distance, pad_radius)
/// @description Check if a note has passed the deadline for hitting
/// @param {real} note_distance Current distance from center
/// @param {real} pad_radius Target pad radius
/// @return {bool} True if past deadline
function note_is_past_deadline(_distance, _radius) {
	var _distance_past = _distance - _radius;
	var _max_miss_distance = (TIMING_OK / 1000) * (_radius / NOTE_APPROACH_TIME);
	return _distance_past > _max_miss_distance;
}

/// @function calculate_note_rating(time_diff_ms)
/// @description Calculate rating based on timing difference
/// @param {real} time_diff_ms Absolute time difference in milliseconds
/// @return {real} NOTE_RATING enum value
function calculate_note_rating(_time_diff) {
	var _abs_diff = abs(_time_diff);
	
	if (_abs_diff <= TIMING_PERFECT) return NOTE_RATING.PERFECT;
	if (_abs_diff <= TIMING_GOOD) return NOTE_RATING.GOOD;
	if (_abs_diff <= TIMING_OK) return NOTE_RATING.OK;
	return NOTE_RATING.MISS;
}
