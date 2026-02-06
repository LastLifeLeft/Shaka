if (keyboard_check(vk_f2)) {
	draw_set_halign(fa_left);
	draw_set_color(c_white);
	
	var _debug = "=== INPUT MANAGER ===\n";
	_debug += $"Offset: {input_offset_ms}ms\n";
	_debug += $"Engine: {instance_exists(rhythm_engine) ? "Connected" : "NOT FOUND"}\n\n";
	
	_debug += "Current Inputs:\n";
	if (InputCheck(INPUT_VERB.HIGH_LEFT)) _debug += "Q (HIGH LEFT) ";
	if (InputCheck(INPUT_VERB.HIGH_MID)) _debug += "W (HIGH MID) ";
	if (InputCheck(INPUT_VERB.HIGH_RIGHT)) _debug += "E (HIGH RIGHT) ";
	if (InputCheck(INPUT_VERB.LOW_LEFT)) _debug += "A (LOW LEFT) ";
	if (InputCheck(INPUT_VERB.LOW_MID)) _debug += "S (LOW MID) ";
	if (InputCheck(INPUT_VERB.LOW_RIGHT)) _debug += "D (LOW RIGHT) ";
	if (InputCheck(INPUT_VERB.SHAKE)) _debug += "SPACE (SHAKE) ";
	
	draw_text(400, 10, _debug);
}