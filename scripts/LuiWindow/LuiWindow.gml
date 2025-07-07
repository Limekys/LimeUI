///@desc Header for LuiWindow, handles dragging and contains title/buttons
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
///@arg {String} title
function LuiWindowHeader(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = "LuiWindowHeader", title = "Title") : LuiBase() constructor {
    
	self.name = name;
    self.pos_x = x;
    self.pos_y = y;
    self.width = width;
    self.height = height;
    _initElement();
	
	self.title = title;
	self.parent_window = -1;
	self.can_drag = true;
    
	self.onCreate = function() { 
		
		self.setPositionType(flexpanel_position_type.absolute).setFlexGap(0).setFlexPadding(0).setFlexDirection(flexpanel_flex_direction.row);
		
		// Add title text
	    self.addContent(new LuiText(0, 0, LUI_AUTO, LUI_AUTO, , self.title).setMouseIgnore(true));
	    
	    // Add buttons (e.g., close, minimize)
	    var _button_size = self.height;
		var _close_button = new LuiButton(, , _button_size, _button_size, , "X").setColor(self.style.color_semantic_error);
	    var _minimize_button = new LuiButton(, , _button_size, _button_size, , "_");
	    
		_close_button.setCallback(function() {
			self.parent.parent_window.closeWindow();
		});
		
		_minimize_button.setCallback(function() {
			self.parent.parent_window.toggleWindow();
		});
		
		self.addContent([_minimize_button, _close_button]);
	}
	
    // Draw method
    self.draw = function() {
        // Header
		if !is_undefined(self.style.sprite_tab) {
            var _blend_color = merge_colour(self.style.color_primary, c_black, 0.25);
			//var _color = isMouseHovered() ? merge_colour(_blend_color, self.style.color_hover, 0.5) : _blend_color;
            draw_sprite_stretched_ext(self.style.sprite_tab, 0, self.x, self.y, self.width, self.height, _blend_color, 1);
        }
		// Border
		if !is_undefined(self.style.sprite_tab_border) {
			draw_sprite_stretched_ext(self.style.sprite_tab_border, 0, self.x, self.y, self.width, self.height, self.style.color_border, 1);
		}
    }
    
	// Mouse events for dragging
    self.onMouseLeftPressed = function() {
		self.parent_window.bringToFront();
		self.bringToFront();
    }
	
    // Dragging window
    self.onDragging = function(_mouse_x, _mouse_y) {
        if (!is_undefined(self.parent_window)) {
            self.parent_window.setPosition(self.pos_x, self.pos_y + self.height);
        }
    }
}

///@desc A draggable window with a header, similar to Windows windows
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
///@arg {String} title
function LuiWindow(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = "LuiWindow", title = "Window") : LuiPanel(x, y, width, height, name) constructor {
    
	self.name = name;
    self.pos_x = x;
    self.pos_y = y;
    self.width = width;
    self.height = height;
    _initElement();
	
	self.title = title;
    self.is_minimized = false;
	self.window_header = undefined;
	self.header_height = 32;
	
	self.onCreate = function() {
		self.setPositionType(flexpanel_position_type.absolute);
		self._initHeader();
		self.setPosition(, self.window_header.pos_y + self.header_height);
	}
	
	static _initHeader = function() {
		if is_undefined(self.window_header) {
			self.window_header = new LuiWindowHeader(self.pos_x, self.pos_y, self.width, self.header_height, , self.title)
				.setMinHeight(self.header_height);
			self.main_ui.addContent(self.window_header);
			self.window_header.parent_window = self;
			self.bringToFront();
			self.window_header.bringToFront();
			self.setPosition(self.pos_x, self.pos_y + self.header_height);
		}
	}
	
	static toggleWindow = function() {
		self.setVisible(!self.visible);
	}
	
	static closeWindow = function() {
		self.window_header.destroy();
		self.destroy();
	}
	
    self.draw = function() {
		// Window
		if !is_undefined(self.style.sprite_tabgroup) {
			var _blend_color = self.style.color_primary;
			if self.deactivated {
				_blend_color = merge_colour(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_tabgroup, 0, self.x, self.y, self.width, self.height, _blend_color, 1);
		}
		// Border
		if !is_undefined(self.style.sprite_tabgroup_border) {
			draw_sprite_stretched_ext(self.style.sprite_tabgroup_border, 0, self.x, self.y, self.width, self.height, self.style.color_border, 1);
		}
    }
	
	// Mouse events for dragging
    self.onMouseLeftPressed = function() {
		self.bringToFront();
		self.window_header.bringToFront();
    }
}