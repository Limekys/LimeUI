///@desc Draws diagnostic overlays after the UI frame has been rendered.
///@ignore
function _luiDrawDiagnostics(_ui) {
	var _alpha = draw_get_alpha();
	var _color = draw_get_color();
	var _font = draw_get_font();
	var _halign = draw_get_halign();
	var _valign = draw_get_valign();

	if _ui.visible && global.lui_debug_mode != 0 {
		for (var i = 0, n = array_length(_ui.content); i < n; i++) {
			var _element = _ui.content[i];
			_luiRenderDebug(_element);
		}
	}
	if global.lui_debug_render_grid {
		_luiDrawScreenGrid(_ui);
	}
	if _ui.visible && global.lui_debug_mode != 0 {
		_luiDrawCursorInspector(_ui);
	} else {
		_ui._debug_cursor_index = 0;
	}

	draw_set_font(_font);
	draw_set_halign(_halign);
	draw_set_valign(_valign);
	draw_set_color(_color);
	draw_set_alpha(_alpha);
}


///@desc Renders debug info for the element (rectangles and text)
///@ignore
function _luiRenderDebug(_node) {

	// Restriction
	if !_node.visible || _node.is_destroyed || !_node._intersects_clip_region return;

	// Set font
	var _style = _node.getStyle();
	if !is_undefined(_style) && !is_undefined(_style.font_debug) {
		draw_set_font(_style.font_debug);
	}

	var _x = _node.x;
	var _y = _node.y;

	// Draw rectangles
	_luiRenderDebugRectangles(_node, _x, _y);

	// Margin, border, padding
	if global.lui_debug_mode >= 2 {
		_luiRenderDebugRectMargin(_node, _x, _y);
		_luiRenderDebugRectBorder(_node, _x, _y);
		_luiRenderDebugRectPadding(_node, _x, _y);
	}


	for (var i = 0, n = array_length(_node.content); i < n; i++) {
		_luiRenderDebug(_node.content[i]);
	}
}

///@ignore
function _luiDrawCursorInspector(_ui) {
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _grid = _ui._screen_grid;
	var _cx = floor(_mouse_x / LUI_GRID_SIZE);
	var _cy = floor(_mouse_y / LUI_GRID_SIZE);
	if _cx < 0 || _cx >= array_length(_grid) return;
	var _column = _grid[_cx];
	if _cy < 0 || _cy >= array_length(_column) return;

	var _hits = [];
	var _cell = _column[_cy];
	for (var i = 0, n = array_length(_cell); i < n; i++) {
		var _element = _cell[i];
		if _element.is_destroyed || !_element.visible || !_element._intersects_clip_region continue;
		var _bounds = _element._visible_bounds;
		if _mouse_x < _bounds.x1 || _mouse_y < _bounds.y1 || _mouse_x >= _bounds.x2 || _mouse_y >= _bounds.y2 continue;
		var _modal_depth = -1;
		for (var j = array_length(_ui._modal_stack) - 1; j >= 0; j--) {
			if _ui._isInSubtree(_element, _ui._modal_stack[j].dialog) {
				_modal_depth = j;
				break;
			}
		}
		array_push(_hits, {element: _element, modal_depth: _modal_depth});
	}

	var _count = array_length(_hits);
	if _count == 0 {
		_ui._debug_cursor_index = 0;
		return;
	}
	array_sort(_hits, function(_a, _b) {
		var _modal_order = _b.modal_depth - _a.modal_depth;
		if _modal_order != 0 return _modal_order;
		return _a.element._compareDepthArrays(_b.element._z_order_path, _a.element._z_order_path);
	});

	var _direction = keyboard_check_pressed(vk_pagedown) - keyboard_check_pressed(vk_pageup);
	var _index = clamp(_ui._debug_cursor_index + _direction, 0, _count - 1);
	_ui._debug_cursor_index = _index;
	var _first = clamp(_index - 2, 0, max(0, _count - 5));
	var _end = min(_first + 5, _count);
	var _text = "Under cursor " + string(_index + 1) + "/" + string(_count);
	if _count > 1 {
		_text += "   PgUp / PgDn";
	}
	for (var i = _first; i < _end; i++) {
		var _element = _hits[i].element;
		var _prefix = i == _index ? "> " : "  ";
		_text += "\n" + _prefix + instanceof(_element) + " #" + string(_element.element_id)
			+ " " + string_copy(string(_element.name), 1, 28);
	}
	var _selected = _hits[_index].element;
	draw_set_font(fDebug);
	draw_set_alpha(0.95);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	var _detail = _luiGetDebugInfo(_ui, _selected);
	if global.lui_debug_mode == 3 {
		draw_set_color(c_yellow);
		var _bounds = _selected._visible_bounds;
		draw_rectangle(_bounds.x1, _bounds.y1, _bounds.x2, _bounds.y2, true);
	}
	_luiDrawDebugText(_mouse_x + 24, _mouse_y + 24, _text + "\n\n" + _detail);
}

