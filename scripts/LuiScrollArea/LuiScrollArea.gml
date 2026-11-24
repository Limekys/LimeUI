///@desc A transparent viewport with optional horizontal and vertical scrolling.
/// During vertical scrolling, offscreen rows in an ordered list refresh their screen position when they enter the viewport.
/// Use getLayoutBounds() to query the current position of an offscreen row.
/// Available parameters:
/// scroll_x
/// scroll_y
///@arg {Struct} [_params] Struct with parameters
function LuiScrollArea(_params = {}) : LuiBase(_params) constructor {
	// STATE

	self.scroll_x = _params[$ "scroll_x"] ?? false;
	self.scroll_y = _params[$ "scroll_y"] ?? false;
	self.ignore_mouse = !self.scroll_x && !self.scroll_y;
	
	if self.scroll_x || self.scroll_y {
		self._clip_children = true;
		self.scroll_offset_x = 0;
		self.scroll_offset_y = 0;
		self.scroll_target_offset_x = 0;
		self.scroll_target_offset_y = 0;
		self._drag_origin = undefined;
		self._pending_focus_reveal = undefined;
		self._scroll_bar_x = undefined;
		self._scroll_bar_y = undefined;
		self._panel_insets = {left: 0, top: 0, right: 0, bottom: 0};
		self._viewport_insets = {left: 0, top: 0, right: 0, bottom: 0};
		self._scroll_layout_revision = -1;
		self._scroll_row_count = 0;
		self._scroll_rows = undefined;
		self._visible_row_start = 0;
		self._visible_row_end_exclusive = 0;
		self._scrollbar_edge_inset = 4;
		self.scroll_smoothness = 0.02;
		self.scroll_container = new LuiAbsoluteContainer({x: 0, y: 0});
		self.scroll_container._scroll_owner = self;
		// Keep the viewport fixed while the content moves beneath it.
		self.scroll_container._clip_children = true;
		self.setContainer(self.scroll_container);
		self._scroll_insets = {left: 0, top: 0, right: 0, bottom: 0};
	}

	// INTERNALS

	///@ignore
	static _getClipInsets = function() {
		if self.scroll_x || self.scroll_y return self._panel_insets;
		return self._getStyleClipInsets(self.getStyle());
	}

	///@ignore
	static _getScrollInsets = function() {
		var _style = self.getStyle();
		var _o = self._getStyleClipInsets(_style);
		var _gutter = is_undefined(_style) ? 0 : _style.scroll_slider_width + self._scrollbar_edge_inset;
		var _insets = self._scroll_insets;
		_insets.left = _o.left;
		_insets.top = _o.top;
		_insets.right = self.scroll_y ? max(_o.right, _gutter) : _o.right;
		_insets.bottom = self.scroll_x ? max(_o.bottom, _gutter) : _o.bottom;
		return _insets;
	}

	///@ignore
	static _getScrollContentInsets = function() {
		var _content = self.scroll_container;
		var _clip = self._getScrollInsets();
		var _insets = self._viewport_insets;
		_insets.left = self.x + _clip.left - _content.x;
		_insets.top = self.y + _clip.top - _content.y;
		_insets.right = _content.x + _content.width - (self.x + self.width - _clip.right);
		_insets.bottom = _content.y + _content.height - (self.y + self.height - _clip.bottom);
		return _insets;
	}

	///@ignore
	static _requestScrollUpdate = function() {
		var _queue = self.main_ui._pending_scroll_areas;
		if !array_contains(_queue, self) {
			array_push(self.main_ui._pending_scroll_areas, self);
		}
	}

	///@ignore
	static _applyScrollUpdate = function() {
		var _container = self.scroll_container;
		if _container.is_destroyed return;
		self._applyPendingFocusReveal();
		_container.invalidateCache();
		_container._applyLayoutGeometry(true);
		self._updateScrollBars();
	}

	///@ignore
	static _getLayoutOffset = function() {
		return {x: self.scroll_offset_x, y: self.scroll_offset_y};
	}

	///@ignore
	static _needsScrollBoundsRefresh = function() {
		return self.scroll_y && !self.scroll_x && self._scroll_layout_revision != self.main_ui._layout_revision;
	}

	///@ignore
	static _indexScrollRows = function(_children, _origin_y) {
		var _rows = [];
		var _previous_bottom = 0;
		for (var i = 0, n = array_length(_children); i < n; i++) {
			var _child = _children[i];
			var _bounds = _child._flex_bounds;
			if _child.is_destroyed || is_undefined(_bounds) || _bounds.height <= 0 return undefined;
			var _top = _bounds.top - _origin_y;
			if i > 0 && _top < _previous_bottom return undefined;
			_previous_bottom = _top + _bounds.height;
			array_push(_rows, {element: _child, top: _top, bottom: _previous_bottom});
		}
		return _rows;
	}

	///@ignore
	static _findScrollRow = function(_rows, _edge, _find_start) {
		var _low = 0;
		var _high = array_length(_rows);
		while _low < _high {
			var _mid = (_low + _high) div 2;
			var _row = _rows[_mid];
			if (_find_start && _row.bottom <= _edge) || (!_find_start && _row.top < _edge) {
				_low = _mid + 1;
			} else {
				_high = _mid;
			}
		}
		return _low;
	}

	///@ignore
	static _updateScrollChildren = function(_reuse_bounds, _offset_x, _offset_y) {
		if self.scroll_x || !self.scroll_y {
			self.scroll_container._applyChildLayoutGeometry(_reuse_bounds, _offset_x, _offset_y);
			return;
		}

		var _container = self.scroll_container;
		var _children = _container.content;
		var _count = array_length(_children);
		var _revision = self.main_ui._layout_revision;
		var _rebuild = !_reuse_bounds || self._scroll_layout_revision != _revision || self._scroll_row_count != _count;
		if _rebuild || is_undefined(self._scroll_rows) {
			for (var i = 0; i < _count; i++) {
				_children[i]._applyLayoutGeometry(!_rebuild, _offset_x, _offset_y);
			}
			if !_rebuild return;
			self._scroll_rows = self._indexScrollRows(_children, _container._flex_bounds.top);
			self._scroll_row_count = _count;
			self._scroll_layout_revision = _revision;
		}

		var _rows = self._scroll_rows;
		if is_undefined(_rows) return;
		var _clip = _container._child_clip_bounds;
		var _first = self._findScrollRow(_rows, _clip.y1 - _container.y, true);
		var _end = max(_first, self._findScrollRow(_rows, _clip.y2 - _container.y, false));
		if !_rebuild {
			// Clear rows leaving the viewport before refreshing the new range.
			for (var i = self._visible_row_start; i < self._visible_row_end_exclusive; i++) {
				if i >= _first && i < _end continue;
				_rows[i].element._propagateVisibleRegionState();
			}
			for (var i = _first; i < _end; i++) {
				_rows[i].element._applyLayoutGeometry(true, _offset_x, _offset_y);
			}
		}
		self._visible_row_start = _first;
		self._visible_row_end_exclusive = _end;
	}

	///@ignore
	static _queueFocusReveal = function(_item) {
		self._pending_focus_reveal = _item;
		self._requestScrollUpdate();
	}

	///@ignore
	static _applyPendingFocusReveal = function() {
		var _item = self._pending_focus_reveal;
		self._pending_focus_reveal = undefined;
		if is_undefined(_item) || _item != self.main_ui.element_in_focus || !self.main_ui.isInputAllowed(_item) return;

		self._revealFocusBounds(_item.getLayoutBounds());
		self.scroll_offset_x = self.scroll_target_offset_x;
		self.scroll_offset_y = self.scroll_target_offset_y;
	}

	///@ignore
	static _getMinScrollOffset = function(_horizontal = false) {
		var _content = self.scroll_container._flex_bounds;
		if is_undefined(_content) || is_undefined(self._flex_bounds) return 0;
		var _o = self._getScrollInsets();
		if _horizontal return min(0, self._flex_bounds.left + self.width - _o.right - (_content.left + _content.width));
		return min(0, self._flex_bounds.top + self.height - _o.bottom - (_content.top + _content.height));
	}

	///@ignore
	static _focusShift = function(_start, _size, _view_start, _view_end) {
		if _start < _view_start return _view_start - _start;
		if _start + _size > _view_end return max(_view_start - _start, _view_end - _start - _size);
		return 0;
	}

	///@ignore
	static _revealFocusBounds = function(_bounds) {
		var _view = self.getLayoutBounds();
		var _o = self._getScrollInsets();
		if self.scroll_x {
			var _dx = self._focusShift(_bounds.left, _bounds.width, _view.left + _o.left, _view.left + _view.width - _o.right);
			self.scroll_target_offset_x = clamp(self.scroll_offset_x + _dx, self._getMinScrollOffset(true), 0);
			_bounds.left += self.scroll_target_offset_x - self.scroll_offset_x;
		}
		if self.scroll_y {
			var _dy = self._focusShift(_bounds.top, _bounds.height, _view.top + _o.top, _view.top + _view.height - _o.bottom);
			self.scroll_target_offset_y = clamp(self.scroll_offset_y + _dy, self._getMinScrollOffset(), 0);
			_bounds.top += self.scroll_target_offset_y - self.scroll_offset_y;
		}
	}

	///@ignore
	static _updateScrollBars = function() {
		if !is_undefined(self._scroll_bar_x) && !self._scroll_bar_x.is_destroyed {
			self._scroll_bar_x._applyLayoutGeometry(true);
		}
		if !is_undefined(self._scroll_bar_y) && !self._scroll_bar_y.is_destroyed {
			self._scroll_bar_y._applyLayoutGeometry(true);
		}
	}

	///@ignore
	static _handlePointerWheel = function(_data) {
		if !self.scroll_x && !self.scroll_y return;
		var _horizontal = self.scroll_x && (!self.scroll_y || _data.shift);
		var _step = self.getStyle().scroll_step * _data.delta;
		var _limit = self._getMinScrollOffset(_horizontal);
		var _previous = _horizontal ? self.scroll_target_offset_x : self.scroll_target_offset_y;
		_previous = clamp(_previous, _limit, 0);
		var _delta = _horizontal
			? (LUI_INVERT_SCROLL_X ? _step : -_step)
			: (LUI_INVERT_SCROLL_Y ? -_step : _step);
		var _next = clamp(_previous + _delta, _limit, 0);
		if _next == _previous return;

		if _horizontal {
			self.scroll_target_offset_x = _next;
		} else {
			self.scroll_target_offset_y = _next;
		}
		_data.stop_propagation = true;
	}

	// UPDATE

	///@ignore
	static _stepScroll = function() {
		var _allowed = self.main_ui.isInputAllowed(self);
		var _pressed = mouse_check_button_pressed(mb_left);
		var _held = mouse_check_button(mb_left);
		if _pressed {
			self._drag_origin = undefined;
		}
		if _allowed && _pressed {
			var _mx = device_mouse_x_to_gui(0);
			var _my = device_mouse_y_to_gui(0);
			var _hit = self.main_ui._getTopmostElement(_mx, _my);
			var _hit_can_drag = !is_undefined(_hit) && _hit.can_drag;
			while !is_undefined(_hit) {
				if _hit == self {
					if !_hit_can_drag {
						self._drag_origin = {x: _mx, y: _my};
					}
					break;
				}
				if is_instanceof(_hit, LuiScrollBar) {
					break;
				}
				if is_instanceof(_hit, LuiScrollArea) && (_hit.scroll_x || _hit.scroll_y) {
					break;
				}
				_hit = _hit.parent;
			}
		}

		if !_allowed || !_held || !is_undefined(self.main_ui.dragging_element) {
			self._drag_origin = undefined;
		} else if !is_undefined(self._drag_origin) {
			var _drag_x = device_mouse_x_to_gui(0);
			var _drag_y = device_mouse_y_to_gui(0);
			self.scroll_target_offset_x += _drag_x - self._drag_origin.x;
			self.scroll_target_offset_y += _drag_y - self._drag_origin.y;
			self._drag_origin.x = _drag_x;
			self._drag_origin.y = _drag_y;
		}

		var _min_x = self.scroll_x ? self._getMinScrollOffset(true) : 0;
		var _min_y = self.scroll_y ? self._getMinScrollOffset() : 0;
		self.scroll_target_offset_x = clamp(self.scroll_target_offset_x, _min_x, 0);
		self.scroll_target_offset_y = clamp(self.scroll_target_offset_y, _min_y, 0);
		var _x = SmoothApproachDelta(clamp(self.scroll_offset_x, _min_x, 0), self.scroll_target_offset_x, self.scroll_smoothness, 0.1);
		var _y = SmoothApproachDelta(clamp(self.scroll_offset_y, _min_y, 0), self.scroll_target_offset_y, self.scroll_smoothness, 0.1);
		if _x != self.scroll_offset_x || _y != self.scroll_offset_y {
			self.scroll_offset_x = _x;
			self.scroll_offset_y = _y;
			self._requestScrollUpdate();
		}
	}

	if self.scroll_x || self.scroll_y {
		self.step = method(self, self._stepScroll);
	}

	// EVENT HANDLERS

	self.addEvent(LUI_EV_CREATE, function(_e) {
		if _e.scroll_x || _e.scroll_y {
			_e.scroll_container._getClipInsets = method(_e, _e._getScrollContentInsets);
			_e.scroll_container.addEvent(LUI_EV_SIZE_UPDATE, function(_content) {
				// A partial layout can resize the content without visiting its sibling scroll bars.
				_content._scroll_owner._updateScrollBars();
			});
			_e.addContentDirect(_e.scroll_container);
			if _e.scroll_x {
				_e._scroll_bar_x = new LuiScrollBar({area: _e, horizontal: true});
				_e.addContentDirect(_e._scroll_bar_x);
			}
			if _e.scroll_y {
				_e._scroll_bar_y = new LuiScrollBar({area: _e});
				_e.addContentDirect(_e._scroll_bar_y);
			}
			if _e.auto_height {
				flexpanel_node_style_set_flex(_e.flex_node, 1);
			}
			var _gutter = _e.getStyle().scroll_slider_width + _e._scrollbar_edge_inset;
			if _e.scroll_x {
				if _e.scroll_container.auto_width {
					flexpanel_node_style_set_width(_e.scroll_container.flex_node, 0, flexpanel_unit.auto);
				}
				flexpanel_node_style_set_border(_e.flex_node, flexpanel_edge.bottom, _gutter);
			}
			if _e.scroll_y {
				flexpanel_node_style_set_border(_e.flex_node, flexpanel_edge.right, _gutter);
			}
		}
	});

	self.addEvent(LUI_EV_DESTROY, function(_e) {
		if (_e.scroll_x || _e.scroll_y) && !_e.scroll_container.is_destroyed {
			_e.scroll_container.destroy();
		}
	});
}

