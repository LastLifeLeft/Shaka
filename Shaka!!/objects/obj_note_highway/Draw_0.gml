draw_set_alpha(1.0);

// Draw background (optional - can be removed if you have a separate background object)
// draw_set_color(c_black);
// draw_rectangle(0, 0, NOTE_HIGHWAY_WIDTH, NOTE_HIGHWAY_HEIGHT, false);

// Draw center circle (spawn point)
draw_set_alpha(center_alpha);
draw_set_color(c_white);
draw_circle(x, y, center_size, false);
draw_set_color(c_gray);
draw_circle(x, y, center_size, true);
draw_circle(x, y, center_size + 1, true);

// Draw guide lines from center to each pad
draw_set_alpha(guide_alpha);
for (var i = 0; i < 6; i++) {
    var _pad_x = get_position_x(i, highway_radius, x, mode);
    var _pad_y = get_position_y(i, highway_radius, y, mode);
    var _color = get_position_color(i);
    
    draw_set_color(_color);
    draw_line_width(x, y, _pad_x, _pad_y, 2);
}

// Draw pads at target positions
draw_set_alpha(pad_alpha + beat_pulse_alpha);
for (var i = 0; i < 6; i++) {
    var _pad_x = get_position_x(i, highway_radius, x, mode);
    var _pad_y = get_position_y(i, highway_radius, y, mode);
    var _color = get_position_color(i);
    
    // Draw pad (larger circle)
    draw_set_color(_color);
    draw_circle(_pad_x, _pad_y, pad_size, false);
    
    // Draw inner ring
    draw_set_color(c_white);
    draw_circle(_pad_x, _pad_y, pad_size * 0.67, true);
    draw_circle(_pad_x, _pad_y, pad_size * 0.67 + 1, true);
    
    // Draw outer ring
    draw_set_color(c_black);
    draw_circle(_pad_x, _pad_y, pad_size, true);
    draw_circle(_pad_x, _pad_y, pad_size + 1, true);
}

// Draw timing window visualization (F4 to toggle)
if (keyboard_check(vk_f4)) {
    draw_set_alpha(0.15);
    
    // Draw rings showing timing windows
    var _perfect_dist = highway_radius * (TIMING_PERFECT / 1000) / NOTE_APPROACH_TIME;
    var _good_dist = highway_radius * (TIMING_GOOD / 1000) / NOTE_APPROACH_TIME;
    var _ok_dist = highway_radius * (TIMING_OK / 1000) / NOTE_APPROACH_TIME;
    
    // OK window (orange)
    draw_set_color(c_orange);
    draw_circle(x, y, highway_radius - _ok_dist, true);
    draw_circle(x, y, highway_radius + _ok_dist, true);
    
    // Good window (yellow)
    draw_set_color(c_yellow);
    draw_circle(x, y, highway_radius - _good_dist, true);
    draw_circle(x, y, highway_radius + _good_dist, true);
    
    // Perfect window (green)
    draw_set_color(c_lime);
    draw_circle(x, y, highway_radius - _perfect_dist, true);
    draw_circle(x, y, highway_radius + _perfect_dist, true);
}

// Reset
draw_set_alpha(1.0);
draw_set_color(c_white);
