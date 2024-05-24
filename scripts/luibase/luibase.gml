///@arg {Struct} _style
function LuiBase(_style = {}) constructor {
	if !variable_global_exists("lui_main_ui") variable_global_set("lui_main_ui", undefined);
	global.lui_main_ui ??= self;
	
	self.name = "LuiBase";
	self.value = undefined;
	self.style = new LuiStyle(_style);
	
	self.x = 0;									//Actual x position on the screen
	self.y = 0;									//Actual y position on the screen
	self.pos_x = 0;								//Offset x position this element relative parent
	self.pos_y = 0;								//Offset y position this element relative parent
	self.target_x = 0;							//Target x position this element for animation //???//
	self.target_y = 0;							//Target y position this element for animation //???//
	self.start_x = self.pos_x;					//First x position
	self.start_y = self.pos_y;					//First y position
	self.width = display_get_gui_width();
	self.height = display_get_gui_height();
	self.min_width = 32;
	self.min_height = 32;
	self.max_width = self.width;
	self.max_height = self.height;
	self.auto_x = false;
	self.auto_y = false;
	self.auto_width = false;
	self.auto_height = false;
	self.parent = undefined;
	self.callback = undefined;
	self.contents = [];
	self.marked_to_delete = false;
	self.is_mouse_hovered = false;
	self.deactivated = false;
	self.has_focus = false;
	self.halign = undefined;
	self.valign = undefined;
	self.draw_relative = false;
	
	//Init
	static init_element = function() {
		if self.pos_x == LUI_AUTO || self.pos_y == LUI_AUTO {
			self.auto_x = true;
			self.auto_y = true;
			self.pos_x = 0;
			self.pos_y = 0;
		}
		if self.width == LUI_AUTO {
			self.auto_width = true;
			self.width = self.min_width;
		}
		if self.height == LUI_AUTO {
			self.auto_height = true;
			self.height = self.min_height;
		}
	}
	
	//Focusing
	///@desc set_focus
	static set_focus = function() {
		self.has_focus = true;
		return self;
	}
	///@desc remove_focus
	static remove_focus = function() {
		self.has_focus = false;
		return self;
	}
	
	//Funcs
	///@desc activate
	static activate = function() {
		self.deactivated = false;
		array_foreach(self.contents, function(_elm) {
			_elm.activate();
		});
		return self;
	}
	///@desc deactivate
	static deactivate = function() {
		self.deactivated = true;
		array_foreach(self.contents, function(_elm) {
			_elm.deactivate();
		});
		return self;
	}
	
	//Add content
	///@desc get_first
	static get_first = function() {
		if (array_length(self.contents) == 0) return undefined;
		return self.contents[0];
	};
	
	///@desc get_last
	static get_last = function() {
		if (array_length(self.contents) == 0) return undefined;
		return self.contents[array_length(self.contents) - 1];
	};
	
	///@desc add_content(elements)
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
			var row_element = elements[i];
			
			//Convert to array if one element
			if !is_array(row_element) row_element = [row_element];
			var _n = array_length(row_element);
			
			//Take ranges from array
			var _ranges = [];
			if is_array(row_element[_n-1]) {
				_ranges = row_element[_n-1];
				_n--;
			}
			
			//Calculate width for each element in row
			var _element_width = floor((self.width - (_n + 1)*self.style.padding) / _n);
			
			//Adding elements in row
			for (var j = 0; j < _n; j++) {
				//Get
				var _element = row_element[j];
				var _last = get_last();
				
				//Set parent and style
				_element.parent = self;
				_element.style = new LuiStyle(self.style);
				
				//Set draw_relative if parent has draw_relative too
				_element.draw_relative = _element.parent.draw_relative;
				
				//Set width
				if _element.auto_width == true {
					_element.width = min(_element_width, _element.max_width);
					if array_length(_ranges) > 0 {
						_element.width = floor(_ranges[j] * (self.width - (_n + 1)*self.style.padding));
					}
					_element.width = min(_element.width, _element.max_width);
				}
				
				//Set height
				if _element.auto_height == true {
					_element.height = _element.min_height;
				}
				
				//Set position
				if _element.auto_x == true || _element.auto_y == true {
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
		align_all_elements();
		return self;
	}
	
	//Setter and getter
	///@desc get()
	static get = function() { return self.value; }
	///@desc set()
	static set = function(value) { self.value = value; return self}
	
	//Alignment and sizes
	///@desc stretch_horizontally(padding)
	static stretch_horizontally = function(padding) {
		var _last = parent.get_last();
		if (_last) && (_last.pos_x + _last.width < parent.width - self.min_width - padding) {
			self.width = parent.width - (_last.pos_x + _last.width) - padding*2;
		} else {
			self.width = parent.width - padding*2;
		}
		return self;
	}
	
	///@desc stretch_vertically(padding)
	static stretch_vertically = function(padding) {
		var _last = parent.get_last();
		if (_last) && (_last.pos_y + _last.height < parent.height - self.min_height - padding) {
			self.height = parent.height - (_last.pos_y + _last.height) - padding*2;
		} else {
			self.height = parent.height - padding*2;
		}
		return self;
	}
	
	///@desc set_halign(halign)
	static set_halign = function(halign) {
		self.halign = halign;
		return self;
	}
	
	///@desc set_valign(valign)
	static set_valign = function(valign) {
		self.valign = valign;
		return self;
	}
	
	///@desc align_all_elements() //???//
	static align_all_elements = function() {
		if array_length(self.contents) > 0
		for (var i = 0; i < array_length(self.contents); i++) {
			var _element = self.contents[i];
			switch(_element.halign) {
				case fa_left:
					//while(_element.pos_x > _element.parent.style.padding || !point_on_element(_element.parent.pos_x, _element.parent.pos_y)) {
					//	_element.pos_x--;
					//}
					_element.pos_x = _element.style.padding;
				break;
				case fa_center:
					_element.pos_x = floor(_element.parent.width / 2 - _element.width / 2);
				break;
				case fa_right:
					_element.pos_x = _element.parent.width - _element.width - _element.style.padding;
				break;
				default:
				break;
			}
			switch(_element.valign) {
				case fa_top:
					_element.pos_y = _element.style.padding;
				break;
				case fa_middle:
					_element.pos_y = floor(_element.parent.height / 2 - _element.height / 2);
				break;
				case fa_bottom:
					_element.pos_y = _element.parent.height - _element.height - _element.style.padding;
				break;
				default:
				break;
			}
			_element.align_all_elements();
		}
	}
	
	//Design
	///@desc set_color(main, border)
	static set_color = function(main = undefined, border = undefined) {
		if !is_undefined(main) self.style.color_main = main;
		if !is_undefined(border) self.style.color_border = border;
		return self;
	}
	
	//Interactivity
	///@desc set_callback(callback)
	static set_callback = function(callback) {
		if callback == undefined {
			self.callback = function() {show_debug_message(self.name + ": " + string(self.value))};
		} else {
			self.callback = method(self, callback);
		}
		return self;
	}
	
	///@desc get_absolute_x()
	static get_absolute_x = function() {
		if self.parent != undefined
		return self.pos_x + self.parent.get_absolute_x();
		else
		return self.pos_x;
	}
	
	///@desc get_absolute_y()
	static get_absolute_y = function() {
		if self.parent != undefined
		return self.pos_y + self.parent.get_absolute_y();
		else
		return self.pos_y;
	}
	
	///@desc mouse_hover()
	static mouse_hover = function() {
		return self.is_mouse_hovered;
	}
	
	///@desc mouse_hover_any()
	static mouse_hover_any = function() {
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		var _element_x = self.get_absolute_x();
		var _element_y = self.get_absolute_y();
		var _on_this = point_in_rectangle(_mouse_x, _mouse_y, _element_x, _element_y, _element_x + self.width - 1, _element_y + self.height - 1);
		return _on_this;
	}
	
	///@desc mouse_hover_parent()
	static mouse_hover_parent = function() {
		if is_undefined(self.parent) return false;
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		var _parent_x = self.parent.get_absolute_x();
		var _parent_y = self.parent.get_absolute_y();
		var _on_parent = point_in_rectangle(_mouse_x, _mouse_y, _parent_x, _parent_y, _parent_x + self.parent.width - 1, _parent_y + self.parent.height - 1);
		if _on_parent {
			if !is_undefined(self.parent.parent) {
				return self.parent.mouse_hover_parent();
			} else {
				return true
			}
		} else {
			return false;
		}
	}
	
	///@desc mouse_hover_childs()
	static mouse_hover_childs = function() {
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		var _on_element = false;
		var _n = array_length(self.contents);
		if _n > 0
		for (var i = 0; i < _n; ++i) {
		    var _element = self.contents[i];
			_on_element = _element.mouse_hover_any();
			if _on_element break;
		}
		return _on_element;
	}
	
	///@desc point_on_element
	static point_on_element = function(point_x, point_y) {
		var _element_x = self.get_absolute_x();
		var _element_y = self.get_absolute_y();
		return point_in_rectangle(point_x, point_y, _element_x, _element_y, _element_x + self.width, _element_y + self.height);
	}
	///@desc get_topmost_element
	static get_topmost_element = function(_mouse_x, _mouse_y) {
		var topmost_element = undefined;
		for (var i = array_length(self.contents) - 1; i >= 0; --i) {
			var _element = self.contents[i];
			if (_element.point_on_element(_mouse_x, _mouse_y)) {
				topmost_element = _element.get_topmost_element(_mouse_x, _mouse_y);
				if topmost_element == undefined {
					return _element;
				}
				break;
			}
		}
		return topmost_element;
	}
	
	//Update
	///@desc step()
	step = function() { }
	
	///@desc update()
	static update = function() {
		if !self.deactivated self.step();
		//Update all elements
		if array_length(self.contents) > 0
		for (var i = array_length(self.contents)-1; i >= 0; --i) {
			//Get element
			var _element = self.contents[i];
			//Update
			_element.update();
			//Delete marked to delete elements
			if _element.marked_to_delete {
				delete _element;
				array_delete(contents, i, 1);
			}
		}
		//Mouse hover (check topmost elements on mouse)
		is_mouse_hovered = false;
		if self.parent == undefined {
			var _mouse_x = device_mouse_x_to_gui(0);
	        var _mouse_y = device_mouse_y_to_gui(0);
	        var topmost_element = self.get_topmost_element(_mouse_x, _mouse_y);
	        if (topmost_element != undefined && !topmost_element.deactivated) {
				topmost_element.is_mouse_hovered = true;
			}
		}
	}
	
	//Render
	///@desc draw()
	draw = function() { }
	
	///@desc This function draws all nested elements
	static render = function(base_x = 0, base_y = 0) {
		if array_length(self.contents) > 0
		for (var i = 0, n = array_length(self.contents); i < n; i++) {
			//Get element
			var _element = self.contents[i];
			//Calculate absolute position
			var _e_x = _element.get_absolute_x();
			var _e_y = _element.get_absolute_y();
			var _p_x = _element.parent.get_absolute_x();
			var _p_y = _element.parent.get_absolute_y();
			//Check if the element is in the area of its parent and draw
			if rectangle_in_rectangle(
				_e_x, _e_y, _e_x + _element.width, _e_y + _element.height,
				_p_x, _p_y, _p_x + _element.parent.width, _p_y + _element.parent.height)
			if _element.draw_relative == false {
				_element.draw(_e_x, _e_y);
				_element.render(base_x, base_y);
				if global.LUI_DEBUG_MODE _element.render_debug(_e_x, _e_y);
			} else {
				_element.draw(base_x + _element.pos_x, base_y + _element.pos_y);
				_element.render(_element.pos_x, _element.pos_y);
				if global.LUI_DEBUG_MODE _element.render_debug(base_x + _element.pos_x, base_y + _element.pos_y);
			}
		}
	}
	
	///@desc render_debug()
	static render_debug = function(_x = self.get_absolute_x(), _y = self.get_absolute_y()) {
		if global.LUI_DEBUG_MODE == 1 {
			draw_set_alpha(0.25);
			if mouse_hover() {
				draw_set_color(c_blue);
			} else {
				draw_set_color(c_red);
			}
			//Rectangles
			draw_rectangle(_x, _y, _x + self.width - 1, _y + self.height - 1, true);
			draw_line(_x, _y, _x + self.width - 1, _y + self.height - 1);
			draw_line(_x, _y + self.height, _x + self.width - 1, _y - 1);
			//Text
			var _y_offset = !is_undefined(self.style.font_debug) ? font_get_size(self.style.font_debug) : 8;
			_lui_draw_text_debug(_x, _y, "x: " + string(self.pos_x) + " y: " + string(self.pos_y));
			_lui_draw_text_debug(_x, _y + _y_offset*1, "w: " + string(self.width) + " h: " + string(self.height));
			_lui_draw_text_debug(_x, _y + _y_offset*2, "v: " + string(self.value));
			_lui_draw_text_debug(_x, _y + _y_offset*3, "hl: " + string(self.halign) + " vl: " + string(self.valign));
		}
	}
	
	///@desc _lui_draw_text_debug(x, y, text)
	static _lui_draw_text_debug = function(x, y, text) {
		if !is_undefined(self.style.font_debug) draw_set_font(self.style.font_debug);
		var _text_width = string_width(text);
		var _text_height = string_height(text);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_alpha(1);
		draw_set_color(c_black);
		draw_rectangle(x, y, x + _text_width, y + _text_height, false);
		draw_set_color(c_white);
		draw_text(x, y, text);
	}
	
	//Clean up
	///@desc destroy()
	static destroy = function() {
		if array_length(self.contents) > 0 {
			for (var i = array_length(self.contents) - 1;  i >= 0; --i) {
			    var _element = self.contents[i];
				_element.destroy();
			}
		}
		self.marked_to_delete = true;
	}
}