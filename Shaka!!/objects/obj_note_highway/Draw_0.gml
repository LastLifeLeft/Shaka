/////////////////////////
// Draw Event
/////////////////////////
// Draw center circle (spawn point)
draw_set_alpha(center_alpha);
draw_set_color(c_white);
draw_circle(x, y, center_size, false);
draw_set_color(c_gray);
draw_circle(x, y, center_size, true);
draw_circle(x, y, center_size + 1, true);
draw_set_alpha(1);

for (var i = 0; i < 6; i++) {
	var _pad_x = get_position_x(i, highway_radius, x, mode);
	var _pad_y = get_position_y(i, highway_radius, y, mode);
	draw_sprite(spr_samba_pad, i, _pad_x, _pad_y)
}

// Draw timing window visualization (F4 to toggle)
if (keyboard_check(vk_f4)) {
	draw_set_alpha(0.15);
	
	var _perfect_dist = highway_radius * (TIMING_PERFECT / 1000) / NOTE_APPROACH_TIME;
	var _good_dist = highway_radius * (TIMING_GOOD / 1000) / NOTE_APPROACH_TIME;
	var _ok_dist = highway_radius * (TIMING_OK / 1000) / NOTE_APPROACH_TIME;
	
	draw_set_color(c_orange);
	draw_circle(x, y, highway_radius - _ok_dist, true);
	draw_circle(x, y, highway_radius + _ok_dist, true);
	
	draw_set_color(c_yellow);
	draw_circle(x, y, highway_radius - _good_dist, true);
	draw_circle(x, y, highway_radius + _good_dist, true);
	
	draw_set_color(c_lime);
	draw_circle(x, y, highway_radius - _perfect_dist, true);
	draw_circle(x, y, highway_radius + _perfect_dist, true);
}

// Reset
draw_set_alpha(1);
draw_set_color(c_white);