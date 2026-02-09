// SPLITVIEW SETUP
x = room_width * .5
y = room_height * .5
PP.splitview_setup(1, PP_SPLIT.NONE);
PP.splitview_set_view(0, x, y);
PP.transition_start(-1, PP_TRANSITION.FADE_IN, 0, true);

// GAME STATE
player_count = 2;
game_state = "ready";  // ready → playing → finished

// Chart data (shared between players — same song, same chart)
chart = undefined;
chart_path = "";

// Music playback (Vinyl) — shared, one audio stream
music_voice = undefined;
music_pattern = "game_music";

// Timing (master clock — shared between players)
song_start_time = 0;
current_time_ms = 0;
is_paused = false;
pause_time = 0;
pause_start = 0;

// Game mode
game_mode = GAME_MODE.SHAKATTO;
selected_difficulty = DIFFICULTY.NORMAL;

// Results
final_scores = array_create(player_count, 0);
results_calculated = false;

// PER-PLAYER OBJECT ARRAYS
highways = [];
rhythm_engines = [];
input_managers = [];

// LOAD CHART
chart_path = working_directory + "charts/demo_chart_samba.json";
chart = chart_load(chart_path);
chart.set_difficulty(selected_difficulty);
game_mode = chart.mode;

if (chart == undefined) {
	show_debug_message("ERROR: Failed to load chart!");
	game_state = "error";
	room_goto(rm_mainmenu);
}

show_debug_message($"Chart loaded: {chart.title} by {chart.artist}");
show_debug_message($"BPM: {chart.bpm}, Notes: {chart.total_notes}");

// CREATE PER-PLAYER OBJECTS
var _center_y = room_height * 0.5;
var _width = room_width / player_count

for (var _p = 0; _p < player_count; _p++)
{
	// Each player gets their own highway, rhythm engine, and input manager.
	// They all share the same chart data and master clock.
	var _center_x = (_width * _p) + _width * 0.5;
	
	// Create highway
	var _highway = instance_create_layer(_center_x, _center_y, layer, obj_note_highway, {
		mode: game_mode,
		player_index: _p,
	});
	
	// Each player needs their own copy of chart data for independent scoring/state.
	// Deep-copy the chart so each rhythm engine tracks its own note hit states.
	var _player_chart = variable_clone(chart);
	
	// Create rhythm engine (scoring, note spawning)
	var _engine = instance_create_depth(0, 0, 0, obj_rhythm_engine, {
		highway: _highway,
		chart: _player_chart,
		player_index: _p,
	});
	
	// Create input manager (reads input, matches to notes)
	var _input = instance_create_layer(_center_x, _center_y, layer, obj_samba_input_manager, {
		rhythm_engine: _engine,
		player_index: _p,
	});
	
	// Store references
	array_push(highways, _highway);
	array_push(rhythm_engines, _engine);
	array_push(input_managers, _input);
	
	show_debug_message($"Player {_p} objects created (highway, engine, input)");
}

// LOAD MUSIC (shared — one audio stream for all players)
if (chart.audio_file != "") {
	var _audio_path = working_directory + "charts/" + chart.audio_file;
	VinylSetupExternal(_audio_path, music_pattern, 1.0, 1.0, false, VINYL_NO_MIX);
	VinylSetupBPM(music_pattern, chart.bpm);
	show_debug_message($"Music loaded: {chart.audio_file}");
}

// GAME FUNCTIONS
start_song = function() {
	game_state = "playing";
	
	// Reset timing
	song_start_time = current_time;
	current_time_ms = 0;
	is_paused = false;
	pause_time = 0;
	
	// Start all rhythm engines
	for (var _p = 0; _p < player_count; _p++) {
		rhythm_engines[_p].start_game();
	}
	
	// Start music (one stream)
	if (music_voice == undefined && chart.audio_file != "") {
		music_voice = VinylPlay(music_pattern);
	}
	
	show_debug_message($"Song started! ({player_count} player(s))");
}

finish_song = function() {
	game_state = "finished";
	
	// Stop music
	if (music_voice != undefined) {
		VinylStop(music_voice);
	}
	
	// Stop all rhythm engines
	for (var _p = 0; _p < player_count; _p++) {
		rhythm_engines[_p].stop_game();
	}
	
	show_debug_message("Song finished!");
}

