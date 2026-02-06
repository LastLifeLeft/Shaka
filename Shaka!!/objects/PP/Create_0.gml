#region Settings

// Display
#macro PP_DISPLAY_TARGET_WIDTH 640
#macro PP_DISPLAY_TARGET_HEIGHT 360

// Window Frame
#macro PP_WINDOW_DEFAULT_WIDTH 1280
#macro PP_WINDOW_DEFAULT_HEIGHT 720
#macro PP_WINDOW_MIN_WIDTH 1280
#macro PP_WINDOW_MIN_HEIGHT 720

// Transitions
#macro PP_TRANSITION_DEFAULT_DURATION 400000
#endregion

#region Enums

enum PP_TRANSITION
{
	// Fade (alpha blend)
	FADE_IN,
	FADE_OUT,
	
	// Iris (circular reveal/hide)
	IRIS_IN,
	IRIS_OUT,
	
	// Directional wipes
	WIPE_LEFT_IN,
	WIPE_LEFT_OUT,
	WIPE_RIGHT_IN,
	WIPE_RIGHT_OUT,
	WIPE_UP_IN,
	WIPE_UP_OUT,
	WIPE_DOWN_IN,
	WIPE_DOWN_OUT,
	
	// Diamond pattern (classic RPG style)
	DIAMONDS_IN,
	DIAMONDS_OUT
}

enum PP_DISPLAY_MODE
{
	PIXEL,
	MIXEL,
	HIGHRES
}

enum PP_SPLIT
{
	NONE,		   // Single player (1x1 grid)
	
	// 2 Players
	VERTICAL_2,	 // Side by side
	HORIZONTAL_2,   // Stacked
	
	// 3 Players
	COLUMNS_3,	  // Three columns
	ROWS_2_1,	   // Two on top, one full-width bottom
	GRID_2X2_3,	 // 2x2 grid with bottom-right empty
	
	// 4 Players
	COLUMNS_4,	  // Four columns
	GRID_2X2,	   // 2x2 grid
	
	// 5-8 Players
	GRID_4X2		// 4x2 grid, fills left-to-right, top-to-bottom
}

#endregion

#region Preferences

preferences = {
	vsync: true,
	fullscreen: false,
	window_width: PP_WINDOW_DEFAULT_WIDTH,
	window_height: PP_WINDOW_DEFAULT_HEIGHT
};

/// @func save_preferences()
/// @desc Saves preferences to a JSON file.
save_preferences = function()
{
	var _path = game_save_id + "pref.json";
	var _json_string = json_stringify(preferences);
	var _file = file_text_open_write(_path);
	file_text_write_string(_file, _json_string);
	file_text_close(_file);
};

/// @func load_preferences()
/// @desc Loads preferences from a JSON file, keeping defaults for missing keys.
load_preferences = function()
{
	var _path = game_save_id + "pref.json";
	
	if (!file_exists(_path)) return;
	
	var _file = file_text_open_read(_path);
	var _json_string = "";
	
	while (!file_text_eof(_file))
	{
		_json_string += file_text_read_string(_file);
		file_text_readln(_file);
	}
	file_text_close(_file);
	
	var _loaded = json_parse(_json_string);
	
	if (is_struct(_loaded))
	{
		// Merge loaded values into preferences, keeping defaults for missing keys
		var _names = struct_get_names(_loaded);
		for (var _i = 0; _i < array_length(_names); _i++)
		{
			var _key = _names[_i];
			if (struct_exists(preferences, _key))
			{
				preferences[$ _key] = _loaded[$ _key];
			}
		}
	}
};

#endregion

#region Display

application_surface_draw_enable(false);

display_mode = PP_DISPLAY_MODE.PIXEL;
display_widest_ratio = 16 / 9;
display_tallest_ratio = 16 / 9;
display_current_ratio = 0;

display_target_width = PP_DISPLAY_TARGET_WIDTH;
display_target_height = PP_DISPLAY_TARGET_HEIGHT;

display_splitview_width = 2;
display_splitview_height = 2;
display_surface_width = 2;
display_surface_height = 2;
display_scale = 1;
display_final_scale = 1;
display_final_scale_is_integer = false;

display_orientation = display_landscape;
display_window_width = 0;
display_window_height = 0;
display_needs_update = true;

display_draw_x = 0;
display_draw_y = 0;
display_draw_w = 0;
display_draw_h = 0;

/// @func display_set_target_size(_width, _height)
/// @desc Sets the target resolution for the display.
/// @param {Real} _width - Target width in pixels
/// @param {Real} _height - Target height in pixels
display_set_target_size = function(_width, _height)
{
	display_target_width = _width;
	display_target_height = _height;
	display_needs_update = true;
};

/// @func display_set_mode(_mode)
/// @desc Sets the display scaling mode.
/// @param {Enum.PP_DISPLAY_MODE} _mode - Display mode
display_set_mode = function(_mode)
{
	display_mode = _mode;
	display_needs_update = true;
};

