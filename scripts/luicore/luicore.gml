//Info
#macro LIMEUI_VERSION "Alpha 0.1"

//Fonts
#macro LUI_FONT_BUTTONS					fArial_ru
//Colors
#macro LUI_FONT_COLOR					c_black
//Sprites
#macro LUI_SPRITE_PANEL					sUI_panel
#macro LUI_SPRITE_PANEL_BORDER			sUI_panel_border
#macro LUI_SPRITE_BUTTON				sUI_button
#macro LUI_SPRITE_BUTTON_BORDER			sUI_button_border
//Settings
#macro LUI_PADDING						16

//System (Dont touch)
#macro LUI_AUTO                         ptr(0)
#macro LUI_INLINE                       ptr(1)
#macro LUI_BASE                         ptr(2)
#macro LUI_AUTO_NO_SPACING              ptr(3)

#macro LUI_OVERLAY						_LuiGetOverlay()

//Globals
global.LUI_OVERLAY_INSTANCE = undefined;
global.LUI_DEBUG_MODE =	0;

function LuiBase() constructor {
	self.name = undefined;
	self.value = undefined;
	
	self.x = 0;
	self.y = 0;
	self.width = display_get_gui_width();
	self.height = display_get_gui_height();
	self.root = undefined;
	
	self.contents = [];
	
	static get_last = function() {
        if (array_length(self.contents) == 0) return undefined;
        return self.contents[array_length(self.contents) - 1];
    };
	
	static add_content = function(elements) {
		//convert to array if one
		if !is_array(elements) elements = [elements];
		//adding
		var _x_offset = 0;
		var _y_offset = 0;
		for (var i = 0, count = array_length(elements); i < count; i++) {
		    var _element = elements[i];
			_element.root = self;
			
			//Move X
			if (is_ptr(_element.x) && _element.x == LUI_AUTO) {
				var _last = self.get_last();
				if (_last) {
					_element.x = _last.x + _last.width + LUI_PADDING;
					if _element.x + _element.width > self.x + self.width {
						_element.x = self.x + LUI_PADDING;
						_y_offset += _element.height + LUI_PADDING;
					}
				} else {
					_element.x = self.x + LUI_PADDING;
					if _element.x + _element.width > self.x + self.width {
						_element.x = self.x;
						_y_offset += _element.height;
					}
				}
			} else if (is_ptr(_element.x) && _element.x == LUI_AUTO_NO_SPACING) {
				var _last = self.get_last();
				if (_last) {
					_element.x = _last.x + _last.width;
					if _element.x + _element.width > self.x + self.width {
						_element.x = self.x;
						_y_offset += _element.height;
					}
				} else {
					_element.x = self.x;
					if _element.x + _element.width > self.x + self.width {
						_element.x = self.x;
						_y_offset += _element.height;
					}
				}
			}
			
			//Move Y
			if (is_ptr(_element.y) && _element.y == LUI_AUTO) {
				_element.y = self.y + LUI_PADDING + _y_offset;
            } else if (is_ptr(_element.y) && _element.y == LUI_AUTO_NO_SPACING) {
                _element.y = self.y + _y_offset;
            }
			
			array_push(self.contents, _element);
		}
		return self;
	}
	
	//Value setter and getter
    self.get = function() { return value; }
    self.set = function(value) { self.value = value; }
	self.center = function() {
		var _x = root == undefined ? 0 : root.x;
		var _y = root == undefined ? 0 : root.y;
		var _width = root == undefined ? display_get_gui_width() : root.width;
		var _height = root == undefined ? display_get_gui_height() : root.height;
		self.x = _x + _width div 2 - self.width div 2;
		self.y = _y + _height div 2 - self.height div 2;
		return self;
	}
	self.center_vertically = function() {
		var _y = root == undefined ? 0 : root.y;
		var _height = root == undefined ? display_get_gui_height() : root.height;
		self.y = _y + _height div 2 - self.height div 2;
		return self;
	}
	self.center_horizontally = function() {
		var _x = root == undefined ? 0 : root.x;
		var _width = root == undefined ? display_get_gui_width() : root.width;
		self.x = _x + _width div 2 - self.width div 2;
		return self;
	}
	
	self.callback = undefined;
	
	//
	self.mouse_hover = function() {
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		return (_mouse_x > self.x && _mouse_x < self.x + self.width && _mouse_y > self.y && _mouse_y < self.y + self.height)
	}
	
	//step
	self.step = function() { }
	
	//render
	self.draw = function() { }
	self.render = function() {
		if is_array(self.contents)
		for (var i = 0, _number_of_elements = array_length(self.contents); i < _number_of_elements; ++i) {
			var _element = self.contents[i];
			_element.draw();
			_element.render();
			_element.step();
			if global.LUI_DEBUG_MODE _element.render_debug();
		}
		//self.render_debug();
	}
	self.render_debug = function() {
		if global.LUI_DEBUG_MODE == 1 {
			draw_set_alpha(0.25);
			draw_set_color(c_red);
			
			draw_rectangle(self.x, self.y, self.x + self.width, self.y + self.height, true);
			draw_line(self.x, self.y, self.x + self.width, self.y + self.height);
			draw_line(self.x, self.y + self.height, self.x + self.width, self.y);
			
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_text(x, y, string(x) + "," + string(y));
			draw_text(x, y + 16, string(self.value));
			
			if self.mouse_hover() {
				draw_set_alpha(0.75);
				draw_set_color(c_blue);
				draw_rectangle(self.x, self.y, self.x + self.width, self.y + self.height, true);
			}
			
			if is_array(self.contents)
			for (var i = 0, _number_of_elements = array_length(self.contents); i < _number_of_elements; ++i) {
				var _element = self.contents[i];
				_element.render_debug();
			}
		}
	}
	
	//Clean up
	self.destroy = function() {
		if is_array(self.contents) {
			for (var i = 0, _number_of_elements = array_length(self.contents); i < _number_of_elements; ++i) {
			    var _element = self.contents[i];
				_element.destroy();
			}
		}
		print("element destroyed");
		delete _element;
	}
}

function _LuiGetOverlay() {
	static LuiOverlay = function() : LuiBase() constructor {
		self.baseRender = self.render;
		self.render = function() {
			if array_length(self.contents) > 0 {
				self.width = window_get_width();
	            self.height = window_get_height();
				draw_set_alpha(0.5);
				draw_set_color(c_black);
				draw_rectangle(0, 0, self.width, self.height, false);
				self.baseRender();
			}
		}
	}
	static inst = new LuiOverlay();
    return inst;
}