toggle_pause = function() {
	if (!is_paused) {
		is_paused = true;
		pause_start = current_time;
		
		if (music_voice != undefined && VinylIsPlaying(music_voice)) {
			VinylSetPause(music_voice, true);
		}
		show_debug_message("Game paused");
	} else {
		is_paused = false;
		pause_time += current_time - pause_start;
		
		if (music_voice != undefined) {
			VinylResume(music_voice);
		}
		show_debug_message("Game resumed");
	}
}

/// @function check_all_complete()
/// @description Check if all players have finished
check_all_complete = function() {
	for (var _p = 0; _p < player_count; _p++) {
		if (!rhythm_engines[_p].check_song_complete()) return false;
	}
	return true;
}

// TEMPORARY DRAW FUNCTIONS
draw_results_ui = function() {
	// Title
	scribble("[fa_center][c_yellow][scale,2]RESULTS")
		.draw(x, 20);
	
	scribble($"[fa_center][c_white]{chart.title}")
		.draw(x, 55);
	
	if (player_count == 1)
	{
		// --- Single player results ---
		var _engine = rhythm_engines[0];
		var _y = 90;
		
		scribble($"[fa_center][c_lime][scale,1.5]SCORE: {final_scores[0]}")
			.draw(x, _y);
		
		_y += 40;
		scribble($"[fa_center][c_lime]Perfect: {_engine.perfect_count}").draw(x, _y);
		scribble($"[fa_center][c_yellow]Good: {_engine.good_count}").draw(x, _y + 20);
		scribble($"[fa_center][c_orange]OK: {_engine.ok_count}").draw(x, _y + 40);
		scribble($"[fa_center][c_red]Miss: {_engine.miss_count}").draw(x, _y + 60);
		scribble($"[fa_center][c_white]Max Combo: {_engine.max_combo}x").draw(x, _y + 90);
	}
	else
	{
		// --- Two player results (side by side) ---
		var _col_width = NOTE_HIGHWAY_WIDTH / 2;
		
		for (var _p = 0; _p < player_count; _p++)
		{
			var _engine = rhythm_engines[_p];
			var _col_x = _col_width * _p + _col_width / 2;
			var _y = 80;
			
			// Player header
			var _p_color = _p == 0 ? "c_aqua" : "c_fuchsia";
			scribble($"[fa_center][{_p_color}][scale,1.2]PLAYER {_p + 1}").draw(_col_x, _y);
			
			_y += 30;
			scribble($"[fa_center][c_lime][scale,1.3]{final_scores[_p]}").draw(_col_x, _y);
			
			_y += 30;
			scribble($"[fa_center][c_lime]Perfect: {_engine.perfect_count}").draw(_col_x, _y);
			scribble($"[fa_center][c_yellow]Good: {_engine.good_count}").draw(_col_x, _y + 18);
			scribble($"[fa_center][c_orange]OK: {_engine.ok_count}").draw(_col_x, _y + 36);
			scribble($"[fa_center][c_red]Miss: {_engine.miss_count}").draw(_col_x, _y + 54);
			scribble($"[fa_center][c_white]Max Combo: {_engine.max_combo}x").draw(_col_x, _y + 80);
		}
		
		// Winner announcement
		if (final_scores[0] > final_scores[1]) {
			scribble("[fa_center][c_aqua][pulse][scale,1.3]PLAYER 1 WINS!").draw(x, NOTE_HIGHWAY_HEIGHT - 70);
		} else if (final_scores[1] > final_scores[0]) {
			scribble("[fa_center][c_fuchsia][pulse][scale,1.3]PLAYER 2 WINS!").draw(x, NOTE_HIGHWAY_HEIGHT - 70);
		} else {
			scribble("[fa_center][c_yellow][pulse][scale,1.3]IT'S A TIE!").draw(x, NOTE_HIGHWAY_HEIGHT - 70);
		}
	}
	
	// Continue prompt
	scribble("[fa_center][c_gray][pulse]Press Any Key to Continue").draw(x, NOTE_HIGHWAY_HEIGHT - 30);
}