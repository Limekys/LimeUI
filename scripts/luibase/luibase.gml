function LuiBase() constructor {
	self.name = "-unnamed-";
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
	self.callback = undefined;
	self.contents = [];
	
	//Focusing
	self.has_focus = false;
	static set_focus = function() {
		self.has_focus = true;
	}
	static remove_focus = function() {
		self.has_focus = false;
	}
	
	//Add content
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
			
			//Width
			if (is_ptr(_element.width) && _element.width == LUI_STRETCH)
			_element.stretch_horizontally(_x_padding);
			//Move X
			if is_ptr(_element.pos_x) {
				
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
			
			//Height
			if (is_ptr(_element.height) && _element.height == LUI_STRETCH)
			_element.stretch_vertically(_x_padding);
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
	
	//Setter and getter
	static get = function() { return self.value; }
	static set = function(value) { self.value = value; }
	
	//Alignment and sizes
	static center = function() {
		self.pos_x = root.width div 2 - self.width div 2;
		self.pos_y = root.height div 2 - self.height div 2;
		return self;
	}
	
	static center_vertically = function() {
		self.pos_y = root.height div 2 - self.height div 2;
		return self;
	}
	
	static center_horizontally = function() {
		self.pos_x = root.width div 2 - self.width div 2;
		return self;
	}
	
	static stretch_horizontally = function(padding) {
		var _last = root.get_last();
		if (_last) && (_last.pos_x + _last.width < root.width - self.min_width - padding) {
			self.width = root.width - (_last.pos_x + _last.width) - padding*2;
		} else {
			self.width = root.width - padding*2;
		}
		return self;
	}
	
	static stretch_vertically = function(padding) {
		var _last = root.get_last();
		if (_last) && (_last.pos_y + _last.height < root.height - self.min_height - padding) {
			self.height = root.height - (_last.pos_y + _last.height) - padding*2;
		} else {
			self.height = root.height - padding*2;
		}
		return self;
	}
	
	static set_callback = function(callback) {
		if callback == undefined {
			self.callback = function() {print(self.name)};
		} else {
			self.callback = method(self, callback);
		}
	}
	
	//Interactivity
	static mouse_hover = function() {
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		return point_in_rectangle(_mouse_x, _mouse_y, self.x, self.y, self.x + self.width - 1, self.y + self.height - 1);
	}
	
	//Update
	self.step = function() { }
	
	static update = function(x_offset ,y_offset) {
		self.x = self.pos_x + x_offset;
		self.y = self.pos_y + y_offset;
	}
	
	//render
	self.draw = function() { }
	
	static render = function(base_x = 0, base_y = 0) {
		if is_array(self.contents)
		for (var i = 0, _number_of_elements = array_length(self.contents); i < _number_of_elements; ++i) {
			var _element = self.contents[i];
			_element.update(base_x + self.pos_x, base_y + self.pos_y);
			_element.step();
			_element.draw();
			_element.render(self.x, self.y);
			if global.LUI_DEBUG_MODE _element.render_debug();
		}
		//self.render_debug(); //Not necessary since the first element will be the main container
	}
	
	static render_debug = function() {
		if global.LUI_DEBUG_MODE == 1 {
			draw_set_alpha(0.5);
			draw_set_color(c_red);
			
			draw_rectangle(self.x, self.y, self.x + self.width, self.y + self.height, true);
			draw_line(self.x, self.y, self.x + self.width, self.y + self.height);
			draw_line(self.x, self.y + self.height, self.x + self.width, self.y);
			
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_text(x, y, string(pos_x) + ":" + string(pos_y));
			draw_text(x, y + 16, string(self.value));
			
			if self.mouse_hover() {
				draw_set_alpha(0.75);
				draw_set_color(c_blue);
				draw_rectangle(self.x, self.y, self.x + self.width, self.y + self.height, true);
			}
		}
	}
	
	//Clean up
	static destroy = function() {
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