/// @func display_set_ratio(_widest, _tallest)
/// @desc Sets the aspect ratio bounds.
/// @param {Real} _widest - Widest allowed ratio (e.g., 16/9 for a standard screen)
/// @param {Real} _tallest - Tallest allowed ratio (e.g., 3/4 for a retro screen in tate)
display_set_ratio = function(_widest, _tallest)
{
	display_widest_ratio = _widest;
	display_tallest_ratio = _tallest;
	display_needs_update = true;
};

/// @func display_draw()
/// @desc Draws the application surface to the window with letterboxing if needed.
display_draw = function()
{
	if (display_draw_x > 0 || display_draw_y > 0)
	{
		draw_sprite_tiled(PP_spr_window_bg, 0, 0, 0);
	}
	
	if (display_mode == PP_DISPLAY_MODE.PIXEL)
	{
		if (display_final_scale_is_integer)
		{
			// Integer scaling: draw with no filtering for crisp pixels
			draw_surface_stretched(application_surface, display_draw_x, display_draw_y, display_draw_w, display_draw_h);
		}
		else
		{
			// Non-integer scaling: use Juju's Casey Muratori's shader for smooth pixel scaling
			var _texture = surface_get_texture(application_surface);
			var _texel_w = texture_get_texel_width(_texture);
			var _texel_h = texture_get_texel_height(_texture);
			
			shader_set(shdCaseyMuratori);
			gpu_set_texfilter(true);
			shader_set_uniform_f(shader_get_uniform(shdCaseyMuratori, "u_vTexelSize"), _texel_w, _texel_h);
			shader_set_uniform_f(shader_get_uniform(shdCaseyMuratori, "u_vScale"), display_final_scale, display_final_scale);
			draw_surface_stretched(application_surface, display_draw_x, display_draw_y, display_draw_w, display_draw_h);
			shader_reset();
			gpu_set_texfilter(false);
		}
	}
	else
	{
		// Other modes: standard bilinear filtering
		var _filter = gpu_get_tex_filter()
		gpu_set_texfilter(true);
		draw_surface_stretched(application_surface, display_draw_x, display_draw_y, display_draw_w, display_draw_h);
		gpu_set_texfilter(_filter);
	}
};

#endregion

#region Splitview

// Unified viewport system - works for both single and multiplayer
splitview_mode = PP_SPLIT.NONE;
splitview_count = 1;
splitview = [];

// Border settings (only visible with 2+ players)
splitview_border_visible = true;
splitview_border_color = c_black;
splitview_border_thickness = 2;

// Track if we need to reconfigure views
splitview_needs_update = false;

/// @func splitview_setup([_count], [_mode])
/// @desc Sets up splitview for the specified player count and layout.
/// @param {Real} [_count] - Number of players (1-8), defaults to 1
/// @param {Enum.PP_SPLIT} [_mode] - Layout mode (uses default if not specified)
splitview_setup = function(_count = 1, _mode = undefined)
{
	_count = clamp(floor(_count), 1, 8);
	_mode ??= splitview_get_default_mode(_count);
	
	// Validate mode for player count
	if (!splitview_validate_mode(_count, _mode))
	{
		show_debug_message("PP Warning: Invalid viewport mode for " + string(_count) + " players. Using default.");
		_mode = splitview_get_default_mode(_count);
	}
	
	splitview_count = _count;
	splitview_mode = _mode;
	
	// Clean up existing surfaces before reconfiguring
	splitview_cleanup_surfaces();
		
	// Initialize viewport structs and GameMaker views
	splitview = [];
	
	for (var _i = 0; _i < _count; _i++)
	{
		// Enable GameMaker view
		view_enabled = true;
		view_visible[_i] = true;
		
		// Create camera if none exists for this view
		if (view_camera[_i] < 0)
		{
			view_camera[_i] = camera_create();
		}
		
		array_push(splitview, {
			// View index (matches GameMaker view)
			view_index: _i,
			
			// Dedicated surface for this splitview (eliminates rounding errors)
			surface: -1,
			
			// Screen position and size on application surface (compositing destination)
			screen_x: 0,
			screen_y: 0,
			screen_w: 0,
			screen_h: 0,
			
			// Window position and size (for overlay drawing in Post Draw)
			window_x: 0,
			window_y: 0,
			window_w: 0,
			window_h: 0,
			
			// Game world viewport size (in game units)
			game_w: 0,
			game_h: 0,
			
			// Camera target position (center point in world)
			target_x: 0,
			target_y: 0,
		});
	}
	
	// Disable unused views and clear their surface assignments
	for (var _i = _count; _i < 8; _i++)
	{
		view_visible[_i] = false;
		view_set_surface_id(_i, -1);
	}
	
	// Force recalculation
	display_needs_update = true;
	splitview_needs_update = true;
};

