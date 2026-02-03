draw_set_alpha(1.0);

// Draw background
draw_set_color(c_black);
draw_rectangle(0, 0, NOTE_HIGHWAY_WIDTH, NOTE_HIGHWAY_HEIGHT, false);

// Draw center circle (spawn point)
draw_set_alpha(center_alpha);
draw_set_color(c_white);
draw_circle(CIRCLE_CENTER_X, CIRCLE_CENTER_Y, 20, false);
draw_set_color(c_gray);
draw_circle(CIRCLE_CENTER_X, CIRCLE_CENTER_Y, 20, true);
draw_circle(CIRCLE_CENTER_X, CIRCLE_CENTER_Y, 21, true);

// Draw guide lines from center to each pad
draw_set_alpha(guide_alpha);
for (var i = 0; i < 6; i++) {
    var _pad_x = get_position_x(i);
    var _pad_y = get_position_y(i);
    var _color = get_position_color(i);
    
    draw_set_color(_color);
    draw_line_width(CIRCLE_CENTER_X, CIRCLE_CENTER_Y, _pad_x, _pad_y, 2);
}

// Draw pads at target positions
draw_set_alpha(pad_alpha + beat_pulse_alpha);
for (var i = 0; i < 6; i++) {
    var _pad_x = get_position_x(i);
    var _pad_y = get_position_y(i);
    var _color = get_position_color(i);
    
    // Draw pad (larger circle)
    draw_set_color(_color);
    draw_circle(_pad_x, _pad_y, NOTE_SIZE * 1.2, false);
    
    // Draw inner ring
    draw_set_color(c_white);
    draw_circle(_pad_x, _pad_y, NOTE_SIZE * 0.8, true);
    draw_circle(_pad_x, _pad_y, NOTE_SIZE * 0.8 + 1, true);
    
    // Draw outer ring
    draw_set_color(c_black);
    draw_circle(_pad_x, _pad_y, NOTE_SIZE * 1.2, true);
    draw_circle(_pad_x, _pad_y, NOTE_SIZE * 1.2 + 1, true);
}

// Draw timing window visualization (F4 to toggle)
if (keyboard_check(vk_f4)) {
    draw_set_alpha(0.15);
    
    // Draw rings showing timing windows
    var _perfect_dist = PAD_RADIUS * (TIMING_PERFECT / 1000) / NOTE_APPROACH_TIME;
    var _good_dist = PAD_RADIUS * (TIMING_GOOD / 1000) / NOTE_APPROACH_TIME;
    var _ok_dist = PAD_RADIUS * (TIMING_OK / 1000) / NOTE_APPROACH_TIME;
    
    // OK window (orange)
    draw_set_color(c_orange);
    draw_circle(CIRCLE_CENTER_X, CIRCLE_CENTER_Y, PAD_RADIUS - _ok_dist, true);
    draw_circle(CIRCLE_CENTER_X, CIRCLE_CENTER_Y, PAD_RADIUS + _ok_dist, true);
    
    // Good window (yellow)
    draw_set_color(c_yellow);
    draw_circle(CIRCLE_CENTER_X, CIRCLE_CENTER_Y, PAD_RADIUS - _good_dist, true);
    draw_circle(CIRCLE_CENTER_X, CIRCLE_CENTER_Y, PAD_RADIUS + _good_dist, true);
    
    // Perfect window (green)
    draw_set_color(c_lime);
    draw_circle(CIRCLE_CENTER_X, CIRCLE_CENTER_Y, PAD_RADIUS - _perfect_dist, true);
    draw_circle(CIRCLE_CENTER_X, CIRCLE_CENTER_Y, PAD_RADIUS + _perfect_dist, true);
}

// Reset
draw_set_alpha(1.0);
draw_set_color(c_white);