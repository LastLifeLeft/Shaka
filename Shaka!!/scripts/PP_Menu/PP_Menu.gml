/// @function PP_Menu([playerIndex])
/// @description Creates a new vertical menu that uses Input 10 and Scribble 9
/// @param {Real} [playerIndex=0] The player index for Input library
function PP_Menu(_playerIndex = 0) constructor {
	playerIndex = _playerIndex;
	items = [];
	currentPosition = -1;
	disabled = false;
	defaultCancelPosition = -1; // -1 means no item selected on cancel
	
	// Visual properties
	font = undefined;
	scale = 1;
	coldColor = c_white;
	warmColor = c_yellow;
	disabledColor = c_gray;
	vAlign = fa_top;
	hAlign = fa_left;
	iconSprite = -1;
	iconImage = 0;
	iconHAlign = fa_left;
	offsetX = 0;
	offsetY = 0;
	spacing = 0;
	
	/// @function AddItem(text, position, callback, [disabled])
	/// @description Adds a menu item at the specified position
	/// @param {String} text The text to display
	/// @param {Function} callback The function to call on accept
	/// @param {Bool} [disabled=false] Whether the item is disabled
	static AddItem = function(_text, _callback, _disabled = false) {
		return InsertItem(_text, array_length(items), _callback, _disabled);
	};
	
	/// @function InsertItem(text, position, callback, [disabled])
	/// @description Adds a menu item at the specified position
	/// @param {String} text The text to display
	/// @param {Real} position The position to insert the item
	/// @param {Function} callback The function to call on accept
	/// @param {Bool} [disabled=false] Whether the item is disabled
	static InsertItem = function(_text, _position, _callback, _disabled = false) {
		var _item = {
			text: _text,
			callback: _callback,
			disabled: _disabled,
			scribble: scribble(_text),
			bboxCached: false,
			bboxX1: 0,
			bboxY1: 0,
			bboxX2: 0,
			bboxY2: 0
		};
		
		// Apply current formatting to the scribble object
		if (font != undefined) {
			_item.scribble.starting_format(font, coldColor);
		}
		_item.scribble.scale(scale);
		_item.scribble.blend(coldColor, 1);
		_item.scribble.align(hAlign, fa_top);
		
		// Insert at position or append if position is beyond array length
		if (_position >= array_length(items)) {
			array_push(items, _item);
		} else {
			array_insert(items, _position, _item);
		}
		
		// Ensure currentPosition is valid, and blend the item.
		if ((currentPosition = -1) && ( _disabled = false)) {
			currentPosition = array_length(items) - 1;
			_item.scribble.blend(warmColor, 1);
		}
		else if _disabled
		{
			_item.scribble.blend(disabledColor, 1);
		}
		else
		{
			_item.scribble.blend(coldColor, 1);
		}
		
		_item.scribble.align(hAlign, fa_top);
		
		//Keep the correct cancel action
		if ((defaultCancelPosition > -1) && (defaultCancelPosition >= _position)) defaultCancelPosition++
		
		return self;
	};	
	
	/// @function RemoveItem(position)
	/// @description Removes a menu item at the specified position
	/// @param {Real} position The position of the item to remove
	static RemoveItem = function(_position) {
		if (_position < 0 || _position >= array_length(items)) return self;
		
		// Clean up scribble object
		delete items[_position].scribble;
		
		array_delete(items, _position, 1);
		
		// Adjust current position if needed
		if (array_length(items) == 0) {
			currentPosition = 0;
		} else if (currentPosition >= array_length(items)) {
			currentPosition = array_length(items) - 1;
		}
		
		//Keep the correct cancel action
		if (defaultCancelPosition == _position) defaultCancelPosition = -1;
		if ((defaultCancelPosition > -1) && (defaultCancelPosition > _position)) defaultCancelPosition--;
		
		
		
		return self;
	};
	
	/// @function DisableItem(position, state)
	/// @description Disables or enables a menu item
	/// @param {Real} position The position of the item
	/// @param {Bool} state True to disable, false to enable
	static DisableItem = function(_position, _state) {
		if (_position < 0 || _position >= array_length(items)) return self;
		
		items[_position].disabled = _state;
		
		// If we disabled the current item, move to next non-disabled item
		if (_state && _position == currentPosition) {
			var _found = false;
			// Try next items
			for (var i = currentPosition + 1; i < array_length(items); i++) {
				if (!items[i].disabled) {
					currentPosition = i;
					_found = true;
					break;
				}
			}
			// Try previous items if no next item found
			if (!_found) {
				for (var i = currentPosition - 1; i >= 0; i--) {
					if (!items[i].disabled) {
						currentPosition = i;
						break;
					}
				}
			}
		}
		
		return self;
	};
	
	/// @function SetCancelAction(position)
	/// @description Sets which item is selected when cancel is pressed
	/// @param {Real} position The position to select on cancel (-1 for none)
	static SetCancelAction = function(_position) {
		defaultCancelPosition = _position;
		return self;
	};
	
	/// @function Disable(state)
	/// @description Disables or enables the entire menu
	/// @param {Bool} state True to disable, false to enable
	static Disable = function(_state) {
		disabled = _state;
		return self;
	};
	
	/// @function SetFont(fontName)
	/// @description Sets the font for all menu items
	/// @param {String} fontName The font name to use
	static SetFont = function(_fontName) {
		font = _fontName;
		for (var i = 0; i < array_length(items); i++) {
			items[i].scribble.starting_format(_fontName, i == currentPosition ? warmColor : coldColor);
			items[i].bboxCached = false;
		}
		return self;
	};
	
	/// @function SetScale(scaleFactor)
	/// @description Sets the scale for all menu items
	/// @param {Real} scaleFactor The scale factor
	static SetScale = function(_scale) {
		scale = _scale;
		for (var i = 0; i < array_length(items); i++) {
			items[i].scribble.scale(_scale);
			items[i].bboxCached = false;
		}
		return self;
	};
	
	/// @function SetColors(cold, warm, disabled)
	/// @description Sets the colors for menu items
	/// @param {Constant.Color} cold Color for inactive items
	/// @param {Constant.Color} warm Color for active item
	/// @param {Constant.Color} disabled Color for disabled items
	static SetColors = function(_cold, _warm, _disabled) {
		coldColor = _cold;
		warmColor = _warm;
		disabledColor = _disabled;
		
		for (var i = 0; i < array_length(items); i++) {
			var _color = items[i].disabled ? disabledColor : (i == currentPosition ? warmColor : coldColor);
			items[i].scribble.blend(_color, 1);
		}
		return self;
	};
	
	/// @function SetVAlignment(vAlign)
	/// @description Sets the vertical alignment of the menu
	/// @param {Constant.VAlign} vAlign The vertical alignment (fa_top, fa_middle, fa_bottom)
	static SetVAlignment = function(_vAlign) {
		vAlign = _vAlign;
		return self;
	};
	
	/// @function SetHAlignment(hAlign)
	/// @description Sets the horizontal alignment of the menu
	/// @param {Constant.HAlign} hAlign The horizontal alignment (fa_left, fa_center, fa_right)
	static SetHAlignment = function(_hAlign) {
		hAlign = _hAlign;
		for (var i = 0; i < array_length(items); i++) {
			items[i].scribble.align(_hAlign, fa_top);
			items[i].bboxCached = false;
		}
		return self;
	};
	
	/// @function SetIcon(spriteIndex, imageIndex)
	/// @description Sets an optional sprite to draw in front of the active item
	/// @param {Asset.GMSprite} spriteIndex The sprite to use
	/// @param {Real} imageIndex The image index of the sprite
	static SetIcon = function(_spriteIndex, _imageIndex) {
		iconSprite = _spriteIndex;
		iconImage = _imageIndex;
		return self;
	};
	
	/// @function SetIconHAlignment(hAlign)
	/// @description Sets the horizontal alignment of the icon
	/// @param {Constant.HAlign} hAlign The horizontal alignment (fa_left, fa_center, fa_right)
	static SetIconHAlignment = function(_hAlign) {
		iconHAlign = _hAlign;
		return self;
	};
	
	/// @function SetOffset(xOffset, yOffset)
	/// @description Sets the offset for the active menu item
	/// @param {Real} xOffset Horizontal offset
	/// @param {Real} yOffset Vertical offset
	static SetOffset = function(_xOffset, _yOffset) {
		offsetX = _xOffset;
		offsetY = _yOffset;
		return self;
	};
	
	/// @function SetSpacing(pixels)
	/// @description Sets the vertical spacing between menu items
	/// @param {Real} pixels The spacing in pixels
	static SetSpacing = function(_pixels) {
		spacing = _pixels;
		return self;
	};
	
	/// @function Update()
	/// @description Updates the menu state based on Input library
	static Update = function() {
		if (disabled || array_length(items) == 0) return self;
		
		var _oldPosition = currentPosition;
		
		// Handle UP input
		if (InputRepeat(INPUT_VERB.UP, playerIndex)) {
			var _newPos = currentPosition - 1;
			// Wrap around or find previous non-disabled item
			while (_newPos != currentPosition) {
				if (_newPos < 0) _newPos = array_length(items) - 1;
				if (!items[_newPos].disabled) {
					currentPosition = _newPos;
					break;
				}
				_newPos--;
			}
		}
		
		// Handle DOWN input
		if (InputRepeat(INPUT_VERB.DOWN, playerIndex)) {
			var _newPos = currentPosition + 1;
			// Wrap around or find next non-disabled item
			while (_newPos != currentPosition) {
				if (_newPos >= array_length(items)) _newPos = 0;
				if (!items[_newPos].disabled) {
					currentPosition = _newPos;
					break;
				}
				_newPos++;
			}
		}
		
		// Handle ACCEPT input
		if (InputRepeat(INPUT_VERB.ACCEPT, playerIndex)) {
			if (!items[currentPosition].disabled && items[currentPosition].callback != undefined) {
				items[currentPosition].callback();
				Disable(true);
			}
		}
		
		// Handle CANCEL input
		if (InputRepeat(INPUT_VERB.CANCEL, playerIndex)) {
			if (defaultCancelPosition >= 0 && defaultCancelPosition < array_length(items)) {
				currentPosition = defaultCancelPosition;
				if (!items[currentPosition].disabled && items[currentPosition].callback != undefined) {
					items[currentPosition].callback();
					Disable(true);
				}
			}
		}
		
		// Update colors if position changed
		if (_oldPosition != currentPosition) {
			items[_oldPosition].scribble.blend(items[_oldPosition].disabled ? disabledColor : coldColor, 1);
			items[currentPosition].scribble.blend(items[currentPosition].disabled ? disabledColor : warmColor, 1);
		}
		
		return self;
	};
	
	/// @function UpdateMouse(menuX, menuY, mouseX, mouseY, mouseClick)
	/// @description Updates the menu state based on mouse input
	/// @param {Real} menuX The X position of the menu
	/// @param {Real} menuY The Y position of the menu
	/// @param {Real} mouseX The mouse X position
	/// @param {Real} mouseY The mouse Y position
	/// @param {Bool} mouseClick Whether the mouse was clicked
	static UpdateMouse = function(_menuX, _menuY, _mouseX, _mouseY, _mouseClick) {
		if (disabled || array_length(items) == 0) return self;
		
		var _oldPosition = currentPosition;
		var _hoveredItem = -1;
		
		// Calculate menu starting Y based on vertical alignment
		var _totalHeight = 0;
		for (var i = 0; i < array_length(items); i++) {
			if (!items[i].bboxCached) {
				var _bbox = items[i].scribble.get_bbox(_menuX, _menuY);
				items[i].bboxX1 = _bbox.left;
				items[i].bboxY1 = _bbox.top;
				items[i].bboxX2 = _bbox.right;
				items[i].bboxY2 = _bbox.bottom;
				items[i].bboxCached = true;
			}
			_totalHeight += (items[i].bboxY2 - items[i].bboxY1);
			if (i < array_length(items) - 1) {
				_totalHeight += spacing;
			}
		}
		
		var _startY = _menuY;
		if (vAlign == fa_middle) {
			_startY -= _totalHeight / 2;
		} else if (vAlign == fa_bottom) {
			_startY -= _totalHeight;
		}
		
		// Check each item for hover
		var _currentY = _startY;
		for (var i = 0; i < array_length(items); i++) {
			var _itemHeight = items[i].bboxY2 - items[i].bboxY1;
			
			if (_mouseY >= _currentY && _mouseY < _currentY + _itemHeight) {
				if (_mouseX >= items[i].bboxX1 && _mouseX <= items[i].bboxX2) {
					_hoveredItem = i;
					break;
				}
			}
			
			_currentY += _itemHeight + spacing;
		}
		
		// Update selection if hovering over a non-disabled item
		if (_hoveredItem >= 0 && !items[_hoveredItem].disabled) {
			currentPosition = _hoveredItem;
			
			// Handle click
			if (_mouseClick && items[currentPosition].callback != undefined) {
				items[currentPosition].callback();
				Disable(true);
			}
		}
		
		// Update colors if position changed
		if (_oldPosition != currentPosition) {
			items[_oldPosition].scribble.blend(items[_oldPosition].disabled ? disabledColor : coldColor, 1);
			items[currentPosition].scribble.blend(items[currentPosition].disabled ? disabledColor : warmColor, 1);
		}
		
		return self;
	};
	
	/// @function SetState(position)
	/// @description Sets the current menu position
	/// @param {Real} position The position to set
	static SetState = function(_position) {
		if (_position < 0 || _position >= array_length(items)) return self;
		
		var _oldPosition = currentPosition;
		currentPosition = _position;
		
		// Update colors
		if (_oldPosition != currentPosition && array_length(items) > 0) {
			items[_oldPosition].scribble.blend(items[_oldPosition].disabled ? disabledColor : coldColor, 1);
			items[currentPosition].scribble.blend(items[currentPosition].disabled ? disabledColor : warmColor, 1);
		}
		
		return self;
	};
	
	/// @function GetState()
	/// @description Gets the current menu position
	/// @return {Real} The current position
	static GetState = function() {
		return currentPosition;
	};
	
	/// @function Draw(menuX, menuY)
	/// @description Draws the menu at the specified position
	/// @param {Real} menuX The X position to draw the menu
	/// @param {Real} menuY The Y position to draw the menu
	static Draw = function(_menuX, _menuY) {
		if (array_length(items) == 0) return self;
		
		// Calculate total height for vertical alignment
		var _totalHeight = 0;
		for (var i = 0; i < array_length(items); i++) {
			var _bbox = items[i].scribble.get_bbox(_menuX, _menuY);
			_totalHeight += (_bbox.bottom - _bbox.top);
			if (i < array_length(items) - 1) {
				_totalHeight += spacing;
			}
		}
		
		// Calculate starting Y position based on vertical alignment
		var _startY = _menuY;
		if (vAlign == fa_middle) {
			_startY -= _totalHeight / 2;
		} else if (vAlign == fa_bottom) {
			_startY -= _totalHeight;
		}
		
		// Draw each item
		var _currentY = _startY;
		for (var i = 0; i < array_length(items); i++) {
			var _drawX = _menuX;
			var _drawY = _currentY;
			var _bbox = items[i].scribble.get_bbox(_drawX, _drawY);
			var _itemHeight = _bbox.bottom - _bbox.top;
			
			// Apply offset to active item
			if (i == currentPosition) {
				_drawX += offsetX;
				_drawY += offsetY;
			}
			
			// Draw icon for active item
			if (i == currentPosition && iconSprite >= 0 && sprite_exists(iconSprite)) {
				var _iconX = _drawX;
				var _textWidth = _bbox.right - _bbox.left;
				
				if (iconHAlign == fa_left) {
					_iconX = _drawX - sprite_get_width(iconSprite);
				} else if (iconHAlign == fa_center) {
					_iconX = _drawX + (_textWidth / 2) - (sprite_get_width(iconSprite) / 2);
				} else if (iconHAlign == fa_right) {
					_iconX = _drawX + _textWidth;
				}
				
				draw_sprite(iconSprite, iconImage, _iconX, _drawY + _itemHeight / 2);
			}
			
			// Draw text
			items[i].scribble.draw(_drawX, _drawY);
			
			_currentY += _itemHeight + spacing;
		}
		
		return self;
	};
}
