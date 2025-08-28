///@desc A draggable window with a header, similar to Windows windows
/// Available parameters:
/// title
///@arg {Struct} [_params] Struct with parameters
function LuiWindow(_params = {}) : LuiPanel(_params) constructor {
    
	self.setPositionAbsolute();
	
	self.title = _params[$ "title"] ?? "Title";
    
	self.is_minimized = false;
	self.window_header = undefined;
	self.header_height = LUI_AUTO;
	self.window_container = undefined;
	
	///@desc Set window title
	///@arg {string} _title
	static setTitle = function(_title) {
		self.title = _title;
		if !is_undefined(self.window_header) {
			self.window_header.text_title.setText(_title);
		}
		return self;
	}
	
	///@ignore
	static _initHeader = function() {
		if is_undefined(self.window_header) {
			self.window_header = new LuiWindowHeader({height: self.header_height, title: self.title})
				.setGap(0).setPadding(8).setFlexDirection(flexpanel_flex_direction.row);
			
			// Add title text to header
			self.window_header.text_title = new LuiText({x: 0, y: 0, value: self.title}).setMouseIgnore(true);
		    self.window_header.addContent(self.window_header.text_title);
			
			// Set parent window link
			self.window_header.parent_window = self;
		}
	}
	
	///@desc Create container
	///@ignore
	static _initWindowContainer = function() {
		if is_undefined(self.window_container) {
			self.window_container = new LuiContainer().setFullSize();
			self.setContainer(self.window_container);
		}
	}
	
	///@desc Change getContainer function for compatibility with setFlex... functions
	self.getContainer = function() {
		self._initWindowContainer();
		return self.container;
	}
	
	///@desc Original addContent for compatibility
	self.addContentOriginal = method(self, addContent);
	
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
	
    self.draw = function() {
		if self.window_container.visible {
			// Window
			if !is_undefined(self.style.sprite_tabs) {
				var _blend_color = self.style.color_primary;
				if self.deactivated {
					_blend_color = merge_color(_blend_color, c_black, 0.5);
				}
				draw_sprite_stretched_ext(self.style.sprite_tabs, 0, self.x, self.y + self.window_header.height, self.width, self.height - self.window_header.height, _blend_color, 1);
			}
			// Border
			if !is_undefined(self.style.sprite_tabs_border) {
				draw_sprite_stretched_ext(self.style.sprite_tabs_border, 0, self.x, self.y + self.window_header.height, self.width, self.height - self.window_header.height, self.style.color_border, 1);
			}
		}
    }
	
	self.addEvent(LUI_EV_CREATE, function(_e) {
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
	});
}

///@desc Header for LuiWindow, handles dragging and contains title/buttons
/// Available parameters:
/// title
///@arg {Struct} [_params] Struct with parameters
function LuiWindowHeader(_params = {}) : LuiBase(_params) constructor {
    
	self.can_drag = true;
	
	self.title = _params[$ "title"] ?? "Title";
	
	self.text_title = undefined;
	self.parent_window = undefined;
	
	static _initControlButtons = function() {
		var _button_size = 32; //???//
		var _close_button = new LuiButton({width: _button_size, height: _button_size, text: "X", color: self.style.color_semantic_error});
		var _minimize_button = new LuiButton({width: _button_size, height: _button_size, text: "-"});
		_close_button.addEvent(LUI_EV_CLICK, function(_e) {
			_e.parent.parent_window.closeWindow();
		});
		_minimize_button.addEvent(LUI_EV_CLICK, function(_e) {
			_e.parent.parent_window.toggleWindow();
		});
		self.addContent([_minimize_button, _close_button]);
	}
	
    // Draw method
    self.draw = function() {
        // Header
		if !is_undefined(self.style.sprite_tab) {
            var _blend_color = merge_color(self.style.color_primary, c_black, 0.25);
			//var _color = isMouseHovered() ? merge_color(_blend_color, self.style.color_hover, 0.5) : _blend_color;
            draw_sprite_stretched_ext(self.style.sprite_tab, 0, self.x, self.y, self.width, self.height, _blend_color, 1);
        }
		// Border
		if !is_undefined(self.style.sprite_tab_border) {
			draw_sprite_stretched_ext(self.style.sprite_tab_border, 0, self.x, self.y, self.width, self.height, self.style.color_border, 1);
		}
    }
	
	self.addEvent(LUI_EV_CREATE, function(_e) {
		_e._initControlButtons();
	});
	
	self.addEvent(LUI_EV_MOUSE_LEFT_PRESSED, function(_e) {
		_e.parent_window.bringToFront();
	});
	
	self.addEvent(LUI_EV_DRAGGING, function(_e, _data) {
		if (!is_undefined(_e.parent_window)) {
            var _new_pos_x = clamp(_data.new_x, 0, self.main_ui.width - self.width);
			var _new_pos_y = clamp(_data.new_y, 0, self.main_ui.height - self.height);
			_e.parent_window.setPosition(_new_pos_x, _new_pos_y);
        }
	});
}