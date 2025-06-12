///@desc Header for LuiWindow, handles dragging and contains title/buttons
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
///@arg {String} title
function LuiWindowHeader(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = "LuiWindowHeader", title = "Title") : LuiBase() constructor {
    self.name = name;
    self.pos_x = 0;
    self.pos_y = 0;
    self.width = width;
    self.height = height;
    self.title = title;
	self.parent_window = -1;
    _initElement();
	
    // Dragging state
    self.is_dragging = false;
    self.drag_offset_x = 0;
    self.drag_offset_y = 0;
    
	self.onCreate = function() { 
		
		self.setFlexGap(0).setFlexPadding(0).setFlexDirection(flexpanel_flex_direction.row);
		
		// Add title text
	    self.addContent(new LuiText(0, 0, LUI_AUTO, LUI_AUTO, , self.title).setMouseIgnore(true));
	    /*
	    // Add buttons (e.g., close, minimize)
	    var _button_size = self.height - 4;
	    var _close_button = new LuiButton(self.width - _button_size - 4, 2, _button_size, _button_size, "X");
	    _close_button.onClick = function() {
	        if (self.parent != undefined && self.parent.parent != undefined) {
	            self.parent.parent.destroy(); // Destroy the LuiWindow
	        }
	    };
	    var _minimize_button = new LuiButton(self.width - _button_size * 2 - 8, 2, _button_size, _button_size, "-");
	    _minimize_button.onClick = function() {
	        if (self.parent != undefined && self.parent.parent != undefined) {
	            self.parent.parent.is_minimized = !self.parent.parent.is_minimized;
	        }
	    };
	    self.addContent([_minimize_button, _close_button]);
		*/
	}
	
    // Draw method
    self.draw = function() {
        if !is_undefined(self.style.sprite_panel) {
            var _color = isMouseHovered() ? merge_colour(self.style.color_primary, c_white, 0.2) : self.style.color_primary;
            draw_sprite_stretched_ext(self.style.sprite_panel, 0, self.x, self.y, self.width, self.height, _color, 1);
        }
    };
    
    // Mouse events for dragging
    self.onMouseLeftPressed = function() {
		self.is_dragging = true;
		self.drag_offset_x = device_mouse_x_to_gui(0) - self.parent_window.x;
		self.drag_offset_y = device_mouse_y_to_gui(0) - self.parent_window.y;
		self.bringToFront();
    };
    
	self.onMouseLeft = function() {
		if (self.is_dragging) {
            var _new_pos_x = clamp(device_mouse_x_to_gui(0) - self.drag_offset_x, 0, display_get_gui_width() - self.width);
            var _new_pos_y = clamp(device_mouse_y_to_gui(0) - self.drag_offset_y, 0, display_get_gui_height() - self.height);
			//self.setPosition(_new_pos_x, _new_pos_y);
			self.parent_window.setPosition(_new_pos_x, _new_pos_y);
            self.updateMainUiSurface();
        }
	}
	
    self.onMouseLeftReleased = function() {
        self.is_dragging = false;
    };
}

///@desc A draggable window with a header, similar to Windows windows
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
///@arg {String} title
function LuiWindow(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = "LuiWindow", title = "Window") : LuiPanel(x, y, width, height, name) constructor {
    self.title = title;
    self.is_minimized = false;
    
	self.window_header = undefined;
	self.header_height = 64;
	self.window_container = undefined;
	
	self.onCreate = function() {
		self.setPositionType(flexpanel_position_type.absolute).setFlexPadding(0).setFlexGap(0);
		//self._initHeader();
    	//self.addContent(self.window_header);
		//self.window_header.parent_window = self;
		//self._initContainer();
		//self.addContent(self.window_container);
		
		//???// В общем то тут я запутался в порядке инициализации контейнеров и шапки че куда вообще 
	}
	
	static _initHeader = function() {
		if is_undefined(self.window_header) {
			self.window_header = new LuiWindowHeader(, , , self.header_height, , self.title)
				.setMinHeight(self.header_height);
			self.addContent(self.window_header);
			self.window_header.parent_window = self;
		}
	}
	
	static _initContainer = function() {
		if is_undefined(self.window_container) {
			self.window_container = new LuiContainer(0, 0, , , $"_window_container_{self.element_id}").setFlexGrow(1);
			self.setContainer(self.window_container);
			self.addContent(self.window_container);
		}
	}
	
	///@desc Works like usual addContent, but redirect add content to window_content
	self.addContent = function(elements) {
		self._initHeader();
		self._initContainer();
		self.window_container.addContent(elements);
		return self;
	}
	
    // Override draw to handle minimization
    self.draw = function() {
        if (self.is_minimized) {
            // Draw only header
            self.window_header.draw();
        } else {
            // Draw full panel (inherited)
            if !is_undefined(self.style.sprite_panel) {
                var _blend_color = self.style.color_primary;
                if self.deactivated {
                    _blend_color = merge_colour(_blend_color, c_black, 0.5);
                }
                draw_sprite_stretched_ext(self.style.sprite_panel, 0, self.x, self.y, self.width, self.height, _blend_color, 1);
            }
            // Border
            if !is_undefined(self.style.sprite_panel_border) {
                draw_sprite_stretched_ext(self.style.sprite_panel_border, 0, self.x, self.y, self.width, self.height, self.style.color_border, 1);
            }
        }
    };
}