///@desc Builds detailed information for the selected element
///@ignore
function _luiGetDebugInfo(_ui, _node) {
	var _path = "";
	var _ancestor = _node;
	while !is_undefined(_ancestor) && _ancestor != _ui {
		var _segment = _ancestor.name == LUI_AUTO_NAME ? instanceof(_ancestor) : string(_ancestor.name);
		_path = _path == "" ? _segment : _segment + " > " + _path;
		_ancestor = _ancestor.parent;
	}

	var _bounds = _node._visible_bounds;
	var _visible_w = max(0, _bounds.x2 - _bounds.x1);
	var _visible_h = max(0, _bounds.y2 - _bounds.y1);
	var _visibility = _visible_w < _node.width || _visible_h < _node.height ? " (clipped)" : "";
	var _flex = _node.flex_node;
	var _width = _luiFormatDebugDimension(flexpanel_node_style_get_width(_flex), "auto");
	var _height = _luiFormatDebugDimension(flexpanel_node_style_get_height(_flex), "auto");
	var _min_w = _luiFormatDebugDimension(flexpanel_node_style_get_min_width(_flex), "-");
	var _min_h = _luiFormatDebugDimension(flexpanel_node_style_get_min_height(_flex), "-");
	var _max_w = _luiFormatDebugDimension(flexpanel_node_style_get_max_width(_flex), "-");
	var _max_h = _luiFormatDebugDimension(flexpanel_node_style_get_max_height(_flex), "-");
	var _grow = flexpanel_node_style_get_flex_grow(_flex);
	var _shrink = flexpanel_node_style_get_flex_shrink(_flex);

	var _target = _ui.topmost_hovered_element;
	var _target_text = "none";
	if !is_undefined(_target) && !_target.is_destroyed {
		_target_text = _target == _node ? "selected element" : instanceof(_target) + " #" + string(_target.element_id);
	}
	var _input = "allowed";
	if _node.deactivated || _ui.deactivated {
		_input = "disabled";
	} else if !_ui.isInputAllowed(_node) {
		_input = "outside active modal";
	}

	var _info = instanceof(_node) + " #" + string(_node.element_id) + "  " + string(_node.name)
		+ "\nPath: " + _path
		+ $"\nGUI: ({_node.x}, {_node.y})  {_node.width} x {_node.height}"
		+ $"\nVisible: {_visible_w} x {_visible_h}" + _visibility
		+ $"\nRequested: {_width} x {_height}"
		+ $"\nMin: {_min_w} x {_min_h}   Max: {_max_w} x {_max_h}"
		+ $"\nFlex grow: {_grow}   shrink: {_shrink}"
		+ "\nPointer target: " + _target_text
		+ "\nInput: " + _input + (_node.ignore_mouse ? "   Pointer: pass-through" : "")
		+ "\nFocus: " + (_node.has_focus ? "yes" : "no")
		+ "   Pressed: " + (_node.is_pressed ? "yes" : "no");

	if global.lui_debug_mode == 3 {
		var _cache = "off";
		if _node.cache_as_surface {
			_cache = _node._is_cache_dirty ? "dirty" : "clean";
		}
		_info += "\nZ path: " + string(_node._z_order_path)
			+ "\nChildren: " + string(array_length(_node.content))
			+ "   Pending batches: " + string(array_length(_node.delayed_content))
			+ "   Explicit cache: " + _cache;
	}
	return _info;
}

///@ignore
function _luiFormatDebugDimension(_size, _fallback) {
	if _size.unit == flexpanel_unit.percent return string(_size.value) + "%";
	if _size.unit == flexpanel_unit.point && !is_nan(_size.value) return string(_size.value);
	return _fallback;
}

///@desc Renders debug rectangles for element boundaries and view region
///@arg {real} _x X-coordinate for rendering (default 0)
///@arg {real} _y Y-coordinate for rendering (default 0)
///@ignore
function _luiRenderDebugRectangles(_node, _x = 0, _y = 0) {
	// Remember previous colors
	var _prev_color = draw_get_color();
	var _prev_alpha = draw_get_alpha();

	// Set colors based on mouse hover
	if _node.isMouseHovered() {
		draw_set_alpha(1);
		draw_set_color(c_red);
	} else {
		draw_set_alpha(0.5);
		draw_set_color(make_color_hsv(_node.element_id * 20 % 255, 255, 255));
	}

	// Draw element boundary rectangle
	if _node.isMouseHovered() {
		draw_rectangle(_x - 1, _y - 1, _x + _node.width - 1 + 1, _y + _node.height - 1 + 1, true);
	} else {
		draw_rectangle(_x, _y, _x + _node.width - 1, _y + _node.height - 1, true);
	}

	// Draw view region rectangle
	draw_set_color(make_color_hsv(_node.element_id * 20 % 255, 255, 255));
	draw_rectangle(_node._visible_bounds.x1, _node._visible_bounds.y1, _node._visible_bounds.x2, _node._visible_bounds.y2, true);

	// Reset colors
	draw_set_color(_prev_color);
	draw_set_alpha(_prev_alpha);
}

