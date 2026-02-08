// Player index — set by obj_game_manager at creation
// player_index is set via instance creation variable

// Visual settings
guide_alpha = 0.3;
pad_alpha = 0.6;
center_alpha = 0.4;
beat_pulse_alpha = 0;
beat_pulse_max = 0.6;

// Highway dimensions
highway_radius = PAD_RADIUS;
center_size = 20;
pad_size = NOTE_SIZE * 1.2;

pad_info_array = [];

for (var i = 0; i < 6; i++)
{
	array_push(pad_info_array, [get_position_x(i, highway_radius, x, mode), get_position_y(i, highway_radius, x, mode), get_position_color(i)]);
}

// Labels change based on whether this player is using a gamepad
// These are recalculated each frame in Draw End based on current device
keyboard_labels = ["Q", "W", "E", "A", "S", "D"];
gamepad_labels = ["LB", "Y", "RB", "A", "X", "B"];

show_debug_message($"P{player_index} Note highway created at ({x}, {y}) - Mode: {mode == GAME_MODE.SAMBA ? "SAMBA" : "SHAKATTO"}");