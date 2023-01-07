function LuiBase(style = {}) constructor {
	self.name = "-unnamed-";
	self.value = undefined;
	self.style = new LuiStyle(style);
	
	self.x = 0;	//Actual x position on the screen
	self.y = 0;	//Actual y position on the screen
	self.pos_x = 0;	//Offset x position this element relative parent
	self.pos_y = 0;	//Offset y position this element relative parent
	self.target_x = 0; //Target x position this element for animation
	self.target_y = 0; //Target y position this element for animation
	self.start_x = self.pos_x;
	self.start_y = self.pos_y;
	self.width = display_get_gui_width();
	self.height = display_get_gui_height();
	self.min_width = 32;
	self.min_height = 32;
	self.root = self;
	self.callback = undefined;
	self.contents = [];
	self.marked_to_delete = false;
	self.is_mouse_hovered = false;
	
	//Focusing
	self.has_focus = false;
	///@func set_focus()
	static set_focus = function() {
		self.has_focus = true;
		return self;
	}
	///@func remove_focus()
	static remove_focus = function() {
		self.has_focus = false;
		return self;
	}
	
	//Add content
	///@func get_last()
	static get_last = function() {
        if (array_length(self.contents) == 0) return undefined;
        return self.contents[array_length(self.contents) - 1];
    };
	
	///@func add_content(elements)
	///@arg {array} elements
	static add_content = function(elements) {
		//convert to array if one
		if !is_array(elements) elements = [elements];
		//adding
		var _x_offset = 0;
		var _y_offset = 0;
		
		for (var i = 0; i < array_length(elements); i++) {
		    var _element = elements[i];
			_element.root = self;
			
			_element.style = new LuiStyle(self.style);

			
			//Paddings
			var _x_padding = self.style.padding;
			var _y_padding = self.style.padding;
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
			
			//Save new start x y position
			_element.start_x = _element.pos_x;
			_element.start_y = _element.pos_y;
			
			//Position to target position
			//_element.target_x = _element.pos_x;
			//_element.target_y = _element.pos_y;
			
			//Add to content array
			array_push(self.contents, _element);
		}
		return self;
	}
	
	//Setter and getter
	///@func get()
	static get = function() { return self.value; }
	///@func set()
	static set = function(value) { self.value = value; return self}
	
	//Alignment and sizes
	///@func center()
	static center = function() {
		self.pos_x = root.width div 2 - self.width div 2;
		self.pos_y = root.height div 2 - self.height div 2;
		self.target_x = root.width div 2 - self.width div 2;
		self.target_y = root.height div 2 - self.height div 2;
		return self;
	}
	
	///@func center_vertically()
	static center_vertically = function() {
		self.pos_y = root.height div 2 - self.height div 2;
		self.target_y = root.height div 2 - self.height div 2;
		return self;
	}
	
	///@func center_horizontally()
	static center_horizontally = function() {
		self.pos_x = root.width div 2 - self.width div 2;
		self.target_x = root.width div 2 - self.width div 2;
		return self;
	}
	
	///@func stretch_horizontally(padding)
	static stretch_horizontally = function(padding) {
		var _last = root.get_last();
		if (_last) && (_last.pos_x + _last.width < root.width - self.min_width - padding) {
			self.width = root.width - (_last.pos_x + _last.width) - padding*2;
		} else {
			self.width = root.width - padding*2;
		}
		return self;
	}
	
	///@func stretch_vertically(padding)
	static stretch_vertically = function(padding) {
		var _last = root.get_last();
		if (_last) && (_last.pos_y + _last.height < root.height - self.min_height - padding) {
			self.height = root.height - (_last.pos_y + _last.height) - padding*2;
		} else {
			self.height = root.height - padding*2;
		}
		return self;
	}
	
	//Design
	///@func set_color(main, border)
	set_color = function(main = undefined, border = undefined) {
		if !is_undefined(main) self.style.color_main = main;
		if !is_undefined(border) self.style.color_border = border;
		return self;
	}
	
	//Interactivity
	///@func set_callback(callback)
	static set_callback = function(callback) {
		if callback == undefined {
			self.callback = function() {print(self.name)};
		} else {
			self.callback = method(self, callback);
		}
		return self;
	}
	
	///@func mouse_hover()
	static mouse_hover = function() {
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		var _on_this = point_in_rectangle(_mouse_x, _mouse_y, self.x, self.y, self.x + self.width - 1, self.y + self.height - 1);
		var _on_root = point_in_rectangle(_mouse_x, _mouse_y, self.root.x, self.root.y, self.root.x + self.root.width - 1, self.root.y + self.root.height - 1);
		return _on_this && _on_root;
	}
	
	//Update
	///@func step()
	step = function() { }
	
	///@func update(x_offset, y_offset)
	static update = function(x_offset, y_offset) {
		
		//Position
		//self.pos_x = SmoothApproach(self.pos_x, self.target_x, 2);
		//self.pos_y = SmoothApproach(self.pos_y, self.target_y, 2);
		self.x = self.pos_x + x_offset;
		self.y = self.pos_y + y_offset;
		
		//Update all elements
		for (var i = array_length(contents); i > 0; --i) {
			//Delete marked to delete elements
			if contents[i-1].marked_to_delete {
				delete contents[i-1];
				array_delete(contents, i-1, 1);
			}
		}
	}
	
	//Render
	///@func draw()
	draw = function() { }
	
	///@func render(base_x, base_y)
	static render = function(base_x = 0, base_y = 0) {
		if is_array(self.contents)
		for (var i = 0, n = array_length(self.contents); i < n; i++) {
			var _element = self.contents[i];
			//Render
			_element.update(base_x + self.pos_x, base_y + self.pos_y);
			_element.step();
			_element.draw();
			_element.render(self.x, self.y);
			if global.LUI_DEBUG_MODE _element.render_debug();
		}
		//self.render_debug(); //Not necessary since the first element will be the main container
	}
	
	///@func render_debug()
	static render_debug = function() {
		if global.LUI_DEBUG_MODE == 1 {
			draw_set_alpha(0.5);
			
			if mouse_hover() {
				draw_set_color(c_blue);
			} else {
				draw_set_color(c_red);
			}
			
			draw_rectangle(self.x, self.y, self.x + self.width - 1, self.y + self.height - 1, true);
			draw_line(self.x, self.y, self.x + self.width - 1, self.y + self.height - 1);
			draw_line(self.x, self.y + self.height, self.x + self.width - 1, self.y - 1);
			
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_text(self.x, self.y, string(self.pos_x) + ":" + string(self.pos_y));
			draw_text(self.x, self.y + 16, string(self.value) + ": " + string(self.value));
		}
	}
	
	//Clean up
	///@func destroy()
	destroy = function() {
		if array_length(self.contents) > 0 {
			for (var i = 0, n = array_length(self.contents); i < n; i++) {
			    var _element = self.contents[i];
				_element.destroy();
				self.contents[i] = undefined;
			}
		}
		self.marked_to_delete = true;
	}
}