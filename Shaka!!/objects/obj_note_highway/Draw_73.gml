// Draw key labels near each pad
draw_set_font(fnt_default);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_alpha(0.8);

var _labels = ["Q", "W", "E", "A", "S", "D"];
var _label_distance = highway_radius + 35;

for (var i = 0; i < 6; i++) {
    var _color = get_position_color(i);
    
    // Get label position (slightly outside the pad)
    var _label_x = get_position_x(i, _label_distance, x, mode);
    var _label_y = get_position_y(i, _label_distance, y, mode);
    
    // Background circle for label
    draw_set_color(c_black);
    draw_circle(_label_x, _label_y, 15, false);
    
    // Label text
    draw_set_color(_color);
    scribble($"[fa_center]{_labels[i]}")
        .draw(_label_x, _label_y);
}

// Draw mode indicator (top center)
draw_set_alpha(0.7);
var _mode_text = mode == GAME_MODE.SAMBA ? "SAMBA MODE" : "SHAKATTO MODE";
scribble($"[fa_center][c_white]{_mode_text}")
    .draw(x, y - highway_radius - 50);

// Draw "Press SPACE to Shake" hint
draw_set_alpha(0.5);
scribble("[fa_center][c_gray]SPACE = Shake")
    .draw(NOTE_HIGHWAY_WIDTH / 2, NOTE_HIGHWAY_HEIGHT - 20);

// Draw debug controls hint
scribble("[fa_left][c_gray][scale,0.7]F1=Debug F2=Input F3=Timing F4=Windows")
    .draw(10, NOTE_HIGHWAY_HEIGHT - 15);

draw_set_alpha(1.0);