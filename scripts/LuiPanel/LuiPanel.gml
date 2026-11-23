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
		self._pending_focus_reveal = undefined;
		self._scroll_thumb_x = undefined;
		self._scroll_thumb_y = undefined;
		self._panel_insets = {left: 0, top: 0, right: 0, bottom: 0};
		self._viewport_insets = {left: 0, top: 0, right: 0, bottom: 0};
		self._scroll_layout_revision = -1;
		self._scroll_row_count = 0;
		self._scroll_rows = undefined;
		self._scroll_first_row = 0;
		self._scroll_end_row = 0;
		self.scroll_pin_edge_offset = 4;
		self.scroll_smoothness = 0.02;
		self.scroll_container = new LuiAbsoluteContainer({x: 0, y: 0});
		self.scroll_container._scroll_owner = self;
		// Keep the viewport fixed while the content moves beneath it.
		self.scroll_container.draw_content_in_cutted_region = true;
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
			self.resizer.addEvent(LUI_EV_DRAG_START, function(_e) {
				var _panel = _e.getData("panel");
				_e.setData("resize_start", {x: _e.x, y: _e.y, width: _panel.width, height: _panel.height});
			});
			self.resizer.addEvent(LUI_EV_DRAGGING, function(_e, _data) {
				var _panel = _e.getData("panel");
				var _start = _e.getData("resize_start");
				var _new_width = max(_start.width + _data.new_x - _start.x, _panel.min_width);
				var _new_height = max(_start.height + _data.new_y - _start.y, _panel.min_height);
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
		if self.scroll_x || self.scroll_y return self._panel_insets;
		return self._getStyleClipInsets(self.getStyle());
	}

	///@ignore
	static _getScrollInsets = function() {
		var _style = self.getStyle();
		var _o = self._getStyleClipInsets(_style);
		var _gutter = is_undefined(_style) ? 0 : _style.scroll_slider_width + self.scroll_pin_edge_offset;
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
	static _queueFocusReveal = function(_item) {
		self._pending_focus_reveal = _item;
		self._applyScroll();
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
	static _getScrollBar = function(_horizontal, _style) {
		var _limit = self._getMinScrollOffset(_horizontal);
		if _limit >= 0 return undefined;

		var _edge = self.scroll_pin_edge_offset;
		var _size = _style.scroll_slider_width;
		var _o = self._getScrollInsets();
		var _span = _horizontal ? self.width - _o.right : self.height - _o.bottom;
		var _page = _span - (_horizontal ? _o.left : _o.top);
		var _length = _span - 2 * _edge;
		if _length <= 0 || _size <= 0 || _page <= 0 return undefined;

		var _thumb_length = clamp(_length * _page / (_page - _limit), min(_size, _length * 0.5), _length);
		var _travel = _length - _thumb_length;
		var _offset = _horizontal ? self.scroll_offset_x : self.scroll_offset_y;
		return {
			x: _horizontal ? self.x + _edge : self.x + self.width - _edge - _size,
			y: _horizontal ? self.y + self.height - _edge - _size : self.y + _edge,
			width: _horizontal ? _length : _size,
			height: _horizontal ? _size : _length,
			start: _horizontal ? self.x + _edge : self.y + _edge,
			page: _page,
			limit: _limit,
			thumb_length: _thumb_length,
			thumb_offset: _travel * clamp(_offset / _limit, 0, 1),
			travel: _travel
		};
	}

	///@ignore
	static _pageScrollBar = function(_horizontal, _mx, _my, _style) {
		var _bar = self._getScrollBar(_horizontal, _style);
		if is_undefined(_bar) return false;
		if !point_in_rectangle(_mx, _my, _bar.x, _bar.y, _bar.x + _bar.width, _bar.y + _bar.height) return false;

		var _pointer = (_horizontal ? _mx : _my) - _bar.start;
		if _pointer >= _bar.thumb_offset && _pointer <= _bar.thumb_offset + _bar.thumb_length return true;
		var _delta = _pointer < _bar.thumb_offset ? _bar.page : -_bar.page;
		if _horizontal {
			self.scroll_target_offset_x = self.scroll_offset_x + _delta;
		} else {
			self.scroll_target_offset_y = self.scroll_offset_y + _delta;
		}
		return true;
	}

	///@ignore
	static _updateScrollThumbs = function() {
		if !is_undefined(self._scroll_thumb_x) && !self._scroll_thumb_x.is_destroyed {
			self._scroll_thumb_x._updateFlex(true);
		}
		if !is_undefined(self._scroll_thumb_y) && !self._scroll_thumb_y.is_destroyed {
			self._scroll_thumb_y._updateFlex(true);
		}
	}

	// UPDATE AND DRAW

	///@ignore
	static _stepScroll = function() {
		var _allowed = self.main_ui.isInputAllowed(self);
		var _wheel = mouse_wheel_up() - mouse_wheel_down();
		var _pressed = mouse_check_button_pressed(mb_left);
		var _held = mouse_check_button(mb_left);
		if _pressed {
			self._drag_origin = undefined;
		}
		if _allowed && (_wheel != 0 || _pressed) {
			var _mx = device_mouse_x_to_gui(0);
			var _my = device_mouse_y_to_gui(0);
			var _hit = self.main_ui._getTopmostElement(_mx, _my);
			var _hit_can_drag = !is_undefined(_hit) && _hit.can_drag;
			while !is_undefined(_hit) {
				if _hit == self {
					var _style = self.getStyle();
					var _step = _style.scroll_step * _wheel;
					if self.scroll_x && (!self.scroll_y || keyboard_check(vk_shift)) {
						self.scroll_target_offset_x += _step;
					} else {
						self.scroll_target_offset_y += _step;
					}
					if _pressed && !_hit_can_drag {
						var _bar_pressed = (self.scroll_x && self._pageScrollBar(true, _mx, _my, _style))
							|| (self.scroll_y && self._pageScrollBar(false, _mx, _my, _style));
						if !_bar_pressed {
							self._drag_origin = {x: _mx, y: _my};
						}
					}
					break;
				}
				if is_instanceof(_hit, LuiPanel) && (_hit.scroll_x || _hit.scroll_y) {
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
			self._applyScroll();
		}
	}

	///@ignore
	static _drawScrollBar = function(_horizontal, _style, _alpha) {
		var _bar = self._getScrollBar(_horizontal, _style);
		if is_undefined(_bar) return;

		if !is_undefined(_style.sprite_scroll_slider) {
			draw_sprite_stretched_ext(_style.sprite_scroll_slider, 0, _bar.x, _bar.y, _bar.width, _bar.height, _style.color_back, _alpha);
		} else {
			draw_rectangle_color(_bar.x, _bar.y, _bar.x + _bar.width, _bar.y + _bar.height,
				_style.color_back, _style.color_back, _style.color_back, _style.color_back, false);
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
			_e.scroll_container._getClipInsets = method(_e, _e._getScrollContentInsets);
			_e.scroll_container.addEvent(LUI_EV_SIZE_UPDATE, function(_content) {
				// A partial layout can resize the content without visiting its sibling thumbs.
				_content._scroll_owner._updateScrollThumbs();
			});
			_e.addContentOriginal(_e.scroll_container);
			if _e.scroll_x {
				_e._scroll_thumb_x = new LuiScrollThumb({panel: _e, horizontal: true});
				_e.addContentOriginal(_e._scroll_thumb_x);
			}
			if _e.scroll_y {
				_e._scroll_thumb_y = new LuiScrollThumb({panel: _e});
				_e.addContentOriginal(_e._scroll_thumb_y);
			}
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

///@desc Draggable button used as a scroll thumb by LuiPanel.
/// Available parameters:
/// panel
/// horizontal
///@arg {Struct} [_params] Struct with parameters
function LuiScrollThumb(_params = {}) : LuiButton({x: 0, y: 0, width: 1, height: 1}) constructor {
	// STATE

	self._panel = _params[$ "panel"];
	self._horizontal = _params[$ "horizontal"] ?? false;
	self._grab_fraction = 0;
	self._keyboard_focusable = false;
	self.can_drag = true;
	self.setPositionAbsolute();

	// INTERNALS

	self._overlay_bounds = function() {
		var _bar = self._panel._getScrollBar(self._horizontal, self._panel.getStyle());
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
		var _bar = _panel._getScrollBar(_e._horizontal, _panel.getStyle());
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
		_panel._applyScroll();
	});

	self.addEvent(LUI_EV_DRAG_END, function(_e) {
		_e.updateMainUiSurface();
	});
}
