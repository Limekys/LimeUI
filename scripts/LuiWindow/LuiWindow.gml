///@desc A draggable window with a header, similar to Windows windows
/// Available parameters:
/// title
/// show_controls
/// allow_resize
/// scroll_x
/// scroll_y
///@arg {Struct} [_params] Struct with parameters
function LuiWindow(_params = {}) : LuiBase(_params) constructor {
	// STATE

	self.allow_resize = _params[$ "allow_resize"] ?? false;
	self.resizer = undefined;

	self.setPositionAbsolute();

	self.title = _params[$ "title"] ?? "Title";
	self.show_controls = _params[$ "show_controls"] ?? true;

	self.is_minimized = false;
	self.window_header = undefined;
	self.window_container = undefined;
	self._body_scroll_x = _params[$ "scroll_x"] ?? false;
	self._body_scroll_y = _params[$ "scroll_y"] ?? false;
	self._viewport_align_right = true;
	self.setKeepInViewport();

	// PUBLIC API

	///@desc Enables or disables resizing with the bottom-right handle.
	///@arg {Bool} _allow Allow pointer resizing
	///@return {Struct} This element
	static setAllowResize = function(_allow) {
		self.allow_resize = _allow;
		if is_undefined(self.main_ui) || self.is_destroyed return self;

		if _allow && is_undefined(self.resizer) {
			self.resizer = new LuiResizeHandle(self);
			self.resizer._applySize(self.getStyle());
			self.addContentDirect(self.resizer);
		} else if !_allow && !is_undefined(self.resizer) {
			self.resizer.destroy();
			self.resizer = undefined;
		}
		return self;
	}

	///@desc Set window title
	///@arg {string} _title
	static setTitle = function(_title) {
		self.title = _title;
		if !is_undefined(self.window_header) {
			self.window_header.text_title.setText(_title);
		}
		return self;
	}

	///@desc Show controls buttons or not
	///@arg {bool} _show
	static showControls = function(_show) {
		self.show_controls = _show;
		if !is_undefined(self.window_header) {
			self.window_header.show_controls = _show;
			if _show {
				self.window_header._initControlButtons();
			}
		}
		return self;
	}

	///@desc Change getContainer function for compatibility with setFlex... functions
	self.getContainer = function() {
		self._initWindowContainer();
		return self.window_container.getContainer();
	}

	///@desc Toggle window show or hide
	static toggleWindow = function() {
		self.window_container.setVisible(!self.window_container.visible);
		self.ignore_mouse = !self.window_container.visible;
	}

	///@desc Destroy window
	static closeWindow = function() {
		self.destroy();
	}

	// INTERNALS

	///@ignore
	static _initHeader = function() {
		if is_undefined(self.window_header) {
			self.window_header = new LuiWindowHeader({title: self.title, show_controls: self.show_controls})
				.setFlexDirection(flexpanel_flex_direction.row);

			// Set parent window link
			self.window_header.parent_window = self;
		}
	}

	///@desc Create container
	///@ignore
	static _initWindowContainer = function() {
		if is_undefined(self.window_container) {
			self.window_container = new LuiScrollArea({scroll_x: self._body_scroll_x, scroll_y: self._body_scroll_y}).setFlexGrow(1);
			self.setContainer(self.window_container);
		}
	}

	///@desc Moves the window in GUI coordinates while keeping its header accessible.
	///@ignore
	static _moveInViewport = function(_x, _y) {
		var _bounds = self.getLayoutBounds();
		if self._keep_in_viewport {
			self._moveAbsoluteInViewport(_bounds.left, _bounds.top, _bounds.width, _bounds.height, _x, _y);
		} else {
			var _relative = self.getLayoutBounds(true);
			self.setPosition(_relative.left + _x - _bounds.left, _relative.top + _y - _bounds.top);
		}
	}

	// DRAW

	self.draw = function() {
		if self.window_container.visible {
			var _style = self.getStyle();
			var _alpha = draw_get_alpha();
			// Window
			if !is_undefined(_style.sprite_tabs) {
				var _blend_color = _style.color_primary;
				if self.deactivated {
					_blend_color = merge_color(_blend_color, c_black, 0.5);
				}
				draw_sprite_stretched_ext(_style.sprite_tabs, 0, self.x, self.y + self.window_header.height, self.width, self.height - self.window_header.height, _blend_color, _alpha);
			}
			// Border
			if !is_undefined(_style.sprite_tabs_border) {
				draw_sprite_stretched_ext(_style.sprite_tabs_border, 0, self.x, self.y + self.window_header.height, self.width, self.height - self.window_header.height, _style.color_border, _alpha);
			}
		}
	}

	// EVENT HANDLERS

	self.addEvent(LUI_EV_CREATE, function(_e) {

		// pop-in animation
		_e.visual_alpha = 0;
		_e.visual_scale_x = 0.75;
		_e.visual_scale_y = 0.75;
		self.main_ui.animate(_e, "visual_alpha", 1, 0.25);
		self.main_ui.animate(_e, "visual_scale_x", 1, 0.25, global.Ease.OutBack);
		self.main_ui.animate(_e, "visual_scale_y", 1, 0.25, global.Ease.OutBack);

		// Window settings
		if _e.auto_width {
			_e.setWidth(256);
		}
		_e._initHeader();
		_e._initWindowContainer();
		_e.addContentDirect([
			_e.window_header,
			_e.window_container
		]);
		_e.setAllowResize(_e.allow_resize);
		_e.bringToFront();
	});

	self.addEvent(LUI_EV_STYLE_UPDATE, function(_e, _style) {
		if !is_undefined(_e.resizer) {
			_e.resizer._applySize(_style);
		}
	});

	self.addEvent(LUI_EV_KEYBOARD_CANCEL, function(_e) {
		_e.closeWindow();
	});

	self.addEvent(LUI_EV_POINTER_DOWN, function(_e, _data) {
		if _data.button == mb_left {
			_e.bringToFront();
			_e.main_ui._raiseOwnedPopups(_e);
		}
	});

	self.addEvent(LUI_EV_DESTROY, function(_e) {
		if !is_undefined(_e.window_container) && !_e.window_container.is_destroyed {
			_e.window_container.destroy();
		}
	});
}

