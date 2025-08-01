///@desc A draggable window with a header, similar to Windows windows
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
///@arg {String} title
function LuiWindow(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = LUI_AUTO_NAME, title = "Window") : LuiPanel(x, y, width, height, name) constructor {
    
	self.title = title;
    self.is_minimized = false;
	self.window_header = undefined;
	self.header_height = LUI_AUTO;
	
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
			self.window_header = new LuiWindowHeader(self.pos_x, self.pos_y, self.width, self.header_height, , self.title)
				.setPositionType(flexpanel_position_type.absolute).setGap(0).setPadding(8).setFlexDirection(flexpanel_flex_direction.row);
			
			// Add title text to header
			self.window_header.text_title = new LuiText(0, 0, LUI_AUTO, LUI_AUTO, , self.title).setMouseIgnore(true);
		    self.window_header.addContent(self.window_header.text_title);
		    
		    // Add buttons to header (e.g., close, minimize)
		    var _button_size = self.window_header.height;
			var _close_button = new LuiButton(, , _button_size, _button_size, , "X").setColor(self.style.color_semantic_error);
		    var _minimize_button = new LuiButton(, , _button_size, _button_size, , "-");
			_close_button.setCallback(function() {
				self.parent.parent_window.closeWindow();
			});
			_minimize_button.setCallback(function() {
				self.parent.parent_window.toggleWindow();
			});
			self.window_header.addContent([_minimize_button, _close_button]);
			
			self.main_ui.addContent(self.window_header);
			self.window_header.parent_window = self;
			self.bringToFront();
			self.window_header.bringToFront();
		}
	}
	
	///@desc Toggle window show or hide
	static toggleWindow = function() {
		self.setVisible(!self.visible);
	}
	
	///@desc Destroy window
	static closeWindow = function() {
		self.window_header.destroy();
		self.destroy();
	}
	
    self.draw = function() {
		// Window
		if !is_undefined(self.style.sprite_tabs) {
			var _blend_color = self.style.color_primary;
			if self.deactivated {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_tabs, 0, self.x, self.y, self.width, self.height, _blend_color, 1);
		}
		// Border
		if !is_undefined(self.style.sprite_tabs_border) {
			draw_sprite_stretched_ext(self.style.sprite_tabs_border, 0, self.x, self.y, self.width, self.height, self.style.color_border, 1);
		}
    }
	
	self.addEvent(LUI_EV_CREATE, function(_element) {
		_element.setPositionType(flexpanel_position_type.absolute);
		_element._initHeader();
	});
	
	self.addEvent(LUI_EV_MOUSE_LEFT_PRESSED, function(_element) {
		_element.bringToFront();
		_element.window_header.bringToFront();
	});
	
	self.addEvent(LUI_EV_DESTROY, function(_element) {
		if !is_undefined(_element.window_header) {
			_element.window_header.destroy();
		}
	});
}

///@desc Header for LuiWindow, handles dragging and contains title/buttons
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
///@arg {String} title
function LuiWindowHeader(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = LUI_AUTO_NAME, title = "Title") : LuiBase() constructor {
    
	self.name = name;
    self.pos_x = x;
    self.pos_y = y;
    self.width = width;
    self.height = height;
    _initElement();
	
	self.title = title;
	self.text_title = undefined;
	self.parent_window = -1;
	self.can_drag = true;
	
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
    
	self.addEvent(LUI_EV_CREATE, function(_element) {
		_element.parent_window.setPosition(_element.pos_x, _element.pos_y + _element.height);
	});
	
	self.addEvent(LUI_EV_MOUSE_LEFT_PRESSED, function(_element) {
		_element.parent_window.bringToFront();
		_element.bringToFront();
	});
	
	self.addEvent(LUI_EV_DRAGGING, function(_element) {
		if (!is_undefined(_element.parent_window)) {
            _element.parent_window.setPosition(_element.pos_x, _element.pos_y + _element.height);
        }
	});
	
	self.addEvent(LUI_EV_POSITION_UPDATE, function(_element) {
		if (!is_undefined(_element.parent_window)) {
            _element.parent_window.setPosition(_element.pos_x, _element.pos_y + _element.height);
        }
	});
}