/// @func splitview_set_mode(_mode)
/// @desc Changes the splitview layout without changing player count.
/// @param {Enum.PP_SPLIT} _mode - New layout mode
splitview_set_mode = function(_mode)
{
	if (splitview_validate_mode(splitview_count, _mode))
	{
		splitview_mode = _mode;
		display_needs_update = true;
		splitview_needs_update = true;
	}
	else
	{
		show_debug_message("PP Warning: Invalid viewport mode for current player count.");
	}
};

/// @func splitview_set_view(_index, _x, _y)
/// @desc Sets the camera center position for a splitview.
/// @param {Real} _index - Splitview index (0-based)
/// @param {Real} _x - World X center
/// @param {Real} _y - World Y center
splitview_set_view = function(_index, _x, _y)
{
	if (_index < 0 || _index >= array_length(splitview)) return;
	
	var _sv = splitview[_index];
	_sv.target_x = _x;
	_sv.target_y = _y;
	
	var _cam_x = _sv.target_x - (_sv.screen_w * 0.5);
	var _cam_y = _sv.target_y - (_sv.screen_h * 0.5);
		
	camera_set_view_pos(view_camera[_index], _cam_x, _cam_y);
};

/// @func splitview_get(_index)
/// @desc Returns the splitview struct for a given index.
/// @param {Real} _index - Splitview index (0-based)
/// @return {Struct|undefined}
splitview_get = function(_index)
{
	if (_index < 0 || _index >= array_length(splitview)) return undefined;
	return splitview[_index];
};

/// @func splitview_get_at_position(_screen_x, _screen_y)
/// @desc Returns which splitview contains the given screen position.
/// @param {Real} _screen_x - Screen X coordinate
/// @param {Real} _screen_y - Screen Y coordinate
/// @return {Real} Splitview index (0-based) or -1 if not in any splitview
splitview_get_at_position = function(_screen_x, _screen_y)
{
	for (var _i = 0; _i < array_length(splitview); _i++)
	{
		var _sv = splitview[_i];
		
		if (_screen_x >= _sv.window_x && _screen_x < _sv.window_x + _sv.window_w &&
			_screen_y >= _sv.window_y && _screen_y < _sv.window_y + _sv.window_h)
		{
			return _i;
		}
	}
	
	return -1;
};

/// @func splitview_set_border(_visible, [_color], [_thickness])
/// @desc Configures the border between splitviews.
/// @param {Bool} _visible - Show borders
/// @param {Constant.Color} [_color] - Border color
/// @param {Real} [_thickness] - Border thickness in pixels
splitview_set_border = function(_visible, _color = c_black, _thickness = 2)
{
	splitview_border_visible = _visible;
	splitview_border_color = _color;
	splitview_border_thickness = max(0, floor(_thickness));
	splitview_needs_update = true;
};

/// @func splitview_validate_mode(_count, _mode)
/// @desc Checks if a mode is valid for a given player count.
/// @param {Real} _count
/// @param {Enum.PP_SPLIT} _mode
/// @return {Bool}
splitview_validate_mode = function(_count, _mode)
{
	switch (_count)
	{
		case 1:
			return (_mode == PP_SPLIT.NONE);
		case 2:
			return (_mode == PP_SPLIT.VERTICAL_2 || _mode == PP_SPLIT.HORIZONTAL_2);
		case 3:
			return (_mode == PP_SPLIT.COLUMNS_3 || _mode == PP_SPLIT.ROWS_2_1 || _mode == PP_SPLIT.GRID_2X2_3);
		case 4:
			return (_mode == PP_SPLIT.COLUMNS_4 || _mode == PP_SPLIT.GRID_2X2);
		case 5:
		case 6:
		case 7:
		case 8:
			return (_mode == PP_SPLIT.GRID_4X2);
		default:
			return false;
	}
};

/// @func splitview_get_default_mode(_count)
/// @desc Returns the default layout mode for a player count.
/// @param {Real} _count
/// @return {Enum.PP_SPLIT}
splitview_get_default_mode = function(_count)
{
	switch (_count)
	{
		case 1: return PP_SPLIT.NONE;
		case 2: return PP_SPLIT.VERTICAL_2;
		case 3: return PP_SPLIT.ROWS_2_1;
		case 4: return PP_SPLIT.GRID_2X2;
		default: return PP_SPLIT.GRID_4X2;
	}
};

