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
#macro LUI_AUTO							ptr(0)
#macro LUI_AUTO_NO_PADDING				ptr(1)
#macro LUI_STRETCH						ptr(2)

#macro LUI_OVERLAY						_LuiGetOverlay()

//Globals
global.LUI_DEBUG_MODE =	0;

function LuiBase() constructor {
	self.name = "LuiBase";
	self.value = undefined;
	
	self.x = 0;	//Actual x position on the screen
	self.y = 0;	//Actual y position on the screen
	self.pos_x = 0;	//Offset x position this element relative parent
	self.pos_y = 0;	//Offset y position this element relative parent
	self.width = display_get_gui_width();
	self.height = display_get_gui_height();
	self.min_width = 32;
	self.min_height = 32;
	self.root = self;
	
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
			
			//Paddings
			var _x_padding = LUI_PADDING;
			var _y_padding = LUI_PADDING;
			if (is_ptr(_element.pos_x) && _element.pos_x == LUI_AUTO_NO_PADDING) _x_padding = 0;
			if (is_ptr(_element.pos_y) && _element.pos_y == LUI_AUTO_NO_PADDING) _y_padding = 0;
			
			var _last = self.get_last();
			//Move X
			if is_ptr(_element.pos_x) {
				//Width
				if (is_ptr(_element.width) && _element.width == LUI_STRETCH)
				_element.stretch_horizontally(_x_padding);
				//Move
				if (_last) {
					//For next element
					_element.pos_x = _last.pos_x + _last.width + _x_padding;
					if _element.pos_x + _element.width > self.width - _x_padding {
						_element.pos_x = _x_padding;
						if is_ptr(_element.pos_y) _element.pos_y = _last.pos_y + _last.height + _y_padding;
					}
				} else {
					//For first element
					_element.pos_x = _x_padding;
				}
			}
			
			//Move Y
			if is_ptr(_element.pos_y) {
				if (_last) {
					_element.pos_y = _last.pos_y;
				} else {
					_element.pos_y = _y_padding;
				}
            }
			
			array_push(self.contents, _element);
		}
		return self;
	}
	
	//Value setter and getter
    self.get = function() { return value; }
    self.set = function(value) { self.value = value; }
	self.center = function() {
		self.pos_x = root.width div 2 - self.width div 2;
		self.pos_y = root.height div 2 - self.height div 2;
		return self;
	}
	self.center_vertically = function() {
		self.pos_y = root.height div 2 - self.height div 2;
		return self;
	}
	self.center_horizontally = function() {
		self.pos_x = root.width div 2 - self.width div 2;
		return self;
	}
	self.stretch_horizontally = function(padding) {
		var _last = root.get_last();
		if (_last) && (_last.pos_x + _last.width < root.width - self.min_width - padding) {
			self.width = root.width - (_last.pos_x + _last.width) - padding*2;
		} else {
			self.width = root.width - padding*2;
		}
		return self;
	}
	
	self.callback = undefined;
	
	//Interactivity
	self.mouse_hover = function() {
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		return point_in_rectangle(_mouse_x, _mouse_y, self.x, self.y, self.x + self.width, self.y + self.height)
	}
	
	//Update
	self.step = function() { }
	self.update_position = function(x_offset ,y_offset) {
		self.x = self.pos_x + x_offset;
		self.y = self.pos_y + y_offset;
	}
	
	//render
	self.draw = function() { }
	self.render = function(base_x = 0, base_y = 0) {
		if is_array(self.contents)
		for (var i = 0, _number_of_elements = array_length(self.contents); i < _number_of_elements; ++i) {
			var _element = self.contents[i];
			_element.update_position(base_x + self.pos_x, base_y + self.pos_y);
			_element.step();
			_element.draw();
			_element.render(base_x + self.pos_x, base_y + self.pos_y);
			if global.LUI_DEBUG_MODE _element.render_debug();
		}
		//self.render_debug(); //Not necessary since the first element will be the main container
	}
	self.render_debug = function() {
		if global.LUI_DEBUG_MODE == 1 {
			draw_set_alpha(0.5);
			draw_set_color(c_red);
			
			draw_rectangle(self.x, self.y, self.x + self.width, self.y + self.height, true);
			draw_line(self.x, self.y, self.x + self.width, self.y + self.height);
			draw_line(self.x, self.y + self.height, self.x + self.width, self.y);
			
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_text(x, y, string(x) + ";" + string(y) + "(" + string(pos_x) + ";" + string(pos_y) + ")");
			draw_text(x, y + 16, string(self.value));
			
			if self.mouse_hover() {
				draw_set_alpha(0.75);
				draw_set_color(c_blue);
				draw_rectangle(self.x, self.y, self.x + self.width, self.y + self.height, true);
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
		print("element destroyed", self.name);
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