///@desc Scroll track with a draggable thumb, attached to a scroll area.
/// Available parameters:
/// area
/// horizontal
///@arg {Struct} _params Scroll area and orientation
function LuiScrollBar(_params) : LuiBase({x: 0, y: 0, width: 1, height: 1}) constructor {
	// STATE

	if is_array(self._debug_param_keys) {
		self._debug_param_keys = variable_struct_get_names(_params);
	}
	self._area = _params.area;
	self._horizontal = _params[$ "horizontal"] ?? false;
	self._keyboard_focusable = false;
	self.setPositionAbsolute();

	// INTERNALS

	self._overlay_bounds = function() {
		var _bar = _luiGetScrollBarGeometry(self._area, self._horizontal);
		if is_undefined(_bar) return {left: self._area.x, top: self._area.y, width: 0, height: 0};
		return {left: _bar.x, top: _bar.y, width: _bar.width, height: _bar.height};
	}

	// DRAW

	self.draw = function() {
		var _style = self._area.getStyle();
		if !is_undefined(_style.sprite_scroll_slider) {
			draw_sprite_stretched_ext(_style.sprite_scroll_slider, 0, self.x, self.y, self.width, self.height, _style.color_back, draw_get_alpha());
		} else {
			var _color = _style.color_back;
			draw_rectangle_color(self.x, self.y, self.x + self.width, self.y + self.height, _color, _color, _color, _color, false);
		}
	}

	// EVENT HANDLERS

	self.addEvent(LUI_EV_CREATE, function(_e) {
		_e.addContentDirect(new LuiScrollThumb({panel: _e._area, horizontal: _e._horizontal}));
	});

	self.addEvent(LUI_EV_POINTER_DOWN, function(_e, _data) {
		if _data.button != mb_left || _data.target != _e return;
		var _area = _e._area;
		var _bar = _luiGetScrollBarGeometry(_area, _e._horizontal);
		if is_undefined(_bar) return;
		var _pointer = (_e._horizontal ? device_mouse_x_to_gui(0) : device_mouse_y_to_gui(0)) - _bar.start;
		if _pointer >= _bar.thumb_offset && _pointer <= _bar.thumb_offset + _bar.thumb_length return;
		var _delta = _pointer < _bar.thumb_offset ? -_bar.page : _bar.page;
		if _e._horizontal {
			_area.scroll_target_offset_x = clamp(_area.scroll_offset_x - _delta, _bar.limit, 0);
		} else {
			_area.scroll_target_offset_y = clamp(_area.scroll_offset_y - _delta, _bar.limit, 0);
		}
	});
}

