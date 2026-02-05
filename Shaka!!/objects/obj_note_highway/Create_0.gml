// Game mode
mode = GAME_MODE.SAMBA;  // Can be changed to GAME_MODE.SHAKATTO

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

show_debug_message($"Note highway created at ({x}, {y}) - Mode: {mode == GAME_MODE.SAMBA ? "SAMBA" : "SHAKATTO"}");