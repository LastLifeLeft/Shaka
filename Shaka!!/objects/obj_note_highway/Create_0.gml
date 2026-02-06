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

show_debug_message($"Note highway created at ({x}, {y}) - Mode: {mode == GAME_MODE.SAMBA ? "SAMBA" : "SHAKATTO"}");