// Handle pause
if (InputPressed(INPUT_VERB.PAUSE)) {
    if (game_state == "playing") {
        game_state = "paused";
        VinylSetPause(music_voice, true);
    } else if (game_state == "paused") {
        game_state = "playing";
        VinylSetPause(music_voice, false);
    }
}

// Handle back to menu
if (InputPressed(INPUT_VERB.CANCEL)) {
    room_goto(rm_menu);
}

// State machine
switch (game_state) {
    case "ready":
        // Wait for any input to start
        if (keyboard_check_pressed(vk_anykey) || gamepad_button_check_pressed(0, gp_face1)) {
            start_song();
        }
        break;
        
	case "playing":
	    // Update song time
	    if (music_voice != undefined && VinylIsPlaying(music_voice)) {
	        // Use Vinyl's track position
	        current_time_ms = VinylGetTrackPosition(music_voice) * 1000;
	    } else {
	        // Manual timing fallback
	        current_time_ms = current_time - song_start_time;
	    }
    
	    // Check if song finished
	    if (music_voice != undefined && !VinylIsPlaying(music_voice)) {
	        finish_song();
	    } else if (music_voice == undefined) {
	        // Manual end check - after last note + 5 seconds
	        var _last_note_time = global.current_chart.notes[global.current_chart.total_notes - 1].time_ms;
	        if (current_time_ms > _last_note_time + 5000) {
	            finish_song();
	        }
	    }
	    break;
        
    case "paused":
        // Do nothing, waiting for unpause
        break;
        
    case "finished":
        // Show results, wait for input to continue
        if (keyboard_check_pressed(vk_anykey) || gamepad_button_check_pressed(0, gp_face1)) {
            room_goto(rm_menu);
        }
        break;
}