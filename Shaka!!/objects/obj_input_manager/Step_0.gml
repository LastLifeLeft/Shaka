// Find rhythm engine if not set
if (!instance_exists(rhythm_engine)) {
    rhythm_engine = instance_find(obj_rhythm_engine, 0);
}

if (!instance_exists(rhythm_engine)) exit;
if (!instance_exists(obj_game_controller)) exit;

var _controller = obj_game_controller;

// Only process input during gameplay
if (_controller.game_state != "playing") exit;

// Get current time with calibration offset
var _time_ms = _controller.current_time_ms + calibration_offset;

// Check each position
check_position_input(INPUT_VERB.HIGH_LEFT, NOTE_POSITION.HIGH_LEFT, _time_ms);
check_position_input(INPUT_VERB.HIGH_MID, NOTE_POSITION.HIGH_MID, _time_ms);
check_position_input(INPUT_VERB.HIGH_RIGHT, NOTE_POSITION.HIGH_RIGHT, _time_ms);
check_position_input(INPUT_VERB.LOW_LEFT, NOTE_POSITION.LOW_LEFT, _time_ms);
check_position_input(INPUT_VERB.LOW_MID, NOTE_POSITION.LOW_MID, _time_ms);
check_position_input(INPUT_VERB.LOW_RIGHT, NOTE_POSITION.LOW_RIGHT, _time_ms);

// Check shake
if (InputPressed(INPUT_VERB.SHAKE) && !shake_pressed) {
    shake_pressed = true;
    process_shake_input(_time_ms);
}

if (InputReleased(INPUT_VERB.SHAKE)) {
    shake_pressed = false;
}