switch (game_state) {
	case "ready":
		if (keyboard_check_pressed(vk_anykey) && !keyboard_check(vk_escape)) start_song();
		break;
	case "playing":
		if (!is_paused)
		{
			// Update song time
			current_time_ms = VinylGetTrackPosition(music_voice) * 1000;
	
			// Check if song complete
			if (rhythm_engine.check_song_complete()) {
				finish_song();
			}
	
			// Also check if music finished (if using audio)
			if (music_voice != undefined && !VinylIsPlaying(music_voice)) {
				// Give a bit of buffer time for last notes
				if (array_length(rhythm_engine.active_notes) == 0) {
					finish_song();
				}
			}
		}
		break;
	case "finished":
		if (!results_calculated) {
			final_score = rhythm_engine.calculate_final_score();
			results_calculated = true;
		}
		
		if (keyboard_check_pressed(vk_anykey)) {
			PP.transition_start(-1, PP_TRANSITION.FADE_OUT, {duration: 500000, destination: rm_mainmenu});
		}
		break;
}

// Global pause toggle (ESC)
if (InputPressed(INPUT_VERB.PAUSE)) {
	if (game_state == "ready") {
		// Return to menu
		PP.transition_start(-1, PP_TRANSITION.FADE_OUT, {
			duration: 300000,
			destination: rm_mainmenu
		});
	}
	else
	{
		toggle_pause();
	}
}

// Debug: Skip to results (F12)
if (keyboard_check_pressed(vk_f12) && game_state == "playing") {
	show_debug_message("Debug: Forcing song completion");
	finish_song();
}