///@desc Renders debug rectangles for element
///@arg {real} _x X-coordinate for rendering (default 0)
///@arg {real} _y Y-coordinate for rendering (default 0)
///@ignore
function _luiRenderDebugRectPadding(_node, _x = 0, _y = 0) {

	// Get values
	var _b = flexpanel_node_style_get_border(_node.flex_node, flexpanel_edge.all_edges);
	var _p = flexpanel_node_style_get_padding(_node.flex_node, flexpanel_edge.all_edges).value;

	if _p == 0 return;

	// Remember previous colors
	var _prev_color = draw_get_color();
	var _prev_alpha = draw_get_alpha();

	// Set colors
	draw_set_alpha(0.5);
	draw_set_color(#F06292);

	// Draw padding INSIDE border (border-box model)
	// Top padding
	draw_rectangle(_x + _b, _y + _b, _x + _node.width - _b, _y + _b + _p, false);
	// Bottom padding
	draw_rectangle(_x + _b, _y + _node.height - _b - _p, _x + _node.width - _b, _y + _node.height - _b, false);
	// Left padding
	draw_rectangle(_x + _b, _y + _b + _p, _x + _b + _p, _y + _node.height - _b - _p, false);
	// Right padding
	draw_rectangle(_x + _node.width - _b - _p, _y + _b + _p, _x + _node.width - _b, _y + _node.height - _b - _p, false);

	// Draw text
	draw_set_valign(fa_top);
	draw_set_halign(fa_left);
	draw_set_alpha(0.75);
	draw_set_color(#C2185B);
	draw_text(_x + _b + 2, _y + _b + 2, "padding");

	// Reset colors
	draw_set_color(_prev_color);
	draw_set_alpha(_prev_alpha);
}

///@desc Renders debug rectangles for element
///@arg {real} _x X-coordinate for rendering (default 0)
///@arg {real} _y Y-coordinate for rendering (default 0)
///@ignore
function _luiRenderDebugRectBorder(_node, _x = 0, _y = 0) {

	// Get value
	var _b = flexpanel_node_style_get_border(_node.flex_node, flexpanel_edge.all_edges);

	if _b == 0 return;

	// Remember previous colors
	var _prev_color = draw_get_color();
	var _prev_alpha = draw_get_alpha();

	// Set colors
	draw_set_alpha(0.5);
	draw_set_color(#4DD0E1);

	// Draw border ON THE EDGE of _node.width/height (border-box model)
	// Top border (full width)
	draw_rectangle(_x, _y, _x + _node.width, _y + _b, false);
	// Bottom border (full width)
	draw_rectangle(_x, _y + _node.height - _b, _x + _node.width, _y + _node.height, false);
	// Left border (inner height only, excluding top/bottom borders)
	draw_rectangle(_x, _y + _b, _x + _b, _y + _node.height - _b, false);
	// Right border (inner height only, excluding top/bottom borders)
	draw_rectangle(_x + _node.width - _b, _y + _b, _x + _node.width, _y + _node.height - _b, false);

	// Draw text
	draw_set_valign(fa_top);
	draw_set_halign(fa_left);
	draw_set_alpha(0.75);
	draw_set_color(#00838F);
	draw_text(_x + 2, _y + 2, "border");

	// Reset colors
	draw_set_color(_prev_color);
	draw_set_alpha(_prev_alpha);
}

///@desc Renders debug rectangles for element
///@arg {real} _x X-coordinate for rendering (default 0)
///@arg {real} _y Y-coordinate for rendering (default 0)
///@ignore
function _luiRenderDebugRectMargin(_node, _x = 0, _y = 0) {

	// Get value
	var _m = flexpanel_node_style_get_margin(_node.flex_node, flexpanel_edge.all_edges).value;

	if _m == 0 return;

	// Remember previous colors
	var _prev_color = draw_get_color();
	var _prev_alpha = draw_get_alpha();

	// Set colors
	draw_set_alpha(0.5);
	draw_set_color(#FFB74D);

	// Draw margin OUTSIDE the element (border-box edge is at _x,_y,width,height)
	// Top margin (full width including side margins)
	draw_rectangle(_x - _m, _y - _m, _x + _node.width + _m, _y, false);
	// Bottom margin (full width including side margins)
	draw_rectangle(_x - _m, _y + _node.height, _x + _node.width + _m, _y + _node.height + _m, false);
	// Left margin (inner height only, excluding top/bottom margins to avoid corner overlap)
	draw_rectangle(_x - _m, _y, _x, _y + _node.height, false);
	// Right margin (inner height only, excluding top/bottom margins)
	draw_rectangle(_x + _node.width, _y, _x + _node.width + _m, _y + _node.height, false);

	// Draw text
	draw_set_valign(fa_top);
	draw_set_halign(fa_left);
	draw_set_alpha(0.75);
	draw_set_color(#E65100);
	draw_text(_x - _m, _y - _m, "margin");

	// Reset colors
	draw_set_color(_prev_color);
	draw_set_alpha(_prev_alpha);
}

///@desc Draw debug text
///@ignore
function _luiDrawDebugText(_x, _y, _text) {
	var _padding = 8;
	var _wrap_width = max(1, min(400, display_get_gui_width()) - 2 * _padding);
	var _lines = [];
	var _text_width = 0;
	var _in_details = false;
	var _source_lines = string_split(_text, "\n");
	for (var i = 0, n = array_length(_source_lines); i < n; i++) {
		var _remaining = _source_lines[i];
		var _color = c_white;
		if i == 0 {
			_color = #8FD8FF;
		} else if !_in_details {
			_color = string_char_at(_remaining, 1) == ">" ? #FFD580 : #ADB9CA;
		}
		if _remaining == "" {
			_in_details = true;
		}

		while string_width(_remaining) > _wrap_width {
			var _split = 1;
			var _space = 0;
			for (var j = 2, _length = string_length(_remaining); j <= _length; j++) {
				if string_width(string_copy(_remaining, 1, j)) > _wrap_width {
					break;
				}
				_split = j;
				if string_char_at(_remaining, j) == " " {
					_space = j;
				}
			}
			var _line = string_copy(_remaining, 1, _space > 0 ? _space - 1 : _split);
			array_push(_lines, {text: _line, color: _color});
			_text_width = max(_text_width, string_width(_line));
			_remaining = string_delete(_remaining, 1, _space > 0 ? _space : _split);
		}
		array_push(_lines, {text: _remaining, color: _color});
		_text_width = max(_text_width, string_width(_remaining));
	}

	var _line_height = string_height("Ag") + 2;
	var _card_width = min(_wrap_width, _text_width) + 2 * _padding;
	var _card_height = array_length(_lines) * _line_height + 2 * _padding;
	_x = clamp(_x, 0, max(0, display_get_gui_width() - _card_width));
	_y = clamp(_y, 0, max(0, display_get_gui_height() - _card_height));
	draw_set_color(c_black);
	draw_rectangle(_x, _y, _x + _card_width, _y + _card_height, false);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	for (var i = 0, n = array_length(_lines); i < n; i++) {
		draw_set_color(_lines[i].color);
		draw_text(_x + _padding, _y + _padding + i * _line_height, _lines[i].text);
	}
}


///@desc Draw debug grid info
///@ignore
function _luiDrawScreenGrid(_ui) {
	draw_set_alpha(1);
	draw_set_color(c_red);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_font(fDebug);

	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();

	var _width = ceil(_gui_width / LUI_GRID_SIZE);
	var _height = ceil(_gui_height / LUI_GRID_SIZE);

	for (var _x = 0; _x <= _width; ++_x) {
		var _x_pos = _x * LUI_GRID_SIZE;
		draw_line(_x_pos, 0, _x_pos, _gui_height);

		for (var _y = 0; _y <= _height; ++_y) {
			var _y_pos = _y * LUI_GRID_SIZE;

			if _x == 0 {
				draw_line(0, _y_pos, _gui_width, _y_pos);
			}

			var _array = [];
			if _x < array_length(_ui._screen_grid) && _y < array_length(_ui._screen_grid[_x]) {
				_array = _ui._screen_grid[_x][_y];
			}
			draw_text(_x_pos + 2, _y_pos + 1, $"{_x}_{_y}");

			var _elements_in_cell = array_length(_array);
			for (var i = 0, n = min(18, _elements_in_cell); i < n; ++i) {
				if i mod 2 == 0 {
					draw_set_color(c_orange);
				} else {
					draw_set_color(c_red);
				}
				draw_text(_x_pos + 2, _y_pos + 1 + 12 + 6 * i, string_copy(_array[i].name, 0, 18));
			}
			draw_set_color(c_red);
			if _elements_in_cell > 18 {
				draw_text(_x_pos + 2, _y_pos + 1 + 12 + 6 * 18, $"and {_elements_in_cell - 18} elements...");
			}
		}
	}
}
