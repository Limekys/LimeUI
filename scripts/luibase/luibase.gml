function LuiBase(style = {}) constructor {
	self.name = "-unnamed-";
	self.value = undefined;
	self.style = new LuiStyle(style);
	
	self.x = 0;					//Actual x position on the screen
	self.y = 0;					//Actual y position on the screen
	self.pos_x = 0;				//Offset x position this element relative parent
	self.pos_y = 0;				//Offset y position this element relative parent
	self.target_x = 0;			//Target x position this element for animation
	self.target_y = 0;			//Target y position this element for animation
	self.start_x = self.pos_x;	//First x position
	self.start_y = self.pos_y;	//First y position
	self.width = display_get_gui_width();
	self.height = display_get_gui_height();
	self.min_width = 32;
	self.min_height = 32;
	self.max_width = self.width;
	self.max_height = self.height;
	self.parent = self;
	self.callback = undefined;
	self.contents = [];
	self.marked_to_delete = false;
	self.is_mouse_hovered = false;
	self.deactivated = false;
	
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
	
	//Funcs
	///@func activate()
	static activate = function() {
		self.deactivated = false;
		return self;
	}
	///@func deactivate()
	static deactivate = function() {
		self.deactivated = true;
		return self;
	}
	
	//Add content
	///@func get_first()
	static get_first = function() {
        if (array_length(self.contents) == 0) return undefined;
        return self.contents[0];
    };
	
	///@func get_last()
	static get_last = function() {
        if (array_length(self.contents) == 0) return undefined;
        return self.contents[array_length(self.contents) - 1];
    };
	
	///@func add_content(elements)
	///@arg {Any} elements
	static add_content = function(elements) {
		//Convert to array if one element
		if !is_array(elements) elements = [elements];
		//Other positions
		var _row_pos_y = 0;
		var _element_x = 0;
		//Adding
		for (var i = 0; i < array_length(elements); i++) {
		    //Get
			var row_elements = elements[i];
			
			//Convert to array if one element
			if !is_array(row_elements) row_elements = [row_elements];
			var _n = array_length(row_elements);
			
			//Take ranges from array
			var _ranges = [];
			if is_array(row_elements[_n-1]) {
				_ranges = row_elements[_n-1];
				_n--;
			}
			
			//Calculate width for each element in row
			var _element_width = floor((self.width - (_n + 1)*self.style.padding) / _n);
			
			//Adding elements in row
			for (var j = 0; j < _n; j++) {
				//Get
				var _element = row_elements[j];
				var _last = get_last();
				
				//Set parent and style
				_element.parent = self;
				_element.style = new LuiStyle(self.style);
				
				//Set width
				if _element.width == undefined {
					_element.width = min(_element_width, _element.max_width);
					if array_length(_ranges) > 0
					_element.width = floor(_ranges[j] * (self.width - (_n + 1)*self.style.padding));
				}
				
				//Set position
				_element.pos_x = self.style.padding;
				_element.pos_y = self.style.padding + _row_pos_y;
				
				if !is_undefined(_last) {
					//If there are many elements
					if j != 0 {
						_element_x = _last.pos_x;
						_element.pos_x = _element_x + _last.width + self.style.padding;
					}
					//If one element
					if _n == 1 {
						_element.pos_x = self.style.padding;
						_element.pos_y = self.style.padding + _last.pos_y + _last.height;
					}
				}
				
				//Save new start x y position
				_element.start_x = _element.pos_x;
				_element.start_y = _element.pos_y;
				
				//Add to content array
				array_push(self.contents, _element);
				
				//If last element in row
				if j == _n-1 {
					_element_x = 0;
					_row_pos_y += self.style.padding + _element.height;
				}
			}
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
		self.pos_x = parent.width div 2 - self.width div 2;
		self.pos_y = parent.height div 2 - self.height div 2;
		self.target_x = parent.width div 2 - self.width div 2;
		self.target_y = parent.height div 2 - self.height div 2;
		return self;
	}
	
	///@func center_vertically()
	static center_vertically = function() {
		self.pos_y = parent.height div 2 - self.height div 2;
		self.target_y = parent.height div 2 - self.height div 2;
		return self;
	}
	
	///@func center_horizontally()
	static center_horizontally = function() {
		self.pos_x = parent.width div 2 - self.width div 2;
		self.target_x = parent.width div 2 - self.width div 2;
		return self;
	}
	
	///@func stretch_horizontally(padding)
	static stretch_horizontally = function(padding) {
		var _last = parent.get_last();
		if (_last) && (_last.pos_x + _last.width < parent.width - self.min_width - padding) {
			self.width = parent.width - (_last.pos_x + _last.width) - padding*2;
		} else {
			self.width = parent.width - padding*2;
		}
		return self;
	}
	
	///@func stretch_vertically(padding)
	static stretch_vertically = function(padding) {
		var _last = parent.get_last();
		if (_last) && (_last.pos_y + _last.height < parent.height - self.min_height - padding) {
			self.height = parent.height - (_last.pos_y + _last.height) - padding*2;
		} else {
			self.height = parent.height - padding*2;
		}
		return self;
	}
	
	//Design
	///@func set_color(main, border)
	static set_color = function(main = undefined, border = undefined) {
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
		var _on_parent = point_in_rectangle(_mouse_x, _mouse_y, self.parent.x, self.parent.y, self.parent.x + self.parent.width - 1, self.parent.y + self.parent.height - 1);
		return _on_this && _on_parent;
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
			draw_set_alpha(0.25);
			if !is_undefined(self.style.font_default) draw_set_font(self.style.font_default);
			
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
			var _y_offset = !is_undefined(self.style.font_default) ? font_get_size(self.style.font_default) : 16;
			draw_text(self.x, self.y, "x: " + string(self.pos_x) + " y: " + string(self.pos_y));
			draw_text(self.x, self.y + _y_offset*1, "w: " + string(self.width) + " h: " + string(self.height));
			draw_text(self.x, self.y + _y_offset*2, "v: " + string(self.value));
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