///@desc Draggable button used as the thumb of a scroll bar.
/// Available parameters:
/// panel
/// horizontal
///@arg {Struct} [_params] Struct with parameters
function LuiScrollThumb(_params = {}) : LuiButton({x: 0, y: 0, width: 1, height: 1}) constructor {
	// STATE

	if is_array(self._debug_param_keys) {
		self._debug_param_keys = variable_struct_get_names(_params);
	}
	self._panel = _params[$ "panel"];
	self._horizontal = _params[$ "horizontal"] ?? false;
	self._grab_fraction = 0;
	self._keyboard_focusable = false;
	self.can_drag = true;
	self.setPositionAbsolute();

	// INTERNALS

	self._overlay_bounds = function() {
		var _bar = _luiGetScrollBarGeometry(self._panel, self._horizontal);
		if is_undefined(_bar) {
			return {left: self._panel.x, top: self._panel.y, width: 0, height: 0};
		}
		return {
			left: _bar.x + (self._horizontal ? _bar.thumb_offset : 0),
			top: _bar.y + (self._horizontal ? 0 : _bar.thumb_offset),
			width: self._horizontal ? _bar.thumb_length : _bar.width,
			height: self._horizontal ? _bar.height : _bar.thumb_length
		};
	}

	// UPDATE AND DRAW

	self.draw = function() {
		var _style = self._panel.getStyle();
		var _color = _style.color_secondary;
		if self.isMouseHovered() {
			_color = merge_color(_color, _style.color_hover, 0.5);
		}
		if self.is_pressed || self.is_dragging {
			_color = merge_color(_color, c_black, 0.5);
		}

		var _alpha = draw_get_alpha();
		if !is_undefined(_style.sprite_scroll_pin) {
			draw_sprite_stretched_ext(_style.sprite_scroll_pin, 0, self.x, self.y, self.width, self.height, _color, _alpha);
		} else {
			draw_rectangle_color(self.x, self.y, self.x + self.width, self.y + self.height,
				_color, _color, _color, _color, false);
		}
		if !is_undefined(_style.sprite_scroll_pin_border) {
			draw_sprite_stretched_ext(_style.sprite_scroll_pin_border, 0, self.x, self.y, self.width, self.height, _style.color_border, _alpha);
		}
	}

	// EVENT HANDLERS

	self.addEvent(LUI_EV_DRAG_START, function(_e) {
		var _panel = _e._panel;
		if _e._horizontal {
			_e._grab_fraction = clamp(_e.drag_offset_x / _e.width, 0, 1);
			_panel.scroll_target_offset_x = _panel.scroll_offset_x;
		} else {
			_e._grab_fraction = clamp(_e.drag_offset_y / _e.height, 0, 1);
			_panel.scroll_target_offset_y = _panel.scroll_offset_y;
		}
	});

	self.addEvent(LUI_EV_DRAGGING, function(_e, _data) {
		var _panel = _e._panel;
		var _bar = _luiGetScrollBarGeometry(_panel, _e._horizontal);
		if is_undefined(_bar) || _bar.travel <= 0 return;
		var _pointer = _e._horizontal ? _data.mouse_x : _data.mouse_y;
		var _position = _pointer - _bar.start - _e._grab_fraction * _bar.thumb_length;
		var _offset = clamp(_position / _bar.travel, 0, 1) * _bar.limit;
		if _e._horizontal {
			_panel.scroll_offset_x = _offset;
			_panel.scroll_target_offset_x = _offset;
		} else {
			_panel.scroll_offset_y = _offset;
			_panel.scroll_target_offset_y = _offset;
		}
		_panel._requestScrollUpdate();
	});

	self.addEvent(LUI_EV_DRAG_END, function(_e) {
		_e.invalidateCache();
	});
}

