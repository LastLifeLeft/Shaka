// Initialize PP Framework for single player
x = room_width * .5;
y = room_height * .5;
PP.splitview_setup(1);
PP.splitview_set_view(0, x, y);

// Load chart
global.current_chart = chart_load(working_directory + "charts/demo_chart.json");

if (global.current_chart == undefined) {
    show_debug_message("ERROR: Failed to load chart!");
    // Create a simple fallback chart for testing
    global.current_chart = new Chart();
    global.current_chart.title = "Test Chart";
    global.current_chart.artist = "Shaka Team";
    global.current_chart.bpm = 120;
    global.current_chart.audio_file = "demo_song.ogg";
}

// Load and setup audio with Vinyl
if (global.current_chart.audio_file != "") {
    var _audio_path = working_directory + "charts/" + global.current_chart.audio_file;
    
    // Check if file exists
    if (file_exists(_audio_path)) {
        // Load external audio (supports .ogg and .wav)
        VinylSetupExternal(_audio_path, "demo_music", 1.0, 1.0, false, VINYL_NO_MIX);
        VinylSetupBPM("demo_music", global.current_chart.bpm);
        
        show_debug_message($"Audio loaded: {_audio_path}");
    } else {
        show_debug_message($"Audio file not found: {_audio_path}");
        show_debug_message("Using manual timing instead");
        
        // Fallback to manual timing
        global.current_chart.audio_file = ""; // Clear it so we know to use manual timing
    }
} else {
    show_debug_message("No audio file specified, using manual timing");
}

// Game state
game_state = "ready";  // ready, playing, paused, finished
music_voice = undefined;
song_start_time = 0;
current_time_ms = 0;

// Create rhythm engine
rhythm_engine = instance_create_depth(0, 0, 0, obj_rhythm_engine);

// Create input manager
input_manager = instance_create_depth(0, 0, 0, obj_input_manager);

show_debug_message("=== SHAKA GAME CONTROLLER INITIALIZED ===");
show_debug_message($"Chart: {global.current_chart.title} by {global.current_chart.artist}");
show_debug_message($"BPM: {global.current_chart.bpm}, Notes: {global.current_chart.total_notes}");

start_song = function() {
    game_state = "playing";
    
    // Reset chart
    global.current_chart.reset();
    
    song_start_time = current_time;
    current_time_ms = 0;
    
    // Start music if available
    if (global.current_chart.audio_file != "") {
        music_voice = VinylPlay("demo_music");
    } else {
        music_voice = undefined; // Manual timing
    }
    
    // Signal rhythm engine to start
    rhythm_engine.start_game();
    
    show_debug_message("Song started!");
}

finish_song = function() {
    game_state = "finished";
    
    // Calculate final score and bonuses
    rhythm_engine.calculate_final_score();
    
    show_debug_message("Song finished!");
    show_debug_message($"Final score: {rhythm_engine.total_score}");
}
