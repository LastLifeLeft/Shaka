PP.splitview_setup(1, PP_SPLIT.NONE);
PP.splitview_set_view(0, room_width * .5, room_height * .5);
PP.transition_start(-1, PP_TRANSITION.FADE_IN, 0, true);

// Game state machine
game_state = "ready";  // ready → playing → finished

// Chart data
chart = undefined;
chart_path = "";

// Music playback (Vinyl)
music_voice = undefined;
music_pattern = "game_music";

// Timing (master clock)
song_start_time = 0;	  // When song started (real time)
current_time_ms = 0;	  // Current song time (milliseconds)
is_paused = false;
pause_time = 0;
pause_start = 0;

// Game mode
game_mode = GAME_MODE.SHAKATTO;  // Can be changed before starting

// Results
final_score = 0;
results_calculated = false;

// Getting things ready
var _path = working_directory + "charts/demo_chart.json" // Temp test chart.
	
chart_path = _path;
chart = chart_load(_path);
	
if (chart == undefined) {
	show_debug_message("ERROR: Failed to load chart!");
	game_state = "error";
	room_goto(rm_mainmenu)
}
	
show_debug_message($"Chart loaded: {chart.title} by {chart.artist}");
show_debug_message($"BPM: {chart.bpm}, Notes: {chart.total_notes}");

// Create gameplay objects:
highway = instance_create_layer(NOTE_HIGHWAY_WIDTH / 2, NOTE_HIGHWAY_HEIGHT / 2, layer, obj_note_highway, {mode: game_mode});
rhythm_engine = instance_create_depth(0, 0, 0, obj_rhythm_engine, {highway: highway, chart: chart});
input_manager = instance_create_layer(NOTE_HIGHWAY_WIDTH / 2, NOTE_HIGHWAY_HEIGHT / 2, layer, obj_input_manager, {rhythm_engine: rhythm_engine});
	
// Load music if available
if (chart.audio_file != "") {
	var _audio_path = working_directory + "charts/" + chart.audio_file;
		
	VinylSetupExternal(_audio_path, music_pattern, 1.0, 1.0, false, VINYL_NO_MIX);
	VinylSetupBPM(music_pattern, chart.bpm);
	show_debug_message($"Music loaded: {chart.audio_file}");
}


// Game functions :
start_song = function() {
	game_state = "playing";
	
	// Reset timing
	song_start_time = current_time;
	current_time_ms = 0;
	is_paused = false;
	pause_time = 0;
	
	// Start rhythm engine
	rhythm_engine.start_game();
	
	// Start music
	if (music_voice == undefined && chart.audio_file != "") {
		music_voice = VinylPlay(music_pattern);
	}
	
	show_debug_message("Song started!");
}

finish_song = function() {
	game_state = "finished";
	
	// Stop music
	if (music_voice != undefined) {
		VinylStop(music_voice);
	}
	
	// Stop rhythm engine
	rhythm_engine.stop_game();
	
	show_debug_message("Song finished!");
}

toggle_pause = function() {
	if (!is_paused) {
		// Pause
		is_paused = true;
		pause_start = current_time;
		
		// Pause music
		if (music_voice != undefined && VinylIsPlaying(music_voice)) {
			VinylSetPause(music_voice, true);
		}
		
		show_debug_message("Game paused");
	} else {
		show_debug_message("??")
		// Unpause
		is_paused = false;
		pause_time += current_time - pause_start;
		
		// Resume music
		if (music_voice != undefined) {
			VinylResume(music_voice);
		}
		
		show_debug_message("Game resumed");
	}
}


// Temporary draw functions :
draw_loading_ui = function() {
	scribble("[fa_center][c_white]Loading...")
		.draw(NOTE_HIGHWAY_WIDTH / 2, NOTE_HIGHWAY_HEIGHT / 2);
}

draw_ready_ui = function() {
	var _center_x = NOTE_HIGHWAY_WIDTH / 2;
	var _center_y = NOTE_HIGHWAY_HEIGHT / 2;
	
	// Song info
	scribble($"[fa_center][c_white][scale,1.5]{chart.title}\n" +
			 $"[scale,1.0]{chart.artist}\n\n" +
			 $"[c_gray]BPM: {chart.bpm}  |  Notes: {chart.total_notes}")
		.draw(_center_x, _center_y - 60);
	
	// Start prompt
	scribble("[fa_center][c_yellow][pulse]Press Any Key to Start")
		.draw(_center_x, _center_y + 60);
	
	// Controls
	scribble("[fa_center][c_gray][scale,0.8]Q/W/E = High Left/Mid/Right\n" +
			 "A/S/D = Low Left/Mid/Right\n" +
			 "SPACE = Shake\n\n" +
			 "ESC = Back to Menu")
		.draw(_center_x, NOTE_HIGHWAY_HEIGHT - 80);
}