///@desc Header for LuiWindow, handles dragging and contains title/buttons
/// Available parameters:
/// title
///@arg {Struct} [_params] Struct with parameters
function LuiWindowHeader(_params = {}) : LuiBase(_params) constructor {
	// STATE

	self.can_drag = true;

	self.title = _params[$ "title"] ?? "Title";
	self.show_controls = _params[$ "show_controls"] ?? true;

	self.text_title = undefined;
	self.parent_window = undefined;

	// INTERNALS

	///@ignore
	static _initTitle = function() {
		self.text_title = new LuiText({value: self.title}).setMouseIgnore(true);
		self.addContentDirect(self.text_title);
	}

	///@ignore
	static _initControlButtons = function() {
		var _button_size = 32; //???//
		var _close_button = new LuiButton({width: _button_size, height: _button_size, text: "X", color: self.getStyle().color_semantic_error});

		var _minimize_button = new LuiButton({width: _button_size, height: _button_size, text: "-"});
		_close_button.addEvent(LUI_EV_CLICK, function(_e) {
			_e.parent.parent_window.closeWindow();
		});
		_minimize_button.addEvent(LUI_EV_CLICK, function(_e) {
			_e.parent.parent_window.toggleWindow();
		});
		self.addContentDirect([_minimize_button, _close_button]);
	}

	// DRAW

	self.draw = function() {
		var _style = self.getStyle();
		var _alpha = draw_get_alpha();
		// Header
		if !is_undefined(_style.sprite_tab) {
			var _blend_color = merge_color(_style.color_primary, c_black, 0.25);
			draw_sprite_stretched_ext(_style.sprite_tab, 0, self.x, self.y, self.width, self.height, _blend_color, _alpha);
		}
		// Border
		if !is_undefined(_style.sprite_tab_border) {
			draw_sprite_stretched_ext(_style.sprite_tab_border, 0, self.x, self.y, self.width, self.height, _style.color_border, _alpha);
		}
	}

	// EVENT HANDLERS

	self.addEvent(LUI_EV_CREATE, function(_e) {
		_e._initTitle();
		if _e.show_controls {
			_e._initControlButtons();
		}
	});

	self.addEvent(LUI_EV_DRAGGING, function(_e, _data) {
		if !is_undefined(_e.parent_window) {
			var _window = _e.parent_window;
			_window._moveInViewport(_window.x + _data.new_x - _e.x, _window.y + _data.new_y - _e.y);
		}
	});
}

///@ignore
function LuiResizeHandle(_owner) : LuiBase({r: 0, b: 0}) constructor {
	// STATE

	self._owner = _owner;
	self._drag_start = undefined;
	self.can_drag = true;
	self.setPositionAbsolute().setLocalStyle({padding: 0, border: 0, margin: 0});

	// INTERNALS

	///@ignore
	static _applySize = function(_style) {
		var _size = max(1, round(_style.resize_handle_size));
		self.setMinWidth(_size).setMinHeight(_size).setSize(_size, _size);
	}

	// EVENT HANDLERS

	self.addEvent(LUI_EV_DRAG_START, function(_e) {
		_e._drag_start = {x: _e.x, y: _e.y, width: _e._owner.width, height: _e._owner.height};
	});
	self.addEvent(LUI_EV_DRAGGING, function(_e, _data) {
		var _owner = _e._owner;
		var _start = _e._drag_start;
		var _width = max(_start.width + _data.new_x - _start.x, _owner.min_width);
		var _height = max(_start.height + _data.new_y - _start.y, _owner.min_height);
		_owner.setSize(_width, _height);
	});
	if LUI_ALLOW_CHANGE_CURSOR {
		self.addEvent(LUI_EV_MOUSE_ENTER, function() {
			window_set_cursor(cr_size_nwse);
		});
		self.addEvent(LUI_EV_MOUSE_LEAVE, function() {
			window_set_cursor(cr_default);
		});
	}
}
