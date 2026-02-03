timer = 0;

if (splitscreen == false)
{
	// Pre-calculate draw area (used by most transitions)
	if (whole_screen)
	{
		draw_x = 0;
		draw_y = 0;
		draw_w = PP.display_window_width;
		draw_h = PP.display_window_height;
	}
	else
	{
		draw_x = PP.display_draw_x;
		draw_y = PP.display_draw_y;
		draw_w = PP.display_draw_w;
		draw_h = PP.display_draw_h;
	}
}

/// @func draw()
/// @desc Draws the transition effect. Called by PP in Post Draw.
draw = function()
{
	// Calculate progress
	var _progress = clamp(timer / duration, 0, 1);
	var _curve_value = animcurve_channel_evaluate(channel, _progress);
	_curve_value = is_out ? _curve_value : (1 - _curve_value);
	
	if (splitscreen)
	{
		draw_x = splitview.window_x
		draw_y = splitview.window_y
		draw_w = splitview.window_w
		draw_h = splitview.window_h
	}
	
	// Draw transition overlay based on type
	switch (type)
	{
		case PP_TRANSITION.FADE_IN:
		case PP_TRANSITION.FADE_OUT:
			draw_set_alpha(_curve_value);
			draw_rectangle_color(draw_x, draw_y, draw_x + draw_w, draw_y + draw_h, color, color, color, color, false);
			draw_set_alpha(1);
			break;
			
		case PP_TRANSITION.IRIS_IN:
		case PP_TRANSITION.IRIS_OUT:
			draw_iris(_curve_value, draw_x, draw_y, draw_w, draw_h);
			break;
			
		case PP_TRANSITION.WIPE_LEFT_IN:
		case PP_TRANSITION.WIPE_LEFT_OUT:
			draw_wipe(_curve_value, 1, 0, draw_x, draw_y, draw_w, draw_h); // From right edge, moving left
			break;
			
		case PP_TRANSITION.WIPE_RIGHT_IN:
		case PP_TRANSITION.WIPE_RIGHT_OUT:
			draw_wipe(_curve_value, -1, 0, draw_x, draw_y, draw_w, draw_h); // From left edge, moving right
			break;
			
		case PP_TRANSITION.WIPE_UP_IN:
		case PP_TRANSITION.WIPE_UP_OUT:
			draw_wipe(_curve_value, 0, 1, draw_x, draw_y, draw_w, draw_h); // From bottom, moving up
			break;
			
		case PP_TRANSITION.WIPE_DOWN_IN:
		case PP_TRANSITION.WIPE_DOWN_OUT:
			draw_wipe(_curve_value, 0, -1, draw_x, draw_y, draw_w, draw_h); // From top, moving down
			break;
		
		case PP_TRANSITION.DIAMONDS_IN:
		case PP_TRANSITION.DIAMONDS_OUT:
			draw_diamonds(_curve_value, draw_x, draw_y, draw_w, draw_h);
			break;
	}
};

/// @func draw_iris(_amount, _x, _y, _width, _height)
draw_iris = function(_amount, _x, _y, _width, _height)
{
	if (_amount <= 0) return;
	
	var _cx = _width * 0.5;
	var _cy = _height * 0.5;
	var _max_radius = point_distance(0, 0, _cx, _cy);
	var _radius = _max_radius * (1 - _amount);
	
	var _surf = surface_create(_width, _height);
	surface_set_target(_surf);
	draw_clear(color);
	
	gpu_set_blendmode(bm_subtract);
	draw_circle_color(_cx, _cy, _radius, c_white, c_white, false);
	gpu_set_blendmode(bm_normal);
	
	surface_reset_target();
	
	draw_surface(_surf, _x, _y);
	surface_free(_surf);
};

/// @func draw_wipe(_amount, _dir_x, _dir_y, _x, _y, _width, _height)
draw_wipe = function(_amount, _dir_x, _dir_y, _x, _y, _width, _height)
{
	if (_amount <= 0) return;
	
	var _x1, _y1, _x2, _y2;
	
	if (_dir_x != 0)
	{
		var _wipe_width = _width * _amount;
		
		if (_dir_x > 0)
		{
			_x1 = _x + _width - _wipe_width;
			_x2 = _x + _width;
		}
		else
		{
			_x1 = _x;
			_x2 = _x + _wipe_width;
		}
		_y1 = _y;
		_y2 = _y + _height;
	}
	else
	{
		var _wipe_height = _height * _amount;
		
		if (_dir_y > 0)
		{
			_y1 = _y + _height - _wipe_height;
			_y2 = _y + _height;
		}
		else
		{
			_y1 = _y;
			_y2 = _y + _wipe_height;
		}
		_x1 = _x;
		_x2 = _x + _width;
	}
	
	draw_rectangle_color(_x1, _y1, _x2, _y2, color, color, color, color, false);
};

/// @func draw_diamonds(_amount, _x, _y, _width, _height)
draw_diamonds = function(_amount, _x, _y, _width, _height)
{
	if (_amount <= 0) return;
	if (_amount >= 1)
	{
		draw_rectangle_color(_x, _y, _x + _width, _y + _height, color, color, color, color, false);
		return;
	}
	
	var _diamond_size = max(_width, _height) / 12;
	var _cols = ceil(_width / _diamond_size) + 2;
	var _rows = ceil(_height / _diamond_size) + 2;
	var _current_size = _diamond_size * _amount * 1.5;
	
	var _surf = surface_create(_width, _height);
	surface_set_target(_surf);
	draw_clear_alpha(c_black, 0);
	
	for (var _row = 0; _row < _rows; _row++)
	{
		for (var _col = 0; _col < _cols; _col++)
		{
			var _offset = (_row mod 2) * (_diamond_size * 0.5);
			var _cx = _col * _diamond_size + _offset;
			var _cy = _row * _diamond_size;
			
			draw_diamond(_cx, _cy, _current_size, color);
		}
	}
	
	surface_reset_target();
	draw_surface(_surf, _x, _y);
	surface_free(_surf);
};

/// @func draw_diamond(_cx, _cy, _size, _color)
draw_diamond = function(_cx, _cy, _size, _color)
{
	if (_size <= 0) return;
	
	draw_primitive_begin(pr_trianglefan);
	draw_vertex_color(_cx, _cy - _size, _color, 1);
	draw_vertex_color(_cx + _size, _cy, _color, 1);
	draw_vertex_color(_cx, _cy + _size, _color, 1);
	draw_vertex_color(_cx - _size, _cy, _color, 1);
	draw_primitive_end();
};