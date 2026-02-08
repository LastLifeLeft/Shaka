if (keyboard_check(vk_f2)) {
	draw_set_halign(fa_left);
	draw_set_color(c_white);
	
	var _debug = $"=== INPUT P{player_index + 1} ===\n";
	_debug += $"Offset: {input_offset_ms}ms\n";
	_debug += $"Engine: {instance_exists(rhythm_engine) ? "Connected" : "NOT FOUND"}\n";
	_debug += $"Device: {InputPlayerGetDevice(player_index)}\n";
	_debug += $"Connected: {InputPlayerIsConnected(player_index)}\n";
	_debug += $"Using Gamepad: {InputPlayerUsingGamepad(player_index)}\n\n";
	
	_debug += "Current Inputs:\n";
	if (InputCheck(INPUT_VERB.HIGH_LEFT, player_index))  _debug += "HIGH_LEFT ";
	if (InputCheck(INPUT_VERB.HIGH_MID, player_index))   _debug += "HIGH_MID ";
	if (InputCheck(INPUT_VERB.HIGH_RIGHT, player_index)) _debug += "HIGH_RIGHT ";
	if (InputCheck(INPUT_VERB.LOW_LEFT, player_index))   _debug += "LOW_LEFT ";
	if (InputCheck(INPUT_VERB.LOW_MID, player_index))	_debug += "LOW_MID ";
	if (InputCheck(INPUT_VERB.LOW_RIGHT, player_index))  _debug += "LOW_RIGHT ";
	if (InputCheck(INPUT_VERB.SHAKE, player_index))	  _debug += "SHAKE ";
	
	// Offset debug text for P2
	var _debug_x = (player_index == 0) ? 10 : 350;
	draw_text(_debug_x, 10, _debug);
}