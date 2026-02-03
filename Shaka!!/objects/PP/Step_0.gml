if (gameframe_enabled)
{
	gameframe_update();
	if ((window_gameframe_forced || gameframe_mouse_over_frame) == 0)
	{
		if (window_gameframe_timer)
		{
			window_gameframe_timer = max(0, window_gameframe_timer - delta_time);
		}
		else if gameframe_alpha > 0.01
		{
			gameframe_alpha = lerp(gameframe_alpha, 0, delta_time * .00001);
		}
	}
	else
	{
		window_gameframe_timer = GAMEFRAME_DISPARITION_DELAY;
		gameframe_alpha = 1;
	}
}

var _window_width = window_get_width();
var _window_height = window_get_height();

// Check if display needs recalculation
var _size_changed = (display_window_width != _window_width || display_window_height != _window_height);

if ((display_needs_update || _size_changed) && _window_width > 0 && _window_height > 0)
{
	display_window_width = _window_width;
	display_window_height = _window_height;
	display_needs_update = false;
	display_scale = 1;
	
	// Clamp screen ratio to defined bounds
	var _screen_ratio = display_window_width / display_window_height;
	
	display_current_ratio = clamp(_screen_ratio, display_tallest_ratio, display_widest_ratio);
	
	// Calculate splitview and surface dimensions based on orientation
	if (_screen_ratio >= 1)
	{
		display_orientation = display_landscape;
		display_splitview_height = display_target_height;
		display_splitview_width = ceil(display_splitview_height * display_current_ratio);
	}
	else
	{
		display_orientation = display_portrait;
		display_splitview_width = display_target_width;
		display_splitview_height = ceil(display_splitview_width / display_current_ratio);
	}
	
	// ================================================================
	// /!\ UNTESTED IN PORTAIT MODE! MIGHT NEED TO BE INVERSED?
	if display_current_ratio > _screen_ratio
	{
		// Screen is taller than display_tallest_ratio
		display_draw_w = display_window_width;
		display_draw_h = ceil(display_draw_w / display_current_ratio);
	}
	else
	{
		// Screen is wider than display_tallest_ratio
		display_draw_h = display_window_height;
		display_draw_w = ceil(display_draw_h * display_current_ratio);
	}
	// ================================================================
	
	// Apply display mode adjustments
	switch (display_mode)
	{
		case PP_DISPLAY_MODE.PIXEL:
			display_surface_width = display_splitview_width;
			display_surface_height = display_splitview_height;
			
			if (display_orientation == display_portrait)
			{
				display_final_scale = display_draw_w / display_surface_width;
			}
			else
			{
				display_final_scale = display_draw_h / display_surface_height;
			}
			
			display_final_scale_is_integer = bool(abs(display_final_scale - round(display_final_scale)) < 0.001);
			break;
			
		case PP_DISPLAY_MODE.MIXEL:
			var _integer_scale;
			if (display_orientation == display_portrait)
			{
				_integer_scale = floor(display_window_width / display_splitview_width);
			}
			else
			{
				_integer_scale = floor(display_window_height / display_splitview_height);
			}
			
			display_surface_width = display_splitview_width * _integer_scale;
			display_surface_height = display_splitview_height * _integer_scale;
			
			break;
			
		case PP_DISPLAY_MODE.HIGHRES:
			display_splitview_width = display_window_width;
			display_splitview_height = display_window_height;
			display_surface_width = display_window_width;
			display_surface_height = display_window_height;
			break;
	}
	
	// Calculate draw position (centers the game area in the window)
	display_draw_x = round((display_window_width - display_draw_w) * 0.5);
	display_draw_y = round((display_window_height - display_draw_h) * 0.5);
	
	
	// Resize application surface
	surface_resize(application_surface, display_surface_width, display_surface_height);
	
	// Force viewport layout recalculation
	splitview_calculate_layouts();
	
	// Notify subscribers
	signal_send(SIGNAL_DISPLAY_CHANGE);
}

// Update viewport layouts if needed
if (splitview_needs_update)
{
	splitview_calculate_layouts();
	signal_send(SIGNAL_DISPLAY_CHANGE);
}
