function LuiBase() constructor {
	if !variable_global_exists("lui_main_ui") variable_global_set("lui_main_ui", undefined);
	if !variable_global_exists("lui_element_count") variable_global_set("lui_element_count", 0);
	
	global.lui_main_ui ??= self;
	
	self.element_id = global.lui_element_count++;
	
	self.name = "LuiBase";
	self.value = undefined;
	self.style = undefined;
	self.custom_style_is_setted = false;
	
	self.x = 0;									//Actual x position on the screen
	self.y = 0;									//Actual y position on the screen
	self.z = 0;									//Depth
	self.pos_x = 0;								//Offset x position this element relative parent
	self.pos_y = 0;								//Offset y position this element relative parent
	self.target_x = 0;							//Target x position this element for animation //???//
	self.target_y = 0;							//Target y position this element for animation //???//
	self.start_x = self.pos_x;					//First x position
	self.start_y = self.pos_y;					//First y position
	self.previous_x = -1000;
	self.previous_y = -1000;
	self.grid_previous_x = -1000;
	self.grid_previous_y = -1000;
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
	self.visible = true;
	self.has_focus = false;
	self.halign = undefined;
	self.valign = undefined;
	self.draw_relative = false;
	self.parent_relative = undefined;
	self.inside_parent = 2;
	self.ignore_mouse = false;
	self.render_content_enabled = true;
	self.delayed_content = undefined;
	self.need_to_update_content = false;
	self.topmost_hovered_element = undefined;
	
	//Custom functions for elements
	
	//Called after this item has been added
	self.create = function() {
		//Custom for each element
	}
	
	///@desc step()
	///@deprecated
	self.step = function() {
		//Custom for each element
	}
	
	///@desc Called when adding elements inside
	self.on_content_update = function() {
		//Custom for each element
	}
	
	///@desc Pre draw method call before draw method (for surfaces for example)
	self.pre_draw = function() {
		//Custom for each element
	}
	
	///@desc Draw method for element
	self.draw = function() {
		//Custom for each element
	}
	
	///@desc Called when this element is deleted (for example to clear surfaces)
	self.clean_up = function() {
		//Custom for each element
	};
	
	///@desc Called when you click on an element with the left mouse button
	self.on_mouse_left = function() {
		//Custom for each element
	}
	
	///@desc Called once when you click on an element with the left mouse button
	self.on_mouse_left_pressed = function() {
		//Custom for each element
	}
	
	///@desc Called once when the mouse left button is released
	self.on_mouse_left_released = function() {
		//Custom for each element
	}
	
	///@desc Called during keyboard input if the item is in focus
	self.on_keyboard_input = function() {
		//Custom for each element
	}
	
	///@desc Called when element change his position
	self.on_position_update = function() {
		//Custom for each element
	}
	
	//Screen grid for interactive iterations
	self._grid_location = [];
	
	global.lui_screen_grid_size = 96;
	
	if !variable_global_exists("lui_screen_grid") {
		variable_global_set("lui_screen_grid", {});
		for (var _x = 0, _width = ceil(display_get_gui_width() / global.lui_screen_grid_size); _x <= _width; ++_x) {
		    for (var _y = 0, _height = ceil(display_get_gui_height() / global.lui_screen_grid_size); _y <= _height; ++_y) {
			    var _key = string(_x) + "_" + string(_y);
				global.lui_screen_grid[$ _key] = array_create(0);
			}
		}
	}
	
	///@ignore
	static _grid_add = function() {
		if self.inside_parent == 0 || self.visible == false return false;
		
		var _elm_x = floor(self.get_absolute_x() / global.lui_screen_grid_size);
		var _elm_y = floor(self.get_absolute_y() / global.lui_screen_grid_size);
		var _width = ceil(self.width / global.lui_screen_grid_size);
		var _height = ceil(self.height / global.lui_screen_grid_size);
		
		for (var _x = _elm_x; _x <= _elm_x + _width; ++_x) {
		    for (var _y = _elm_y; _y <= _elm_y + _height; ++_y) {
			    var _inside = rectangle_in_rectangle(
					self.get_absolute_x(), self.get_absolute_y(), self.get_absolute_x() + self.width, self.get_absolute_y() + self.height,
					_x * global.lui_screen_grid_size, _y * global.lui_screen_grid_size, _x * global.lui_screen_grid_size + global.lui_screen_grid_size, _y * global.lui_screen_grid_size + global.lui_screen_grid_size);
				if _inside == 0 continue;
				var _key = string(_x) + "_" + string(_y);
				if variable_struct_exists(global.lui_screen_grid, _key) {
					var _array = global.lui_screen_grid[$ _key];
					array_push(_array, self);
					array_push(self._grid_location, _key);
				}
			}
		}
	}
	
	///@ignore
	static _grid_delete = function() {
		var _elm_x = floor(self.get_absolute_x() / global.lui_screen_grid_size);
		var _elm_y = floor(self.get_absolute_y() / global.lui_screen_grid_size);
		var _width = ceil(self.width / global.lui_screen_grid_size);
		var _height = ceil(self.height / global.lui_screen_grid_size);
		
		for (var i = array_length(self._grid_location) - 1; i >= 0; --i) {
		    var _key = self._grid_location[i];
			if variable_struct_exists(global.lui_screen_grid, _key) {
				var _array = global.lui_screen_grid[$ _key];
				var _ind = array_find_index(_array, function(_elm) {
					return _elm.element_id == self.element_id;
				});
				if _ind != -1 {
					array_delete(_array, _ind, 1);
				}
			}
		}
		
		self._grid_location = [];
	}
	
	///@ignore
	static _grid_update = function() {
		self._grid_delete();
		self._grid_add();
	}
	
	///@ignore
	static _grid_clean_up = function() {
		self._grid_delete();
	}
	
	///@ignore
	static _draw_screen_grid = function() {
		draw_set_color(c_red);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_font(fDebug);
		for (var _x = 0, _width = ceil(display_get_gui_width() / global.lui_screen_grid_size); _x <= _width; ++_x) {
		    for (var _y = 0, _height = ceil(display_get_gui_height() / global.lui_screen_grid_size); _y <= _height; ++_y) {
			    var _key = string(_x) + "_" + string(_y);
				var _array = global.lui_screen_grid[$ _key];
				draw_rectangle(_x * global.lui_screen_grid_size, _y * global.lui_screen_grid_size, 
					_x * global.lui_screen_grid_size + global.lui_screen_grid_size - 1, _y * global.lui_screen_grid_size + global.lui_screen_grid_size - 1, true);
				draw_text(_x * global.lui_screen_grid_size, _y * global.lui_screen_grid_size, string(_key));
				for (var i = 0, n = array_length(_array); i < n; ++i) {
				    draw_text(_x * global.lui_screen_grid_size, _y * global.lui_screen_grid_size + 6 + 6*i, _array[i].name);
				}
			}
		}
	}
	
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
	
	//Functions
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
	///@desc set_visible(true/false)
	static set_visible = function(_visible) {
		self.visible = _visible;
		array_foreach(self.contents, function(_elm) {
			_elm.set_visible(self.visible);
		});
		self._grid_update();
		return self;
	}
	///@desc ignore_mouse_hover(true/false)
	static ignore_mouse_hover = function(_ignore = true) {
		self.ignore_mouse = _ignore;
		return self;
	}
	
	static set_inside_parent = function(_inside) {
		self.inside_parent = _inside;
		array_foreach(self.contents, function(_elm) {
			_elm.set_inside_parent(self.inside_parent);
		});
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
		//Check for unordered adding
		if is_undefined(self.style) {
			if !is_array(self.delayed_content) self.delayed_content = [];
			self.delayed_content = array_concat(self.delayed_content, elements);
			return self;
		}
		//Adding
		var _local_z = 0;
		for (var i = 0; i < array_length(elements); i++) {
		    //Get
			var _row_elements = elements[i];
			
			//Convert to array if one element
			if !is_array(_row_elements) _row_elements = [_row_elements];
			var _row_element_count = array_length(_row_elements);
			
			//Take ranges from array
			var _ranges = [];
			if is_array(_row_elements[_row_element_count-1]) {
				_ranges = _row_elements[_row_element_count-1];
				_row_element_count--;
			}
			
			//Init variable for auto width calculations
			var _last_in_row = undefined;
			var _width = self.width;
			
			//Adding elements in row
			for (var j = 0; j < _row_element_count; j++) {
				//Get
				var _element = _row_elements[j];
				var _last = get_last();
				
				//Set parent and style
				_element.parent = self;
				_element.style = self.style;
				_element.z = _element.parent.z + ++_local_z;
				
				//Calculate width for right auto width calculations for next element
				if !is_undefined(_last_in_row) {
					_width -= _last_in_row.width + self.style.padding;
				}
				
				//Set width
				if _element.auto_width {
					//Calculate width by ranges (ranges have high priority)
					if array_length(_ranges) > 0 {
						_element.width = floor(_ranges[j] * (self.width - (_row_element_count + 1)*self.style.padding));
					} else {
						//Calculate auto width for each element in row
						var _remaining_element_count = _row_element_count - j;
						var _auto_width = floor((_width - (_remaining_element_count + 1)*self.style.padding) / _remaining_element_count);
						//Set width
						_element.width = min(_auto_width, _element.max_width);
					}
				}
				
				//Set height
				if _element.auto_height {
					_element.height = _element.min_height;
				}
				
				//Set position
				if _element.auto_x || _element.auto_y {
					
					//Add padding for first in row
					if j == 0 {
						_element.pos_x = self.style.padding;
						_element.pos_y = self.style.padding;
					}
					
					//If have last element
					if !is_undefined(_last) {
						//For first element in row
						if j == 0 {
							_element.pos_y = _last.pos_y + _last.height + self.style.padding;
						}
						//For next elements
						if j != 0 {
							_element.pos_x = _last.pos_x + _last.width + self.style.padding;
							_element.pos_y = _last_in_row.pos_y;
						}
					}
				}
				
				//Extend the height of the parent element if the added element does not fit (Except for scrollbars, as they work on a different principle)
				if !is_instanceof(self, LuiScrollPanel) && self.auto_height && _element.pos_y + _element.height > self.height - self.style.padding {
					self.height = _element.pos_y + _element.height + self.style.padding;
				}
				
				//Save new start x y position
				_element.start_x = _element.pos_x;
				_element.start_y = _element.pos_y;
				
				//Save last in row
				_last_in_row = _element;
				
				//Add delayed contents
				if !is_undefined(_element.delayed_content) {
					_element.add_content(_element.delayed_content);
				}
				
				//Call create function
				_element.create();
				
				//Add to content array
				array_push(self.contents, _element);
			}
		}
		self.align_all_elements();
		self.set_need_to_update_content(true);
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
	
	static center_horizontally = function() {
		self.pos_x = floor(self.parent.width / 2) - floor(self.width / 2);
	}
	
	static center_vertically = function() {
		self.pos_y = floor(self.parent.height / 2) - floor(self.height / 2);
	}
	
	///@desc align_all_elements() //???//
	static align_all_elements = function() {
		for (var i = array_length(self.contents) - 1; i >= 0 ; --i) {
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
	///@desc set_style(_style)
	static set_style = function(_style) {
		self.style = new LuiStyle(_style);
		self.custom_style_is_setted = true;
		for (var i = 0, n = array_length(self.contents); i < n; ++i) {
			var _element = self.contents[i];
			_element.set_style_childs(self.style);
		}
		return self;
	}
	///@desc set_style_childs(_style)
	static set_style_childs = function(_style) {
		if self.custom_style_is_setted == false {
			self.style = _style;
		}
		for (var i = array_length(self.contents)-1; i >= 0 ; --i) {
			var _element = self.contents[i];
			_element.set_style_childs(_style);
		}
		return self;
	}
	///@desc get style
	static get_style = function() {
		var _style = self.style;
		if !is_undefined(_style) return _style;
		if !is_undefined(self.parent) {
			_style = self.parent.get_style();
			if !is_undefined(_style) return _style;
		}
		return _style;
	}
	///@desc Set draw_relative to all descendants
	static set_draw_relative = function(_relative, _parent_relative = self) {
		for (var i = 0, n = array_length(self.contents); i < n; ++i) {
		    self.contents[i].draw_relative = _relative;
		    self.contents[i].parent_relative = _parent_relative;
			self.contents[i].set_draw_relative(_relative, self.contents[i].parent_relative);
		}
		return self;
	}
	static set_depth = function(_depth) {
		self.z = _depth;
		for (var i = 0, n = array_length(self.contents); i < n; ++i) {
		    self.contents[i].set_depth(_depth + i + 1);
		}
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
	///@return {Real}
	static get_absolute_x = function() {
		if self.parent != undefined {
			return self.pos_x + self.parent.get_absolute_x();
		} else {
			return self.pos_x;
		}
	}
	
	///@desc get_absolute_y()
	///@return {Real}
	static get_absolute_y = function() {
		if self.parent != undefined {
			return self.pos_y + self.parent.get_absolute_y();
		} else {
			return self.pos_y;
		}
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
		if is_undefined(self.parent_relative) {
			return self.parent.mouse_hover_any(_mouse_x, _mouse_y);
		} else {
			return self.parent_relative.mouse_hover_any(_mouse_x, _mouse_y);
		}
	}
	
	///@desc mouse_hover_childs()
	static mouse_hover_childs = function() {
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		var _on_element = false;
		if self.visible
		for (var i = 0, _n = array_length(self.contents); i < _n; ++i) {
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
		return point_in_rectangle(point_x, point_y, _element_x, _element_y, _element_x + self.width - 1, _element_y + self.height - 1);
	}
	///@desc get_topmost_element
	static get_topmost_element = function(_mouse_x, _mouse_y) {
		var _key = string(floor(_mouse_x / global.lui_screen_grid_size)) + "_" + string(floor(_mouse_y / global.lui_screen_grid_size));
		var _array = array_filter(global.lui_screen_grid[$ _key], function(_elm) {
			return _elm.mouse_hover_any() && _elm.mouse_hover_parent() && _elm.visible && !_elm.ignore_mouse;
		});
		array_sort(_array, function(_elm1, _elm2) {
			return _elm1.z - _elm2.z;
		});
		return array_last(_array);
	}
	
	///@desc get_topmost_element_old
	static get_topmost_element_old = function(_mouse_x, _mouse_y) {
		var topmost_element = undefined;
		for (var i = array_length(self.contents) - 1; i >= 0; --i) {
			var _element = self.contents[i];
			if _element.visible && !_element.ignore_mouse && _element.point_on_element(_mouse_x, _mouse_y) {
				topmost_element = _element.get_topmost_element_old(_mouse_x, _mouse_y);
				if topmost_element == undefined {
					return _element;
				}
				break;
			}
		}
		return topmost_element;
	}
	
	static set_need_to_update_content = function(_update) {
		if is_undefined(self.parent) return true;
		self.need_to_update_content = true;
		self.parent.set_need_to_update_content(_update);
	}
	
	//Update
	///@desc update()
	static update = function(base_x = 0, base_y = 0) {
		//Limit updates
		if self.visible == false || self.deactivated || self.inside_parent == 0 {
			return false;
		}
		//Check if the element is in the area of its parent and call its step function
		if self.draw_relative == false {
			if self.inside_parent == 1 {
				self.step();
			}
		} else {
			if self.inside_parent == 1 || self.inside_parent == 2 {
				self.step();
			}
		}
		//Update all elements inside
		for (var i = array_length(self.contents)-1; i >= 0; --i) {
			//Get element
			var _element = self.contents[i];
			//Get absolute position
			var _e_x = base_x + _element.pos_x;
			var _e_y = base_y + _element.pos_y;
			//Update
			_element.update(_e_x, _e_y);
			//Update content script
			if _element.need_to_update_content {
				_element.on_content_update();
				_element.need_to_update_content = false;
			}
			//Update current position
			var _cur_x = floor(_e_x);
			var _cur_y = floor(_e_y);
			if _element.previous_x != _cur_x || _element.previous_y != _cur_y {
				//Get absolute parent position
				var _p_x = base_x;
				var _p_y = base_y;
				//Check element is inside parent when position update
				if is_undefined(self.parent_relative) {
					_element.inside_parent = rectangle_in_rectangle(
						_e_x, _e_y, _e_x + _element.width, _e_y + _element.height,
						_p_x, _p_y, _p_x + _element.parent.width, _p_y + _element.parent.height);
				} else {
					_p_x = _element.parent_relative.get_absolute_x();
					_p_y = _element.parent_relative.get_absolute_y();
					_element.inside_parent = rectangle_in_rectangle(
						_e_x, _e_y, _e_x + _element.width, _e_y + _element.height,
						_p_x, _p_y, _p_x + _element.parent_relative.width, _p_y + _element.parent_relative.height);
				}
				_element.on_position_update();
			}
			_element.previous_x = _e_x;
			_element.previous_y = _e_y;
			//Update grid position
			var _grid_x = floor(_e_x / 32);
			var _grid_y = floor(_e_y / 32);
			if _element.grid_previous_x != _grid_x || _element.grid_previous_y != _grid_y {
				_element._grid_update();
			}
			_element.grid_previous_x = _grid_x;
			_element.grid_previous_y = _grid_y;
			//Delete marked to delete elements
			if _element.marked_to_delete {
				delete _element;
				array_delete(contents, i, 1);
			}
		}
		//Mouse hover (check topmost elements on mouse)
		is_mouse_hovered = false;
		var _is_main_ui = (self.parent == undefined);
		if _is_main_ui {
			var _mouse_x = device_mouse_x_to_gui(0);
	        var _mouse_y = device_mouse_y_to_gui(0);
			if _mouse_x < 0 || _mouse_x > self.width || _mouse_y < 0 || _mouse_y > self.height exit;
	        self.topmost_hovered_element = self.get_topmost_element(_mouse_x, _mouse_y);
	        if !is_undefined(self.topmost_hovered_element) && !self.topmost_hovered_element.deactivated {
				self.topmost_hovered_element.is_mouse_hovered = true;
				if mouse_check_button(mb_left) {
					self.topmost_hovered_element.on_mouse_left();
				}
				if mouse_check_button_pressed(mb_left) {
					self.topmost_hovered_element.on_mouse_left_pressed();
				}
				if mouse_check_button_released(mb_left) {
					self.topmost_hovered_element.on_mouse_left_released();
				}
			}
		}
	}
	
	//Render
	///@desc This function draws all nested elements
	static render = function(base_x = 0, base_y = 0) {
		if !self.visible return false;
		for (var i = 0, n = array_length(self.contents); i < n; i++) {
			//Get element
			var _element = self.contents[i];
			if _element.visible == false continue;
			//Check for allowing to draw
			var _allow_to_draw = (_element.draw_relative == false && _element.inside_parent == 1) || (_element.draw_relative == true && _element.inside_parent == 1 || _element.inside_parent == 2);
			//Check if the element is in the area of its parent and draw
			if _allow_to_draw {
				//Draw
				_element.pre_draw();
				_element.draw(base_x + _element.pos_x, base_y + _element.pos_y);
				if _element.render_content_enabled _element.render(base_x + _element.pos_x, base_y + _element.pos_y);
				if global.LUI_DEBUG_MODE != 0 _element.render_debug(base_x + _element.pos_x, base_y + _element.pos_y);
			}
		}
		if global.LUI_DEBUG_MODE != 0 {
			//Get element
			var _element = self.topmost_hovered_element;
			if is_undefined(_element) return false;
			//Text on mouse
			var _mouse_x = device_mouse_x_to_gui(0) + 16;
			var _mouse_y = device_mouse_y_to_gui(0) + 0;
			//Text
			draw_set_alpha(1);
			draw_set_color(c_white);
			_lui_draw_text_debug(_mouse_x, _mouse_y, 
			"name: " + string(_element.name) + "\n" +
			"x: " + string(_element.pos_x) + " y: " + string(_element.pos_y) + "\n" +
			"w: " + string(_element.width) + " h: " + string(_element.height) + "\n" +
			"v: " + string(_element.value) + "\n" +
			"hl: " + string(_element.halign) + " vl: " + string(_element.valign) + "\n" +
			"z: " + string(_element.z));
		}
	}
	
	///@desc render_debug()
	///@ignore
	static render_debug = function(_x = 0, _y = 0) {
		if !is_undefined(self.style.font_debug) {
			draw_set_font(self.style.font_debug);
		}
		draw_set_alpha(0.5);
		draw_set_color(mouse_hover() ? c_red : make_color_hsv(self.z % 255 * 10, 255, 255));
		//Rectangles
		draw_rectangle(_x, _y, _x + self.width - 1, _y + self.height - 1, true);
		//draw_line(_x, _y, _x + self.width - 1, _y + self.height - 1);
		//draw_line(_x, _y + self.height, _x + self.width - 1, _y - 1);
		//Text
		if global.LUI_DEBUG_MODE == 2 {
			_lui_draw_text_debug(_x, _y, 
			"name: " + string(self.name) + "\n" +
			"x: " + string(self.pos_x) + " y: " + string(self.pos_y) + "\n" +
			"w: " + string(self.width) + " h: " + string(self.height) + "\n" +
			"v: " + string(self.value) + "\n" +
			"hl: " + string(self.halign) + " vl: " + string(self.valign) + "\n" +
			"z: " + string(self.z));
			draw_set_alpha(1);
			draw_set_color(c_white);
		}
	}
	
	///@desc _lui_draw_text_debug(x, y, text)
	///@ignore
	static _lui_draw_text_debug = function(x, y, text) {
		var _text_width = string_width(text);
		var _text_height = string_height(text);
		x = clamp(x, 0, display_get_gui_width() - _text_width);
		y = clamp(y, 0, display_get_gui_height() - _text_height);
		draw_set_color(c_black);
		draw_rectangle(x, y, x + _text_width, y + _text_height, false);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);
		draw_text(x, y, text);
	}
	
	///@desc draw text fit to width
	///@ignore
	static _lui_draw_text_cutoff = function(_x, _y, _string, _width = infinity) {
		//Calculate text width to cut off
		var _str_to_draw = _string;
		var _str_width = string_width(_str_to_draw);
		if _str_width >= _width {
			_str_to_draw += "...";
			do {
				_str_to_draw = string_delete(_str_to_draw, string_length(_str_to_draw)-3, 1);
				_str_width = string_width(_str_to_draw);
			}
			until (_str_width < _width);
		}
		//Draw text
		draw_text(_x, _y, _str_to_draw);
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
		self.clean_up();
		self._grid_clean_up();
		global.lui_element_count--;
	}
	
	///@desc destroy_content()
	static destroy_content = function() {
		if array_length(self.contents) > 0 {
			for (var i = array_length(self.contents) - 1;  i >= 0; --i) {
			    var _element = self.contents[i];
				_element.destroy();
			}
		}
	}
}