/// @func splitview_calculate_layouts()
/// @desc Calculates splitview positions and sizes, then configures GameMaker views.
splitview_calculate_layouts = function()
{
	// Calculate cell dimensions
	var _layout = splitview_get_layout_grid();
	var _cell_w = ceil(display_surface_width / _layout.cols);
	var _cell_h = ceil(display_surface_height / _layout.rows);
	
	display_scale = display_draw_h / display_surface_height;
	var _game_scale_x = display_splitview_width / display_surface_width;
	var _game_scale_y = display_splitview_height / display_surface_height;
	
	// Position each viewport
	for (var _i = 0; _i < array_length(splitview); _i++)
	{
		if (_i >= array_length(_layout.cells)) break;
		
		var _sv = splitview[_i];
		var _cell = _layout.cells[_i];
		
		// Screen position and size (on application surface)
		_sv.screen_x = _cell.col * _cell_w;
		_sv.screen_y = _cell.row * _cell_h;
		_sv.screen_w = _cell_w * _cell.colspan;
		_sv.screen_h = _cell_h * _cell.rowspan;
		
		// Window position and size (for overlay drawing)
		_sv.window_x = round(display_draw_x + _sv.screen_x * display_scale);
		_sv.window_y = round(display_draw_y + _sv.screen_y * display_scale);
		_sv.window_w = round(_sv.screen_w * display_scale);
		_sv.window_h = round(_sv.screen_h * display_scale);
		
		// Maintain the same pixel density as the base display
		_sv.game_w = _sv.screen_w * _game_scale_x;
		_sv.game_h = _sv.screen_h * _game_scale_y;
		
		// Apply to GameMaker view system
		splitview_apply_view(_sv);
	}
	
	splitview_needs_update = false;
};

/// @func splitview_apply_view(_splitview)
/// @desc Applies splitview settings to GameMaker's view system.
///	   Each view renders to its own surface at (0,0) to eliminate rounding errors.
/// @param {Struct} _splitview - Splitview struct
splitview_apply_view = function(_splitview)
{
	// Create or resize the dedicated surface for this splitview
	var _surf_w = _splitview.screen_w;
	var _surf_h = _splitview.screen_h;
	
	if (!surface_exists(_splitview.surface))
	{
		_splitview.surface = surface_create(_surf_w, _surf_h);
	}
	else if (surface_get_width(_splitview.surface) != _surf_w || 
			 surface_get_height(_splitview.surface) != _surf_h)
	{
		surface_resize(_splitview.surface, _surf_w, _surf_h);
	}
	
	// Set view port to render at (0,0) on its own surface, filling the entire surface
	view_set_xport(_splitview.view_index, 0);
	view_set_yport(_splitview.view_index, 0);
	view_set_wport(_splitview.view_index, _surf_w);
	view_set_hport(_splitview.view_index, _surf_h);
	
	// Set the surface this view renders to
	view_set_surface_id(_splitview.view_index, _splitview.surface);
	
	// Set camera size (how much of the world it sees)
	camera_set_view_size(view_camera[_splitview.view_index], _surf_w, _surf_h);
	splitview_set_view(_splitview.view_index, _splitview.target_x, _splitview.target_y);
};

/// @func splitview_get_layout_grid()
/// @desc Returns grid configuration for current splitview mode.
/// @return {Struct} { cols, rows, cells }
splitview_get_layout_grid = function()
{
	var _cells = [];
	var _cols = 1;
	var _rows = 1;
	
	switch (splitview_mode)
	{
		case PP_SPLIT.NONE:
			_cols = 1; _rows = 1;
			_cells = [{ col: 0, row: 0, colspan: 1, rowspan: 1 }];
			break;
			
		case PP_SPLIT.VERTICAL_2:
			_cols = 2; _rows = 1;
			_cells = [
				{ col: 0, row: 0, colspan: 1, rowspan: 1 },
				{ col: 1, row: 0, colspan: 1, rowspan: 1 }
			];
			break;
			
		case PP_SPLIT.HORIZONTAL_2:
			_cols = 1; _rows = 2;
			_cells = [
				{ col: 0, row: 0, colspan: 1, rowspan: 1 },
				{ col: 0, row: 1, colspan: 1, rowspan: 1 }
			];
			break;
			
		case PP_SPLIT.COLUMNS_3:
			_cols = 3; _rows = 1;
			_cells = [
				{ col: 0, row: 0, colspan: 1, rowspan: 1 },
				{ col: 1, row: 0, colspan: 1, rowspan: 1 },
				{ col: 2, row: 0, colspan: 1, rowspan: 1 }
			];
			break;
			
		case PP_SPLIT.ROWS_2_1:
			_cols = 2; _rows = 2;
			_cells = [
				{ col: 0, row: 0, colspan: 1, rowspan: 1 },
				{ col: 1, row: 0, colspan: 1, rowspan: 1 },
				{ col: 0, row: 1, colspan: 2, rowspan: 1 }
			];
			break;
			
		case PP_SPLIT.GRID_2X2_3:
			_cols = 2; _rows = 2;
			_cells = [
				{ col: 0, row: 0, colspan: 1, rowspan: 1 },
				{ col: 1, row: 0, colspan: 1, rowspan: 1 },
				{ col: 0, row: 1, colspan: 1, rowspan: 1 }
			];
			break;
			
		case PP_SPLIT.COLUMNS_4:
			_cols = 4; _rows = 1;
			_cells = [
				{ col: 0, row: 0, colspan: 1, rowspan: 1 },
				{ col: 1, row: 0, colspan: 1, rowspan: 1 },
				{ col: 2, row: 0, colspan: 1, rowspan: 1 },
				{ col: 3, row: 0, colspan: 1, rowspan: 1 }
			];
			break;
			
		case PP_SPLIT.GRID_2X2:
			_cols = 2; _rows = 2;
			_cells = [
				{ col: 0, row: 0, colspan: 1, rowspan: 1 },
				{ col: 1, row: 0, colspan: 1, rowspan: 1 },
				{ col: 0, row: 1, colspan: 1, rowspan: 1 },
				{ col: 1, row: 1, colspan: 1, rowspan: 1 }
			];
			break;
			
		case PP_SPLIT.GRID_4X2:
			_cols = 4; _rows = 2;
			_cells = [];
			for (var _i = 0; _i < splitview_count; _i++)
			{
				array_push(_cells, {
					col: _i mod 4,
					row: _i div 4,
					colspan: 1,
					rowspan: 1
				});
			}
			break;
	}
	
	return { cols: _cols, rows: _rows, cells: _cells };
};