draw_playing_ui = function() {
	// Song progress bar
	if (chart != undefined && chart.total_notes > 0) {
		var _progress = rhythm_engine.next_note_index / chart.total_notes;
		var _bar_width = 200;
		var _bar_x = NOTE_HIGHWAY_WIDTH - _bar_width - 10;
		var _bar_y = NOTE_HIGHWAY_HEIGHT - 30;
		
		// Background
		draw_set_color(c_black);
		draw_set_alpha(0.5);
		draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_width, _bar_y + 10, false);
		
		// Progress
		draw_set_color(c_lime);
		draw_set_alpha(0.8);
		draw_rectangle(_bar_x, _bar_y, _bar_x + (_bar_width * _progress), _bar_y + 10, false);
		
		draw_set_alpha(1.0);
	}
	
	// Pause indicator
	if (is_paused) {
		scribble("[fa_center][c_yellow][pulse][scale,2]PAUSED\n\n" +
				 "[scale,1][c_white]Press ESC to Resume")
			.draw(NOTE_HIGHWAY_WIDTH / 2, NOTE_HIGHWAY_HEIGHT / 2);
	}
}

draw_results_ui = function() {
	var _center_x = NOTE_HIGHWAY_WIDTH / 2;
	var _center_y = NOTE_HIGHWAY_HEIGHT / 2;
	
	// Title
	scribble("[fa_center][c_yellow][scale,2]RESULTS")
		.draw(_center_x, 40);
	
	// Song info
	scribble($"[fa_center][c_white]{chart.title}")
		.draw(_center_x, 80);
	
	// Score
	scribble($"[fa_center][c_lime][scale,1.5]SCORE: {final_score}")
		.draw(_center_x, 120);
	
	// Statistics
	var _stats_y = 160;
	var _line_height = 20;
	
	scribble($"[fa_center][c_lime]Perfect: {rhythm_engine.perfect_count}")
		.draw(_center_x, _stats_y);
	scribble($"[fa_center][c_yellow]Good: {rhythm_engine.good_count}")
		.draw(_center_x, _stats_y + _line_height);
	scribble($"[fa_center][c_orange]OK: {rhythm_engine.ok_count}")
		.draw(_center_x, _stats_y + _line_height * 2);
	scribble($"[fa_center][c_red]Miss: {rhythm_engine.miss_count}")
		.draw(_center_x, _stats_y + _line_height * 3);
	
	// Max combo
	scribble($"[fa_center][c_white]Max Combo: {rhythm_engine.max_combo}x")
		.draw(_center_x, _stats_y + _line_height * 4 + 10);
	
	// Accuracy
	var _total = chart.total_notes;
	var _accuracy = _total > 0 ? (rhythm_engine.total_notes_hit / _total) * 100 : 0;
	scribble($"[fa_center][c_white]Accuracy: {_accuracy}%")
		.draw(_center_x, _stats_y + _line_height * 5 + 10);
	
	// Continue prompt
	scribble("[fa_center][c_gray][pulse]Press Any Key to Continue")
		.draw(_center_x, NOTE_HIGHWAY_HEIGHT - 40);
}

draw_debug_ui = function() {
	draw_set_halign(fa_left);
	draw_set_color(c_white);
	
	var _debug = $"=== GAME CONTROLLER ===\n";
	_debug += $"State: {game_state}\n";
	_debug += $"Time: {current_time_ms / 1000}s\n";
	_debug += $"Paused: {is_paused}\n";
	_debug += $"Mode: {game_mode == GAME_MODE.SAMBA ? "SAMBA" : "SHAKATTO"}\n";
	
	if (chart != undefined) {
		_debug += $"\n=== CHART ===\n";
		_debug += $"Title: {chart.title}\n";
		_debug += $"BPM: {chart.bpm}\n";
		_debug += $"Notes: {chart.total_notes}\n";
	}
	
	if (instance_exists(rhythm_engine)) {
		_debug += $"\n=== ENGINE ===\n";
		_debug += $"Next note: {rhythm_engine.next_note_index}\n";
		_debug += $"Active: {array_length(rhythm_engine.active_notes)}\n";
		_debug += $"Score: {rhythm_engine.total_score}\n";
		_debug += $"Combo: {rhythm_engine.current_combo}x\n";
	}
	
	draw_text(10, 10, _debug);
}

