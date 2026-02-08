switch (game_state) {
	case "ready":
		if (keyboard_check_pressed(vk_anykey) && !keyboard_check(vk_escape)) start_song();
		break;
	case "playing":
		if (!is_paused)
		{
			// Update song time (master clock — shared by all players)
			current_time_ms = VinylGetTrackPosition(music_voice) * 1000;
	
			// Check if all players have finished
			if (check_all_complete()) {
				finish_song();
			}
	
			// Also check if music finished
			if (music_voice != undefined && !VinylIsPlaying(music_voice)) {
				var _all_empty = true;
				for (var _p = 0; _p < player_count; _p++) {
					if (array_length(rhythm_engines[_p].active_notes) > 0) {
						_all_empty = false;
						break;
					}
				}
				if (_all_empty) finish_song();
			}
		}
		break;
	case "finished":
		if (!results_calculated) {
			for (var _p = 0; _p < player_count; _p++) {
				final_scores[_p] = rhythm_engines[_p].calculate_final_score();
			}
			results_calculated = true;
		}
		
		if (keyboard_check_pressed(vk_anykey)) {
			PP.transition_start(-1, PP_TRANSITION.FADE_OUT, {duration: 500000, destination: rm_mainmenu});
		}
		break;
}

// Global pause toggle — Player 0 controls pause
if (InputPressed(INPUT_VERB.PAUSE, 0)) {
	if (game_state == "ready") {
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

// Player 2 can also pause
if (player_count >= 2 && InputPressed(INPUT_VERB.PAUSE, 1)) {
	if (game_state == "playing") {
		toggle_pause();
	}
}

// Debug: Skip to results (F12)
if (keyboard_check_pressed(vk_f12) && game_state == "playing") {
	show_debug_message("Debug: Forcing song completion");
	finish_song();
}
