///@desc A draggable window with a header, similar to Windows windows
/// Available parameters:
/// title
/// show_controls
///@arg {Struct} [_params] Struct with parameters
function LuiWindow(_params = {}) : LuiPanel(_params) constructor {
	// STATE

	self.setPositionAbsolute();

	self.title = _params[$ "title"] ?? "Title";
	self.show_controls = _params[$ "show_controls"] ?? true;

	self.is_minimized = false;
	self.window_header = undefined;
	self.window_container = undefined;
	self._viewport_resize_handler = undefined;

	// PUBLIC API

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
		return self.container;
	}

	///@desc Redirect addContent
	self.addContent = function(elements) {
		self._initWindowContainer();
		self.window_container.addContent(elements);
		return self;
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
			self.window_container = new LuiContainer().setFlexGrow(1);
			self.setContainer(self.window_container);
		}
	}

	///@desc Moves the window in GUI coordinates while keeping its header accessible.
	///@ignore
	static _moveInViewport = function(_x, _y) {
		var _ui = self.main_ui;
		var _bounds = flexpanel_node_layout_get_position(self.flex_node, false);
		if _ui.width <= 0 || _ui.height <= 0 || _bounds.width <= 0 || _bounds.height <= 0 return;

		var _max_x = _ui.width - _bounds.width;
		var _target_x = _max_x < 0 ? _max_x : clamp(_x, 0, _max_x);
		var _target_y = clamp(_y, 0, max(0, _ui.height - _bounds.height));
		if _target_x == _bounds.left && _target_y == _bounds.top return;

		var _relative = flexpanel_node_layout_get_position(self.flex_node);
		if _target_x != _bounds.left {
			var _left = _relative.left + _target_x - _bounds.left;
			flexpanel_node_style_set_position(self.flex_node, flexpanel_edge.left, _left, flexpanel_unit.point);
			self.auto_x = false;
		}
		if _target_y != _bounds.top {
			var _top = _relative.top + _target_y - _bounds.top;
			flexpanel_node_style_set_position(self.flex_node, flexpanel_edge.top, _top, flexpanel_unit.point);
			self.auto_y = false;
		}
		self.updateMainUiFlex();
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
		_e.addContentOriginal([
			_e.window_header,
			_e.window_container
		]);
		_e.bringToFront();
		_e._viewport_resize_handler = method(_e, function(_ui) {
			if self.is_destroyed || !self.visible return;

			var _bounds = flexpanel_node_layout_get_position(self.flex_node, false);
			self._moveInViewport(_bounds.left, _bounds.top);
		});
		_e.main_ui.addEvent(LUI_EV_SIZE_UPDATE, _e._viewport_resize_handler);
	});

	self.addEvent(LUI_EV_POINTER_DOWN, function(_e, _data) {
		if _data.button == mb_left {
			_e.bringToFront();
			_e.main_ui._raiseOwnedPopups(_e);
		}
	});

	self.addEvent(LUI_EV_DESTROY, function(_e) {
		if !is_undefined(_e._viewport_resize_handler) {
			_e.main_ui.removeEvent(LUI_EV_SIZE_UPDATE, _e._viewport_resize_handler);
			_e._viewport_resize_handler = undefined;
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
		self.addContentOriginal(self.text_title);
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
		self.addContentOriginal([_minimize_button, _close_button]);
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
