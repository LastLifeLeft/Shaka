// Reference to rhythm engine (set by game controller)
rhythm_engine = noone;

// Input state tracking (prevent double-hits from held keys)
position_pressed = array_create(6, false);
shake_pressed = false;

// Calibration offset (milliseconds to add/subtract from inputs)
// Positive = inputs are early, negative = inputs are late
calibration_offset = 0;

show_debug_message("Input manager created");

/// @function check_position_input(verb, position, time_ms)
/// @description Check if a position was pressed and route to rhythm engine
/// @param {real} verb The INPUT_VERB to check
/// @param {real} position The NOTE_POSITION
/// @param {real} time_ms Current time with calibration
check_position_input = function(_verb, _position, _time_ms) {
    if (InputPressed(_verb) && !position_pressed[_position]) {
        position_pressed[_position] = true;
        process_position_input(_position, _time_ms);
    }
    
    if (InputReleased(_verb)) {
        position_pressed[_position] = false;
    }
}

/// @function process_position_input(position, time_ms)
/// @description Process a position input
/// @param {real} position The NOTE_POSITION
/// @param {real} time_ms Current time
process_position_input = function(_position, _time_ms) {
    if (!instance_exists(rhythm_engine)) return;
    
    // Check if this hit a note
    var _hit = rhythm_engine.check_input_timing(_position, _time_ms);
    
    if (!_hit) {
        // Miss - no note was in range
        show_debug_message($"Input miss at position {_position}");
    }
}

/// @function process_shake_input(time_ms)
/// @description Process a shake input
/// @param {real} time_ms Current time
process_shake_input = function(_time_ms) {
    // For Phase 1, shake is treated like a regular position
    // In later phases, this will handle shake notes differently
    show_debug_message("Shake input detected");
    
    // TODO: Check for shake notes
}

/// @function set_calibration(offset_ms)
/// @description Set calibration offset
/// @param {real} offset_ms Offset in milliseconds
set_calibration = function(_offset_ms) {
    calibration_offset = _offset_ms;
    show_debug_message($"Calibration set to {_offset_ms}ms");
}