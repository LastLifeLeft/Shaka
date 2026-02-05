switch (game_state) {
    case "loading":
        step_loading();
        break;
        
    case "ready":
        step_ready();
        break;
        
    case "playing":
        step_playing();
        break;
        
    case "finished":
        step_finished();
        break;
}

// Global pause toggle (ESC)
if (keyboard_check_pressed(vk_escape)) {
    if (game_state == "playing") {
        toggle_pause();
    } else if (game_state == "ready") {
        // Return to menu
        PP.transition_start(-1, PP_TRANSITION.FADE_OUT, {
            duration: 300000,
            destination: rm_mainmenu
        });
    }
}

// Debug: Skip to results (F12)
if (keyboard_check_pressed(vk_f12) && game_state == "playing") {
    show_debug_message("Debug: Forcing song completion");
    finish_song();
}