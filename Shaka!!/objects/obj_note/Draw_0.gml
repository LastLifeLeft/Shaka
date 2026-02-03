// Don't draw if hit (unless showing hit effect)
if (note_data.hit && !hit_effect) {
    exit;
}

// Calculate current position based on distance from center
var _draw_x = get_position_x(note_data.position, current_distance);
var _draw_y = get_position_y(note_data.position, current_distance);
var _draw_alpha = note_alpha;
var _draw_scale = 1.0;

// Hit effect animation
if (hit_effect) {
    // Expand and fade out
    var _progress = hit_effect_timer / hit_effect_duration;
    _draw_scale = 1.0 + _progress * 1.5;
    _draw_alpha = 1.0 - _progress;
    
    // Color based on rating
    switch (hit_rating) {
        case NOTE_RATING.PERFECT:
            draw_set_color(c_lime);
            break;
        case NOTE_RATING.GOOD:
            draw_set_color(c_yellow);
            break;
        case NOTE_RATING.OK:
            draw_set_color(c_orange);
            break;
        default:
            draw_set_color(c_red);
            break;
    }
} else {
    draw_set_color(note_color);
}

draw_set_alpha(_draw_alpha);

// Draw note as circle
var _size = NOTE_SIZE * _draw_scale;
draw_circle(_draw_x, _draw_y, _size / 2, false);

// Draw inner circle for depth
draw_set_color(c_white);
draw_set_alpha(_draw_alpha * 0.5);
draw_circle(_draw_x, _draw_y, _size / 4, false);

// Draw outline
draw_set_alpha(_draw_alpha);
draw_set_color(c_black);
draw_circle(_draw_x, _draw_y, _size / 2, true);
draw_circle(_draw_x, _draw_y, _size / 2 - 1, true);

// Reset draw state
draw_set_alpha(1.0);
draw_set_color(c_white);


// === DRAW EVENT (for debug - F3) ===

if (keyboard_check(vk_f3) && !hit_effect) {
    var _controller = obj_game_controller;
    var _time_diff = note_data.time_ms - _controller.current_time_ms;
    
    draw_set_font(fnt_default);
    draw_set_halign(fa_center);
    draw_set_color(c_white);
    draw_text(_draw_x, _draw_y - NOTE_SIZE, string(floor(_time_diff)));
}