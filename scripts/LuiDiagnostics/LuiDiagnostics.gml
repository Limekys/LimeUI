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
	var _hovered = _ui.topmost_hovered_element;
	if global.lui_debug_mode != 0 && !is_undefined(_hovered) && !_hovered.is_destroyed {
		_luiRenderDebugInfo(_hovered, device_mouse_x_to_gui(0) + 32, device_mouse_y_to_gui(0) + 32);
	}

	draw_set_font(_font);
	draw_set_halign(_halign);
	draw_set_valign(_valign);
	draw_set_color(_color);
	draw_set_alpha(_alpha);
}


///@desc Renders debug info for the element (rectangles and text)
///@arg {real} _x X-coordinate for rendering (default 0)
///@arg {real} _y Y-coordinate for rendering (default 0)
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
	if global.lui_debug_mode == 2 {
		_luiRenderDebugRectMargin(_node, _x, _y);
		_luiRenderDebugRectBorder(_node, _x, _y);
		_luiRenderDebugRectPadding(_node, _x, _y);
	}

	// Draw debug text info
	if global.lui_debug_mode == 3 {
		_luiRenderDebugInfo(_node, _x, _y);
	}

	for (var i = 0, n = array_length(_node.content); i < n; i++) {
		_luiRenderDebug(_node.content[i]);
	}
}

///@desc Renders debug text information for the element
///@arg {real} _x X-coordinate for rendering (default 0)
///@arg {real} _y Y-coordinate for rendering (default 0)
///@ignore
function _luiRenderDebugInfo(_node, _x = 0, _y = 0) {
	var _style = _node.getStyle();
	// Set font if defined
	if !is_undefined(_style) && !is_undefined(_style.font_debug) {
		draw_set_font(_style.font_debug);
	}

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

	// Draw debug text
	_luiDrawDebugText(_x, _y,
		"id: " + string(_node.element_id) + "\n" +
		"name: " + string(_node.name) + "\n" +
		"class: " + instanceof(_node) + "\n" +
		"x: " + string(_node.x) + (_node.auto_x ? " (auto)" : "") + " y: " + string(_node.y) + (_node.auto_y ? " (auto)" : "") + "\n" +
		"w: " + string(_node.width) + (_node.auto_width ? " (auto)" : "") + " h: " + string(_node.height) + (_node.auto_height ? " (auto)" : "") + "\n" +
		"min_w: " + string(_node.min_width) + " min_h: " + string(_node.min_height) + " max_w: " + string(_node.max_width) + " max_h: " + string(_node.max_height) + "\n" +
		"v: " + string(_node.value) + "\n" +
		"content: " + string(array_length(_node.content)) + "/" + string(array_length(_node.delayed_content)) + "\n" +
		"parent: " + (is_undefined(_node.parent) ? "undefined" : _node.parent.name) + "\n" +
		"z: " + string(_node.z) + " " + string(_node._z_order_path) + "\n" +
		"nesting_level: " + string(_node.nesting_level)
	);

	// Reset colors
	draw_set_color(_prev_color);
	draw_set_alpha(_prev_alpha);
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
	var _text_width = string_width(_text);
	var _text_height = string_height(_text);
	_x = clamp(_x, 0, display_get_gui_width() - _text_width);
	_y = clamp(_y, 0, display_get_gui_height() - _text_height);
	draw_set_color(c_black);
	draw_rectangle(_x, _y, _x + _text_width + 1, _y + _text_height + 1, false);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_text(_x + 1, _y + 1, _text);
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