/// @func splitview_cleanup_surfaces()
/// @desc Frees all splitview surfaces. Called when reconfiguring splitviews.
splitview_cleanup_surfaces = function()
{
	var _count = array_length(splitview);
	for (var _i = 0; _i < _count; _i++)
	{
		if (surface_exists(splitview[_i].surface))
		{
			surface_free(splitview[_i].surface);
			splitview[_i].surface = -1;
		}
	}
};

/// @func splitview_mouse_get_index()
/// @desc Returns which splitview the mouse cursor is currently over.
/// @return {Real} Splitview index (0-based) or -1 if not over any splitview
splitview_mouse_get_index = function()
{
	return splitview_get_at_position(window_mouse_get_x(), window_mouse_get_y());
};

/// @func splitview_mouse_in_bounds(_index)
/// @desc Checks if the mouse is within the bounds of a specific splitview.
/// @param {Real} _index - Splitview index (0-based)
/// @return {Bool}
splitview_mouse_in_bounds = function(_index)
{
	if (_index < 0 || _index >= array_length(splitview)) return false;
	
	var _sv = splitview[_index];
	var _mx = window_mouse_get_x();
	var _my = window_mouse_get_y();
	
	return (_mx >= _sv.window_x && _mx < _sv.window_x + _sv.window_w &&
			_my >= _sv.window_y && _my < _sv.window_y + _sv.window_h);
};

/// @func splitview_mouse_get_position(_index)
/// @desc Gets the mouse position in game world coordinates for a specific splitview.
/// @param {Real} _index - Splitview index (0-based)
/// @return {Struct|undefined} { x, y } in world coordinates, or undefined if mouse is outside
splitview_mouse_get_position = function(_index)
{
	if (_index < 0 || _index >= array_length(splitview)) return {x: - 32000, y: - 32000};
	
	var _sv = splitview[_index];
	var _mx = window_mouse_get_x();
	var _my = window_mouse_get_y();
	
	// Check bounds
	if (_mx < _sv.window_x || _mx >= _sv.window_x + _sv.window_w ||
		_my < _sv.window_y || _my >= _sv.window_y + _sv.window_h)
	{
		return {x: - 32000, y: - 32000};
	}
	
	// Convert window coords to normalized position within splitview (0 to 1)
	var _norm_x = (_mx - _sv.window_x) / _sv.window_w;
	var _norm_y = (_my - _sv.window_y) / _sv.window_h;
	
	// Scale to view size and add camera offset
	var _cam = view_camera[_sv.view_index];
	var _cam_x = camera_get_view_x(_cam);
	var _cam_y = camera_get_view_y(_cam);
	var _cam_w = camera_get_view_width(_cam);
	var _cam_h = camera_get_view_height(_cam);
	
	return {
		x: _cam_x + (_norm_x * _cam_w),
		y: _cam_y + (_norm_y * _cam_h)
	};
};

/// @func splitview_mouse_get_x(_index)
/// @desc Gets the mouse X position in game world coordinates for a specific splitview.
/// @param {Real} _index - Splitview index (0-based)
/// @return {Real|undefined} World X coordinate, or undefined if mouse is outside
splitview_mouse_get_x = function(_index)
{
	var _pos = splitview_mouse_get_position(_index);
	return (_pos != undefined) ? _pos.x : undefined;
};

/// @func splitview_mouse_get_y(_index)
/// @desc Gets the mouse Y position in game world coordinates for a specific splitview.
/// @param {Real} _index - Splitview index (0-based)
/// @return {Real|undefined} World Y coordinate, or undefined if mouse is outside
splitview_mouse_get_y = function(_index)
{
	var _pos = splitview_mouse_get_position(_index);
	return (_pos != undefined) ? _pos.y : undefined;
};

