// State-specific UI
switch (game_state) {
	case "ready":
		draw_ready_ui();
		break;
		
	case "playing":
		draw_playing_ui();
		break;
		
	case "finished":
		draw_results_ui();
		break;
}

// Debug overlay (F1)
if (keyboard_check(vk_f1)) {
	draw_debug_ui();
}