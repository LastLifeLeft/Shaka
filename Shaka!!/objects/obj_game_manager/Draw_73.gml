// State-specific UI
switch (game_state) {
	case "ready":
			var _center_x = NOTE_HIGHWAY_WIDTH / 2;
			var _center_y = NOTE_HIGHWAY_HEIGHT / 2;
	
			// Song info
			scribble($"[fa_center][c_white][scale,1.5]{chart.title}\n" +
					 $"[scale,1.0]{chart.artist}\n\n" +
					 $"[c_gray]BPM: {chart.bpm}  |  Notes: {chart.total_notes}")
				.draw(_center_x, _center_y - 60);
	
			// Player count info
			var _player_text = player_count >= 2 ? "[c_aqua]2 PLAYERS" : "[c_white]1 PLAYER";
			scribble($"[fa_center]{_player_text}")
				.draw(_center_x, _center_y + 20);
	
			// Connection status for Player 2
			if (player_count >= 2) {
				var _p2_connected = InputPlayerIsConnected(1);
				var _p2_color = _p2_connected ? "c_lime" : "c_red";
				var _p2_text = _p2_connected ? "P2 Gamepad Connected" : "P2 Waiting for Gamepad...";
				scribble($"[fa_center][{_p2_color}]{_p2_text}")
					.draw(_center_x, _center_y + 40);
			}
	
			// Start prompt
			scribble("[fa_center][c_yellow][pulse]Press Any Key to Start")
				.draw(_center_x, _center_y + 70);
	
			// Controls
			scribble("[fa_center][c_gray][scale,0.8]Q/W/E = High Left/Mid/Right\n" +
					 "A/S/D = Low Left/Mid/Right\n" +
					 "SPACE = Shake\n\n" +
					 "ESC = Back to Menu")
				.draw(_center_x, NOTE_HIGHWAY_HEIGHT - 80);
		break;
		
	case "playing":
			if (is_paused) {
					scribble("[fa_center][c_yellow][pulse][scale,2]PAUSED\n\n" + "[scale,1][c_white]Press ESC to Resume").draw(x,y);
			}
		break;
		
	case "finished":
		draw_results_ui();
		break;
}