#endregion

#region Splitview: UI

/// @func splitview_get_window_rect(_index)
/// @desc Returns the window coordinates and dimensions of a specific splitview.
/// @param {Real} _index - Splitview index (0-based, -1 for the whole surface)
/// @return {Struct|undefined} { x, y, w, h } in window coordinates, or undefined if invalid index
splitview_get_window_rect = function(_index)
{
	if (_index < 0){
		return {
			x: display_draw_x,
			y: display_draw_y,
			w: display_draw_w,
			h: display_draw_h
		};
	}
	
	if (_index >= array_length(splitview)) return undefined;
	
	var _sv = splitview[_index];
	
	return {
		x: _sv.window_x,
		y: _sv.window_y,
		w: _sv.window_w,
		h: _sv.window_h
	};
};

/// @func splitview_world_to_window(_index, _world_x, _world_y)
/// @desc Converts world coordinates to window position for a specific splitview.
/// @param {Real} _index - Splitview index (0-based)
/// @param {Real} _world_x - World X coordinate
/// @param {Real} _world_y - World Y coordinate
/// @return {Struct|undefined} { x, y, in_bounds } in window coordinates, or undefined if invalid index
splitview_world_to_window = function(_index, _world_x, _world_y)
{
	if (_index < 0 || _index >= array_length(splitview)) return undefined;
	
	var _sv = splitview[_index];
	
	// Get camera info
	var _cam = view_camera[_sv.view_index];
	var _cam_x = camera_get_view_x(_cam);
	var _cam_y = camera_get_view_y(_cam);
	var _cam_w = camera_get_view_width(_cam);
	var _cam_h = camera_get_view_height(_cam);
	
	// Convert world coords to normalized position within camera view (0 to 1)
	var _norm_x = (_world_x - _cam_x) / _cam_w;
	var _norm_y = (_world_y - _cam_y) / _cam_h;
	
	// Scale to window coordinates
	var _window_x = _sv.window_x + (_norm_x * _sv.window_w);
	var _window_y = _sv.window_y + (_norm_y * _sv.window_h);
	
	// Check if position is within the splitview bounds
	var _in_bounds = (_norm_x >= 0 && _norm_x <= 1 && _norm_y >= 0 && _norm_y <= 1);
	
	return {
		x: _window_x,
		y: _window_y,
		in_bounds: _in_bounds
	};
};

/// @func splitview_world_to_window_x(_index, _world_x, _world_y)
/// @desc Gets the window X position for a world coordinate in a specific splitview.
/// @param {Real} _index - Splitview index (0-based)
/// @param {Real} _world_x - World X coordinate
/// @param {Real} _world_y - World Y coordinate (needed for potential camera rotation)
/// @return {Real|undefined} Window X coordinate, or undefined if invalid index
splitview_world_to_window_x = function(_index, _world_x, _world_y)
{
	var _pos = splitview_world_to_window(_index, _world_x, _world_y);
	return (_pos != undefined) ? _pos.x : undefined;
};

/// @func splitview_world_to_window_y(_index, _world_x, _world_y)
/// @desc Gets the window Y position for a world coordinate in a specific splitview.
/// @param {Real} _index - Splitview index (0-based)
/// @param {Real} _world_x - World X coordinate (needed for potential camera rotation)
/// @param {Real} _world_y - World Y coordinate
/// @return {Real|undefined} Window Y coordinate, or undefined if invalid index
splitview_world_to_window_y = function(_index, _world_x, _world_y)
{
	var _pos = splitview_world_to_window(_index, _world_x, _world_y);
	return (_pos != undefined) ? _pos.y : undefined;
};

