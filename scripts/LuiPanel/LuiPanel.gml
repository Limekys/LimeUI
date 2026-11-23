///@desc A visually visible container for placing elements in it.
/// During vertical scrolling, offscreen rows in an ordered list refresh their screen position when they enter the viewport.
/// Use getLayoutBounds() to query the current position of an offscreen row.
/// Available parameters:
/// allow_resize
/// scroll_x
/// scroll_y
///@arg {Struct} [_params] Struct with parameters
function LuiPanel(_params = {}) : LuiBase(_params) constructor {
	// STATE

	self.allow_resize = _params[$ "allow_resize"] ?? false;
	
	self.resizer = undefined;
	self.scroll_x = _params[$ "scroll_x"] ?? false;
	self.scroll_y = _params[$ "scroll_y"] ?? false;
	if self.scroll_x || self.scroll_y {
		self.draw_content_in_cutted_region = true;
		self.scroll_offset_x = 0;
		self.scroll_offset_y = 0;
		self.scroll_target_offset_x = 0;
		self.scroll_target_offset_y = 0;
		self._drag_origin = undefined;
		self._scroll_layout_revision = -1;
		self._scroll_row_count = 0;
		self._scroll_rows = undefined;
		self._scroll_first_row = 0;
		self._scroll_end_row = 0;
		self.scroll_pin_edge_offset = 4;
		self.scroll_smoothness = 0.02;
		self.scroll_container = new LuiAbsoluteContainer({x: 0, y: 0});
		self.scroll_container._scroll_owner = self;
		self.setContainer(self.scroll_container);
		self._scroll_insets = {left: 0, top: 0, right: 0, bottom: 0};
		self.addContent = function(elements) {
			self.scroll_container.addContent(elements);
			return self;
		}
	}
	
	// PUBLIC API

	///@desc Set allow to resize panel or not
	///@arg {bool} _allow
	static setAllowResize = function(_allow) {
		self.allow_resize = _allow;
		if _allow {
			self._initResizer();
		} else {
			if !is_undefined(self.resizer) {
				self.resizer.destroy();
				self.resizer = undefined;
			}
		}
		return self;
	}
	
	// INTERNALS

	///@ignore
	static _initResizer = function() {
		if is_undefined(self.resizer) && self.allow_resize {
			self.resizer = new LuiBox({r: 0, b: 0, w: 8, h: 8, color: c_red, alpha: 0}).setPositionAbsolute(); //???//
			self.resizer.can_drag = true;
			self.resizer.setData("panel", self);
			self.resizer.addEvent(LUI_EV_DRAGGING, function(_e, _data) {
				var _new_x = _data.new_x;
				var _new_y = _data.new_y;
				var _panel = _e.getData("panel");
				var _new_width = max(_new_x - _panel.x, _panel.min_width);
				var _new_height = max(_new_y - _panel.y, _panel.min_height);
				_panel.setSize(_new_width, _new_height);
			});
			if LUI_ALLOW_CHANGE_CURSOR {
				self.resizer.addEvent(LUI_EV_MOUSE_ENTER, function() {
					window_set_cursor(cr_size_nwse);
				});
				self.resizer.addEvent(LUI_EV_MOUSE_LEAVE, function() {
					window_set_cursor(cr_default);
				});
			}
			self.addContentOriginal(self.resizer);
		}
	}
	
	///@ignore
	static _getClipInsets = function() {
		var _style = self.getStyle();
		var _o = is_undefined(_style) ? self.render_region_offset : _style.render_region_offset;
		if !self.scroll_x && !self.scroll_y return _o;
		var _gutter = is_undefined(_style) ? 0 : _style.scroll_slider_width + self.scroll_pin_edge_offset;
		var _insets = self._scroll_insets;
		_insets.left = _o.left;
		_insets.top = _o.top;
		_insets.right = self.scroll_y ? max(_o.right, _gutter) : _o.right;
		_insets.bottom = self.scroll_x ? max(_o.bottom, _gutter) : _o.bottom;
		return _insets;
	}

	///@ignore
	static _applyScroll = function() {
		var _queue = self.main_ui._scroll_updates;
		if !array_contains(_queue, self.scroll_container) {
			array_push(self.main_ui._scroll_updates, self.scroll_container);
		}
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
	static _updateScrollRows = function(_reuse_bounds, _offset_x, _offset_y) {
		var _container = self.scroll_container;
		var _children = _container.content;
		var _count = array_length(_children);
		var _revision = self.main_ui._layout_revision;
		var _rebuild = !_reuse_bounds || self._scroll_layout_revision != _revision || self._scroll_row_count != _count;
		if _rebuild || is_undefined(self._scroll_rows) {
			for (var i = 0; i < _count; i++) {
				_children[i]._updateFlex(!_rebuild, _offset_x, _offset_y);
			}
			if !_rebuild return;
			self._scroll_rows = self._indexScrollRows(_children, _container._flex_bounds.top);
			self._scroll_row_count = _count;
			self._scroll_layout_revision = _revision;
		}

		var _rows = self._scroll_rows;
		if is_undefined(_rows) return;
		var _clip = _container.child_region;
		var _first = self._findScrollRow(_rows, _clip.y1 - _container.y, true);
		var _end = max(_first, self._findScrollRow(_rows, _clip.y2 - _container.y, false));
		if !_rebuild {
			// Clear rows leaving the viewport before refreshing the new range.
			for (var i = self._scroll_first_row; i < self._scroll_end_row; i++) {
				if i >= _first && i < _end continue;
				_rows[i].element._propagateVisibleRegionState();
			}
			for (var i = _first; i < _end; i++) {
				_rows[i].element._updateFlex(true, _offset_x, _offset_y);
			}
		}
		self._scroll_first_row = _first;
		self._scroll_end_row = _end;
	}

	///@ignore
	static _getMinScrollOffset = function(_horizontal = false) {
		var _content = self.scroll_container._flex_bounds;
		if is_undefined(_content) || is_undefined(self._flex_bounds) return 0;
		var _o = self._getClipInsets();
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
		var _o = self._getClipInsets();
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

	// UPDATE AND DRAW

	///@ignore
	static _stepScroll = function() {
		var _allowed = self.main_ui.isInputAllowed(self);
		var _wheel = mouse_wheel_up() - mouse_wheel_down();
		var _pressed = mouse_check_button_pressed(mb_left);
		if _allowed && (_wheel != 0 || _pressed) {
			var _hit = self.main_ui._getTopmostElement(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0));
			while !is_undefined(_hit) {
				if _hit == self {
					var _step = self.getStyle().scroll_step * _wheel;
					if self.scroll_x && (!self.scroll_y || keyboard_check(vk_shift)) {
						self.scroll_target_offset_x += _step;
					} else {
						self.scroll_target_offset_y += _step;
					}
					if _pressed {
						self._drag_origin = {x: device_mouse_x_to_gui(0), y: device_mouse_y_to_gui(0)};
					}
					break;
				}
				if is_instanceof(_hit, LuiPanel) && (_hit.scroll_x || _hit.scroll_y) {
					break;
				}
				_hit = _hit.parent;
			}
		}

		if !_allowed || !mouse_check_button(mb_left) || !is_undefined(self.main_ui.dragging_element) {
			self._drag_origin = undefined;
		} else if !is_undefined(self._drag_origin) {
			var _mx = device_mouse_x_to_gui(0);
			var _my = device_mouse_y_to_gui(0);
			self.scroll_target_offset_x += _mx - self._drag_origin.x;
			self.scroll_target_offset_y += _my - self._drag_origin.y;
			self._drag_origin.x = _mx;
			self._drag_origin.y = _my;
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
			self._applyScroll();
		}
	}

	///@ignore
	static _drawScrollBar = function(_horizontal, _style, _alpha) {
		var _edge = self.scroll_pin_edge_offset;
		var _size = _style.scroll_slider_width;
		var _o = self._getClipInsets();
		var _length = (_horizontal ? self.width - _o.right : self.height - _o.bottom) - 2 * _edge;
		if _length <= 0 return;
		var _x = _horizontal ? self.x + _edge : self.x + self.width - _edge - _size;
		var _y = _horizontal ? self.y + self.height - _edge - _size : self.y + _edge;
		if !is_undefined(_style.sprite_scroll_slider) {
			draw_sprite_stretched_ext(_style.sprite_scroll_slider, 0, _x, _y, _horizontal ? _length : _size, _horizontal ? _size : _length, _style.color_back, _alpha);
		}
		var _limit = self._getMinScrollOffset(_horizontal);
		var _offset = _horizontal ? self.scroll_offset_x : self.scroll_offset_y;
		var _travel = _limit < 0 ? max(0, _length - _size) * clamp(_offset / _limit, 0, 1) : 0;
		if _horizontal {
			_x += _travel;
		} else {
			_y += _travel;
		}
		if !is_undefined(_style.sprite_scroll_pin) {
			draw_sprite_stretched_ext(_style.sprite_scroll_pin, 0, _x, _y, _size, _size, _style.color_secondary, _alpha);
		}
		if !is_undefined(_style.sprite_scroll_pin_border) {
			draw_sprite_stretched_ext(_style.sprite_scroll_pin_border, 0, _x, _y, _size, _size, _style.color_border, _alpha);
		}
	}

	if self.scroll_x || self.scroll_y {
		self.step = method(self, self._stepScroll);
	}

	self.draw = function() {
		var _style = self.getStyle();
		var _alpha = draw_get_alpha();
		//Shadow
		//var _left = (sprite_get_width(sUI_Square_21r_shadow) - sprite_get_width(_style.sprite_panel)) div 2;
		//var _right = (sprite_get_width(sUI_Square_21r_shadow) - sprite_get_width(_style.sprite_panel)) div 2;
		//var _top = (sprite_get_height(sUI_Square_21r_shadow) - sprite_get_height(_style.sprite_panel)) div 2 - 2;
		//var _bottom = (sprite_get_height(sUI_Square_21r_shadow) - sprite_get_height(_style.sprite_panel)) div 2 + 1;
		//draw_sprite_stretched_ext(sUI_Square_21r_shadow, 0, self.x - _left, self.y - _top, self.width + _right*2, self.height + _bottom*2, c_white, 1);
		// Base
		if !is_undefined(_style.sprite_panel) {
			var _blend_color = _style.color_primary; //???// self.nesting_level == 1 ? _style.color_primary : merge_color(_style.color_primary, _style.color_secondary, 0.25);
			if self.deactivated {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(_style.sprite_panel, 0, self.x, self.y, self.width, self.height, _blend_color, _alpha);
		}
		if (self.scroll_x || self.scroll_y) && array_length(self.scroll_container.content) > 0 {
			if self.scroll_x {
				self._drawScrollBar(true, _style, _alpha);
			}
			if self.scroll_y {
				self._drawScrollBar(false, _style, _alpha);
			}
		}
		// Border
		if !is_undefined(_style.sprite_panel_border) {
			draw_sprite_stretched_ext(_style.sprite_panel_border, 0, self.x, self.y, self.width, self.height, _style.color_border, _alpha);
		}
	}
	
	// EVENT HANDLERS

	self.addEvent(LUI_EV_CREATE, function(_e) {
		if _e.scroll_x || _e.scroll_y {
			_e.addContentOriginal(_e.scroll_container);
			if _e.auto_height {
				flexpanel_node_style_set_flex(_e.flex_node, 1);
			}
			var _gutter = _e.getStyle().scroll_slider_width + _e.scroll_pin_edge_offset;
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
		_e._initResizer();
	});
}
