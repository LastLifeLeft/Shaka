// Draw key labels near each pad
draw_set_font(fnt_default);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_alpha(0.8);

var _labels = ["Q", "W", "E", "A", "S", "D"];
for (var i = 0; i < 6; i++) {
    var _pad_x = get_position_x(i);
    var _pad_y = get_position_y(i);
    var _color = get_position_color(i);
    
    // Draw label slightly outside the pad
    var _angle = get_position_angle(i);
    var _label_x = get_position_x(i, PAD_RADIUS + 35);
    var _label_y = get_position_y(i, PAD_RADIUS + 35);
    
    // Background circle for label
    draw_set_color(c_black);
    draw_circle(_label_x, _label_y, 15, false);
    
    // Label text
    draw_set_color(_color);
    scribble($"[fa_center]{_labels[i]}")
        .draw(_label_x, _label_y);
}

// Draw "Press SPACE to Shake" hint at bottom
draw_set_alpha(0.7);
scribble("[fa_center][c_gray]SPACE = Shake")
    .draw(NOTE_HIGHWAY_WIDTH / 2, NOTE_HIGHWAY_HEIGHT - 20);

// Draw debug controls hint
draw_set_alpha(0.5);
scribble("[fa_left][c_gray][scale,0.7]F1=Debug F2=Input F3=Timing F4=Windows")
    .draw(10, NOTE_HIGHWAY_HEIGHT - 15);

draw_set_alpha(1.0);