/// @func splitview_draw_borders()
/// @desc Draws border lines between splitviews on the application surface.
splitview_draw_borders = function()
{
	// Only draw borders if there are multiple viewports
	if (splitview_count <= 1 || !splitview_border_visible || splitview_border_thickness <= 0) return;
	
	surface_set_target(application_surface)
	
	// Scale the border thickness based on display scale for consistent pixel appearance
	var _thickness = splitview_border_thickness * display_scale;
	var _color = splitview_border_color;
	var _half = floor(_thickness * 0.5);

	// Draw borders between adjacent viewports using screen coordinates
	// (positions on the application_surface, before final scaling to window)
	var _count = array_length(splitview);
	
	for (var _i = 0; _i < _count; _i++)
	{
		var _sv1 = splitview[_i];
		
		for (var _j = _i + 1; _j < _count; _j++)
		{
			var _sv2 = splitview[_j];
			
			// Use screen coordinates (application surface space)
			var _sv1_right = _sv1.screen_x + _sv1.screen_w;
			var _sv1_bottom = _sv1.screen_y + _sv1.screen_h;
			var _sv2_right = _sv2.screen_x + _sv2.screen_w;
			var _sv2_bottom = _sv2.screen_y + _sv2.screen_h;
			
			// Check if vp1's right edge touches vp2's left edge (vertical border)
			if (abs(_sv1_right - _sv2.screen_x) <= _thickness)
			{
				// Check for vertical overlap
				var _top = max(_sv1.screen_y, _sv2.screen_y);
				var _bottom = min(_sv1_bottom, _sv2_bottom);
				
				if (_bottom > _top)
				{
					// Draw centered on the seam
					var _x = _sv1_right - _half;
					
					draw_rectangle_color(
						_x, _top,
						_x + _thickness, _bottom,
						_color, _color, _color, _color, false
					);
				}
			}
			
			// Check if vp1's bottom edge touches vp2's top edge (horizontal border)
			if (abs(_sv1_bottom - _sv2.screen_y) <= _thickness)
			{
				// Check for horizontal overlap
				var _left = max(_sv1.screen_x, _sv2.screen_x);
				var _right = min(_sv1_right, _sv2_right);
				
				if (_right > _left)
				{
					// Draw centered on the seam
					var _y = _sv1_bottom - _half;
					
					draw_rectangle_color(
						_left, _y,
						_right, _y + _thickness,
						_color, _color, _color, _color, false
					);
				}
			}
		}
	}
	surface_reset_target()
};

/// @func splitview_composite()
/// @desc Composites all splitview surfaces onto application_surface.
///	   Called in Post Draw before drawing borders and final display.
splitview_composite = function()
{
	surface_set_target(application_surface);
	draw_clear_alpha(c_black, 1);
	
	var _count = array_length(splitview);
	for (var _i = 0; _i < _count; _i++)
	{
		var _sv = splitview[_i];
		
		// Ensure surface exists (recreate if lost)
		if (!surface_exists(_sv.surface))
		{
			_sv.surface = surface_create(_sv.screen_w, _sv.screen_h);
			view_set_surface_id(_sv.view_index, _sv.surface);
			continue;
		}
		
		// Draw the splitview surface at its designated position on application_surface
		draw_surface(_sv.surface, _sv.screen_x, _sv.screen_y);
	}
	
	surface_reset_target();
};

/// @func transition_start(_index, _type, [_options])
/// @desc Starts a transition on a specific splitview.
/// @param {Real} _index - Splitview index (0-based)
/// @param {Enum.PP_TRANSITION} _type - Transition type
/// @param {Struct} [_options] - Options struct
transition_start = function(_index, _type, _options = 0, _whole_screen = false)
{
	if (_index < -1 || _index >= array_length(splitview)) return;
	
	// Build options struct if not provided
	if (!is_struct(_options))
	{
		_options = {
			duration: PP_TRANSITION_DEFAULT_DURATION
		};
	}
	
	// Identify the transition direction
	var _curve_name;
	switch (_type)
	{
		// "In" transitions - game becomes visible
		case PP_TRANSITION.FADE_IN:
		case PP_TRANSITION.IRIS_IN:
		case PP_TRANSITION.WIPE_LEFT_IN:
		case PP_TRANSITION.WIPE_RIGHT_IN:
		case PP_TRANSITION.WIPE_UP_IN:
		case PP_TRANSITION.WIPE_DOWN_IN:
		case PP_TRANSITION.DIAMONDS_IN:
			_curve_name = "cubic_in";
			_options.is_out = false;
			break;
			
		// "Out" transitions - game becomes hidden
		case PP_TRANSITION.FADE_OUT:
		case PP_TRANSITION.IRIS_OUT:
		case PP_TRANSITION.WIPE_LEFT_OUT:
		case PP_TRANSITION.WIPE_RIGHT_OUT:
		case PP_TRANSITION.WIPE_UP_OUT:
		case PP_TRANSITION.WIPE_DOWN_OUT:
		case PP_TRANSITION.DIAMONDS_OUT:
			_curve_name = "cubic_out";
			_options.is_out = true;
			break;
			
		default:
			_curve_name = "cubic_inout";
			_options.is_out = false;
	}
		
	// Set default for unspecified optionnal fields
	if (!variable_struct_exists(_options, "channel")) _options.channel = animcurve_get_channel(PP_ac_defaults, _curve_name);
	if (!variable_struct_exists(_options, "duration")) _options.duration = PP_TRANSITION_DEFAULT_DURATION;
	if (!variable_struct_exists(_options, "color")) _options.color = c_black;
	
	// Add required fields
	_options.type = _type;
	
	if (_index == -1)
	{
		_options.splitscreen = false;
		_options.whole_screen = _whole_screen;
		if (!variable_struct_exists(_options, "destination")) _options.destination = undefined;
	}
	else
	{
		_options.splitview = splitview[_index];
		_options.splitscreen = true;
	}
	instance_create_layer(x, y, layer, PP_obj_transition_manager, _options);
};

