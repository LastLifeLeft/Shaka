// Don't draw if hit (unless showing hit effect)
if (note_data.hit && !hit_effect) exit;

// Calculate world position from distance and angle
var _angle = get_position_angle(note_data.position, highway.mode);
var _draw_x = highway.center_x + lengthdir_x(current_distance, _angle);
var _draw_y = highway.center_y + lengthdir_y(current_distance, _angle);

if (hit_effect) {
	// Expand and fade out
	var _progress = hit_effect_timer / hit_effect_duration;
	draw_set_alpha(1.0 - _progress);
	draw_circle_colour(_draw_x, _draw_y, NOTE_SIZE / 2 * (1.0 + _progress * 1.5), c_white, note_color, false);
	draw_set_alpha(1);
} else {
	draw_circle_colour(_draw_x, _draw_y, NOTE_SIZE / 2, c_white, note_color, false);
}

// Debug: Show timing info (F3)
if (keyboard_check(vk_f3) && !hit_effect) {
	draw_set_font(fnt_default);
	draw_set_halign(fa_center);
	draw_set_color(c_white);
	
	var _time_until_hit = hit_time_ms - obj_game_manager.current_time_ms;
	draw_text(_draw_x, _draw_y - NOTE_SIZE, string(floor(_time_until_hit)));
}