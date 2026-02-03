
// Draw UI overlay
draw_set_font(fnt_default);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

// Draw title
scribble($"[fa_center][c_yellow]{global.current_chart.title}[/]\n[c_white]{global.current_chart.artist}")
    .draw(320, 10);

// Draw state
var _state_text = "";
switch (game_state) {
    case "ready":
        _state_text = "[fa_center][pulse]Press any key to start!";
        break;
    case "paused":
        _state_text = "[fa_center][shake]PAUSED";
        break;
    case "finished":
        _state_text = "[fa_center][rainbow]SONG COMPLETE!\n\nPress any key to continue";
        break;
}

if (_state_text != "") {
    scribble(_state_text).draw(320, 150);
}

// Draw debug info
if (keyboard_check(vk_f1)) {
    draw_set_halign(fa_left);
    var _debug = $"Time: {current_time_ms / 1000}s\n";
    _debug += $"Notes spawned: {global.current_chart.current_note_index}\n";
    _debug += $"State: {game_state}\n";
    _debug += $"Music: {VinylIsPlaying(music_voice)}";
    
    draw_text(10, 10, _debug);
}