#endregion

#region Signal System

// Signals
#macro SIGNAL_DISPLAY_CHANGE "display_change"
#macro SIGNAL_TRANSITION_ENDED "transition_ended"
#macro SIGNAL_SPLITVIEW_TRANSITION_ENDED "splitview_transition_ended"
#macro SIGNAL_SPLITVIEW_DRAWUI "splitview_UI"
#macro SIGNAL_FONT_CHANGE "font_change"
#macro SIGNAL_LANGUAGE_CHANGE "language_change"
#macro SIGNAL_INPUT_HOTSWAP "input_change"
#macro SIGNAL_ROLLBACK "rollback"

signal_map = {};

/// @func signal_subscribe(_signal, _callback)
/// @desc Subscribes a function to a named signal.
/// @param {String} _signal - Signal name
/// @param {Function} _callback - Method to call when signal fires
signal_subscribe = function(_signal, _callback)
{
	if (!struct_exists(signal_map, _signal))
	{
		signal_map[$ _signal] = [];
	}
	
	array_push(signal_map[$ _signal], _callback);
};

/// @func signal_unsubscribe(_signal, _callback)
/// @desc Unsubscribes a function from a named signal.
/// @param {String} _signal - Signal name
/// @param {Function} _callback - Method to remove
signal_unsubscribe = function(_signal, _callback)
{
	if (!struct_exists(signal_map, _signal)) return;
	
	var _arr = signal_map[$ _signal];
	var _idx = array_get_index(_arr, _callback);
	
	if (_idx >= 0)
	{
		array_delete(_arr, _idx, 1);
		
		// Clean up empty arrays
		if (array_length(_arr) == 0)
		{
			struct_remove(signal_map, _signal);
		}
	}
};

/// @func signal_send(_signal)
/// @desc Fires a signal, calling all subscribed functions.
/// @param {String} _signal - Signal name
/// @param {Structure} _data - Parameters added to the call
signal_send = function(_signal, _data = undefined)
{
	if (!struct_exists(signal_map, _signal)) return;
	
	var _arr = signal_map[$ _signal];
	
	// Iterate backwards to safely remove dead instances
	for (var _i = array_length(_arr) - 1; _i >= 0; _i--)
	{
		var _callback = _arr[_i];
		var _owner = method_get_self(_callback);
		
		// Check if owner instance still exists (skip for standalone functions)
		if (_owner != undefined && !instance_exists(_owner))
		{
			array_delete(_arr, _i, 1);
			continue;
		}
		
		_callback(_data);
	}
	
	// Clean up if all subscribers are gone
	if (array_length(_arr) == 0)
	{
		struct_remove(signal_map, _signal);
	}
};

#endregion

#region Initialization

// Initialize with single viewport by default
splitview_setup(1);

#endregion

#region Game Window

if os_type = os_windows
{
	#macro GAMEFRAME_DISPARITION_DELAY 3000000
	window_is_gameframe = true;
	gameframe_enabled = true;
	window_gameframe_forced = true;
	window_gameframe_timer = GAMEFRAME_DISPARITION_DELAY;
	
	gameframe_caption_font = fnt_default;
	gameframe_minimum_width = PP_WINDOW_MIN_WIDTH;
	gameframe_minimum_height = PP_WINDOW_MIN_HEIGHT;
	
	gameframe_init()
}
else
{
	gameframe_enabled = false;
	window_is_gameframe = false;
	window_set_min_width(PP_WINDOW_MIN_WIDTH);
	window_set_min_height(PP_WINDOW_MIN_HEIGHT);
}

gameframe_enable = function(_state)
{
	if (window_is_gameframe == true) gameframe_enabled = _state;
}

gameframe_set_forced = function(_state)
{
	if (window_is_gameframe == true) window_gameframe_forced = _state;
}
#endregion

splitview_debug = function()
{
	var _sv = splitview[0];
	var _cam = view_camera[_sv.view_index];
	
	show_debug_message("=== SPLITVIEW DEBUG ===");
	show_debug_message("surface exists: " + string(surface_exists(_sv.surface)));
	show_debug_message("surface id: " + string(_sv.surface));
	show_debug_message("screen_w/h: " + string(_sv.screen_w) + " x " + string(_sv.screen_h));
	show_debug_message("target_x/y: " + string(_sv.target_x) + ", " + string(_sv.target_y));
	show_debug_message("camera id: " + string(_cam));
	show_debug_message("camera pos: " + string(camera_get_view_x(_cam)) + ", " + string(camera_get_view_y(_cam)));
	show_debug_message("camera size: " + string(camera_get_view_width(_cam)) + " x " + string(camera_get_view_height(_cam)));
	show_debug_message("view_surface_id: " + string(view_get_surface_id(_sv.view_index)));
	show_debug_message("view visible: " + string(view_visible[_sv.view_index]));
	show_debug_message("========================");
};