if (!instance_exists(rhythm_engine)) exit;
if (!instance_exists(obj_game_controller)) exit;
if (obj_game_controller.game_state != "playing") exit;
if (obj_game_controller.is_paused) exit;

// Get current time (with calibration offset)
var _current_time_ms = obj_game_controller.current_time_ms + input_offset_ms;

// Check each position for input
check_position_input(NOTE_POSITION_SHAKATTO.HIGH_LEFT,	INPUT_VERB.HIGH_LEFT	, _current_time_ms);
check_position_input(NOTE_POSITION_SHAKATTO.HIGH_MID,	INPUT_VERB.HIGH_MID		, _current_time_ms);
check_position_input(NOTE_POSITION_SHAKATTO.HIGH_RIGHT, INPUT_VERB.HIGH_RIGHT	, _current_time_ms);
check_position_input(NOTE_POSITION_SHAKATTO.LOW_LEFT,	INPUT_VERB.LOW_LEFT		, _current_time_ms);
check_position_input(NOTE_POSITION_SHAKATTO.LOW_MID,	INPUT_VERB.LOW_MID		, _current_time_ms);
check_position_input(NOTE_POSITION_SHAKATTO.LOW_RIGHT,	INPUT_VERB.LOW_RIGHT	, _current_time_ms);

// Check shake input
check_shake_input(_current_time_ms);