///@ignore
function _luiGetScrollBarGeometry(_area, _horizontal) {
	var _limit = _area._getMinScrollOffset(_horizontal);
	if _limit >= 0 return undefined;

	var _edge = _area._scrollbar_edge_inset;
	var _size = _area.getStyle().scroll_slider_width;
	var _o = _area._getScrollInsets();
	var _span = _horizontal ? _area.width - _o.right : _area.height - _o.bottom;
	var _page = _span - (_horizontal ? _o.left : _o.top);
	var _length = _span - 2 * _edge;
	if _length <= 0 || _size <= 0 || _page <= 0 return undefined;

	var _thumb_length = clamp(_length * _page / (_page - _limit), min(_size, _length * 0.5), _length);
	var _travel = _length - _thumb_length;
	var _offset = _horizontal ? _area.scroll_offset_x : _area.scroll_offset_y;
	return {
		x: _horizontal ? _area.x + _edge : _area.x + _area.width - _edge - _size,
		y: _horizontal ? _area.y + _area.height - _edge - _size : _area.y + _edge,
		width: _horizontal ? _length : _size,
		height: _horizontal ? _size : _length,
		start: _horizontal ? _area.x + _edge : _area.y + _edge,
		page: _page,
		limit: _limit,
		thumb_length: _thumb_length,
		thumb_offset: _travel * clamp(_offset / _limit, 0, 1),
		travel: _travel
	};
}
