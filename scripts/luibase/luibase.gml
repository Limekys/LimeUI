function LuiBase() constructor {
	if !variable_global_exists("lui_element_count") variable_global_set("lui_element_count", 0);
	
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
	self.target_x = 0;							//Target x position this element relative parent (for animation) //???//
	self.target_y = 0;							//Target y position this element relative parent (for animation) //???//
	self.start_x = 0;							//First x position
	self.start_y = 0;							//First y position
	self.previous_x = -1;						//Previous floor(x) position on the screen
	self.previous_y = -1;						//Previous floor(y) position on the screen
	self.grid_previous_x = -1;					//Previous floor(x / global.lui_screen_grid_accuracy) position on the grid
	self.grid_previous_y = -1;					//Previous floor(y / global.lui_screen_grid_accuracy) position on the grid
	self.width = 32;							//Actual width
	self.height = 32;							//Actual height
	self.target_width = 32;						//Target width (for animation) //???//
	self.target_height = 32;					//Target height (for animation) //???//
	self.min_width = 32;
	self.min_height = 32;
	self.max_width = 3200;
	self.max_height = 3200;
	self.auto_x = false;
	self.auto_y = false;
	self.auto_width = false;
	self.auto_height = false;
	self.parent = undefined;
	self.callback = undefined;
	self.content = [];
	self.marked_to_delete = false;				//Deprecated variable
	self.is_mouse_hovered = false;
	self.deactivated = false;
	self.visible = true;
	self.visibility_switching = true;
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
	self.element_in_focus = undefined;
	self.display_focused_element = false;
	self.waiting_for_keyboard_input = false;
	self.main_ui = self;
	self.allow_height_extend = true;
	
	//Custom functions for elements
	
	//Called after this item has been added
	self.create = function() {
		//Custom for each element
	}
	
	///@desc step()
	self.step = function() {
		//Custom for each element
	}
	
	///@desc Called when adding or deleting elements inside
	self.onContentUpdate = function() {
		//Custom for each element
	}
	
	///@desc Pre draw method call before draw method (for surfaces for example)
	self.preDraw = function() {
		//Custom for each element
	}
	
	///@desc Draw method for element
	self.draw = function() {
		//Custom for each element
	}
	
	///@desc Called when this element is deleted (for example to clear surfaces)
	self.cleanUp = function() {
		//Custom for each element
	};
	
	///@desc Called when you click on an element with the left mouse button
	self.onMouseLeft = function() {
		//Custom for each element
	}
	
	///@desc Called once when you click on an element with the left mouse button
	self.onMouseLeftPressed = function() {
		//Custom for each element
	}
	
	///@desc Called once when the mouse left button is released
	self.onMouseLeftReleased = function() {
		//Custom for each element
	}
	
	///@desc Called when the mouse wheel moves up or down
	self.onMouseWheel = function() {
		//Custom for each element
	}
	
	///@desc Called once when mouse enter on an element
	self.onMouseEnter = function() {
		//Custom for each element
	}
	
	///@desc Called once when mouse leave from an element
	self.onMouseLeave = function() {
		//Custom for each element
	}
	
	///@desc Called during keyboard input if the item is in focus
	self.onKeyboardInput = function() {
		//Custom for each element
	}
	
	///@desc Called during keyboard release if the item is in focus
	self.onKeyboardRelease = function() {
		//Custom for each element
	}
	
	///@desc Called when element change his position
	self.onPositionUpdate = function() {
		//Custom for each element
	}
	
	///@desc Called once when an element gets the focus
	self.onFocusSet = function() {
		//Custom for each element
	}
	
	///@desc Called once when an element has lost focus
	self.onFocusRemove = function() {
		//Custom for each element
	}
	
	///@desc Called when an element has change value
	self.onValueUpdate = function() {
		//Custom for each element
	}
	
	///@desc Called when an element has change visible to true
	self.onShow = function() {
		//Custom for each element
	}
	
	///@desc Called when an element has change visible to false
	self.onHide = function() {
		//Custom for each element
	}
	
	//Screen grid to optimize the search for items under the mouse cursor
	self._grid_location = [];
	
	///@ignore
	static _gridAdd = function() {
		if (self.inside_parent == 0 || !self.visible) return false;
		
		var _grid_size = LUI_GRID_SIZE;
		
		var _elm_x = floor(self.x / _grid_size);
		var _elm_y = floor(self.y / _grid_size);
		var _width = ceil(self.width / _grid_size);
		var _height = ceil(self.height / _grid_size);
		
		var abs_x_end = self.x + self.width;
		var abs_y_end = self.y + self.height;
		
		for (var _x = _elm_x; _x <= _elm_x + _width; ++_x) {
			for (var _y = _elm_y; _y <= _elm_y + _height; ++_y) {
				var grid_x_start = _x * _grid_size;
				var grid_y_start = _y * _grid_size;
				var grid_x_end = grid_x_start + _grid_size;
				var grid_y_end = grid_y_start + _grid_size;
				
				var _inside = rectangle_in_rectangle(
					self.x, self.y, abs_x_end, abs_y_end,
					grid_x_start, grid_y_start, grid_x_end, grid_y_end
				);
				
				if (_inside == 0) continue;
				
				var _key = string(_x) + "_" + string(_y);
				
				if (variable_struct_exists(self.main_ui._screen_grid, _key)) {
					var _array = self.main_ui._screen_grid[$ _key];
					array_push(_array, self);
					array_push(self._grid_location, _key);
				}
			}
		}
	};
	
	///@ignore
	static _gridDelete = function() {
		
		var _grid_size = LUI_GRID_SIZE;
		
		var _elm_x = floor(self.x / _grid_size);
		var _elm_y = floor(self.y / _grid_size);
		var _width = ceil(self.width / _grid_size);
		var _height = ceil(self.height / _grid_size);
		
		var _grid_location_length = array_length(self._grid_location);
		for (var i = _grid_location_length - 1; i >= 0; --i) {
			var _key = self._grid_location[i];
			
			if (variable_struct_exists(self.main_ui._screen_grid, _key)) {
				var _array = self.main_ui._screen_grid[$ _key];
				var _array_length = array_length(_array);
				for (var j = 0; j < _array_length; ++j) {
					if (_array[j].element_id == self.element_id) {
						array_delete(_array, j, 1);
						break;
					}
				}
			}
		}
		
		self._grid_location = [];
	};
	
	///@ignore
	static _gridUpdate = function() {
		self._gridDelete();
		self._gridAdd();
	}
	
	///@ignore
	static _gridCleanUp = function() {
		self._gridDelete();
		self._grid_location = -1;
	}
	
	///@ignore
	static _drawScreenGrid = function() {
		draw_set_alpha(1);
		draw_set_color(c_red);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_font(fDebug);
		
		var grid_size = LUI_GRID_SIZE;
		var gui_width = display_get_gui_width();
		var gui_height = display_get_gui_height();
		
		var _width = ceil(gui_width / grid_size);
		var _height = ceil(gui_height / grid_size);
		
		for (var _x = 0; _x <= _width; ++_x) {
			var x_pos = _x * grid_size;
			draw_line(x_pos, 0, x_pos, gui_height);
			
			for (var _y = 0; _y <= _height; ++_y) {
				var y_pos = _y * grid_size;
				
				if _x == 0 draw_line(0, y_pos, gui_width, y_pos);
				
				var _key = string(_x) + "_" + string(_y);
				var _array = self.main_ui._screen_grid[$ _key];
				draw_text(x_pos, y_pos, string(_key));
				
				for (var i = 0, n = array_length(_array); i < n; ++i) {
					draw_text(x_pos, y_pos + 6 + 6 * i, _array[i].name);
				}
			}
		}
	};
	
	//Init
	static initElement = function() {
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
	
	//Element names
	///@ignore
	static _registerElementName = function() {
		if !variable_struct_exists(self.main_ui.element_names, self.name) {
			variable_struct_set(self.main_ui.element_names, self.name, self);
		} else {
			if LUI_LOG_ERROR_MODE == 2 print($"WARNING: This element name {self.name} already exists! Please give another name!");
			var _new_name = "_" + md5_string_utf8(self.name + string(self.element_id));
			variable_struct_set(self.main_ui.element_names, _new_name, self);
			self.name = _new_name;
		}
	}
	///@ignore
	static _deleteElementName = function() {
		if variable_struct_exists(self.main_ui.element_names, self.name) {
			variable_struct_remove(self.main_ui.element_names, self.name);
		} else {
			if LUI_LOG_ERROR_MODE >= 1 print($"ERROR: Can't find name {self.name}!");
		}
	}
	
	///@desc Set name of this element (by which the data of this element can be retrieved in the future)
	///@return {Struct}
	static setName = function(_name) {
		if !variable_struct_exists(self.main_ui.element_names, _name) {
			self._deleteElementName();
			self.name = _name;
			self._registerElementName();
		} else {
			if LUI_LOG_ERROR_MODE == 2 print($"WARNING: This element name {_name} already exists! Please give another name!");
		}
		return self;
	}
	
	//Focusing
	///@desc setFocus
	///@return {Struct}
	static setFocus = function() {
		self.has_focus = true;
		self.onFocusSet();
		return self;
	}
	///@desc removeFocus
	///@return {Struct}
	static removeFocus = function() {
		self.has_focus = false;
		self.onFocusRemove();
		return self;
	}
	
	//Functions
	///@desc activate
	///@return {Struct}
	static activate = function() {
		self.deactivated = false;
		array_foreach(self.content, function(_elm) {
			_elm.activate();
		});
		return self;
	}
	///@desc deactivate
	///@return {Struct}
	static deactivate = function() {
		self.deactivated = true;
		array_foreach(self.content, function(_elm) {
			_elm.deactivate();
		});
		return self;
	}
	///@desc setVisible(true/false)
	///@return {Struct}
	static setVisible = function(_visible) {
		if self.visibility_switching {
			if self.visible != _visible {
				//Change visible
				self.visible = _visible;
				if !is_undefined(self.main_ui) {
					self._gridUpdate();
				}
				//Set visible to all childs
				array_foreach(self.content, function(_elm) {
					_elm.setVisible(self.visible);
				});
				//Call event onShow / onHide
				if _visible {
					self.onShow();
					self.updateMainUiSurface();
				} else {
					self.onHide();
					self.updateMainUiSurface();
				}
			}
		}
		return self;
	}
	///@desc ignoreMouseHover(true/false)
	///@return {Struct}
	static ignoreMouseHover = function(_ignore = true) {
		self.ignore_mouse = _ignore;
		return self;
	}
	
	//???//
	///@return {Struct}
	static setInsideParent = function(_inside) {
		self.inside_parent = _inside;
		array_foreach(self.content, function(_elm) {
			_elm.setInsideParent(self.inside_parent);
		});
		return self;
	}
	
	///@desc Enable or disable visibility switching by function setVisible()
	///@return {Struct}
	static setVisibilitySwitching = function(_bool) {
		self.visibility_switching = _bool;
		return self;
	}
	
	//Add content
	///@desc getFirst
	static getFirst = function() {
		return array_first(self.content);
	};
	
	///@desc getLast
	static getLast = function() {
		return array_last(self.content);
	};
	
	///@desc addContent(elements)
	///@arg {Any} elements
	static addContent = function(elements) {
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
				var _last = getLast();
				
				//Set parent, main ui and style
				_element.parent = self;
				_element.main_ui = _element.parent.main_ui;
				_element.style = self.style;
				_element.z = _element.parent.z + 1//++_local_z;
				if !_element.parent.visible _element.visible = false;
				
				//Calculate width for right auto width calculations for next element
				if !is_undefined(_last_in_row) {
					_width -= _last_in_row.width + self.style.padding;
				}
				
				//Set width
				_element.min_width = _element.style.default_min_width;
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
				_element.min_height = _element.style.default_min_height;
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
				
				//Save new start x y position
				_element.start_x = _element.pos_x;
				_element.start_y = _element.pos_y;
				
				//Save last in row
				_last_in_row = _element;
				
				//Register element name
				_element._registerElementName();
				
				//Add delayed contents
				if !is_undefined(_element.delayed_content) {
					_element.addContent(_element.delayed_content);
				}
				
				//Call create function
				_element.create();
				
				//Add to content array
				array_push(self.content, _element);
				
				//Extend the height of the parent element if the added element does not fit
				self.extendHeight();
			}
		}
		self.alignAllElements();
		self.setNeedToUpdateContent(true);
		return self;
	}
	
	// Getters
	///@desc Get value of this element
	static get = function() {
		return self.value;
	}
	
	///@desc Returns the lowest point of the elements by height
	static getLowerPoint = function() {
		var _lower_point = 0;
		for (var i = 0, n = array_length(content); i < n; ++i) {
		    var _elm = content[i];
			_lower_point = max(_lower_point, _elm.pos_y + _elm.height);
		}
		return _lower_point;
	}
	
	// Setters
	///@desc Set value of this element
	static set = function(value) {
		if self.value != value {
			self.value = value;
			self.onValueUpdate();
			self.updateMainUiSurface();
		}
		return self;
	}
	
	//Alignment and sizes
	///@desc stretchHorizontally(padding) //???//
	static stretchHorizontally = function(padding) {
		var _last = parent.getLast();
		if (_last) && (_last.pos_x + _last.width < parent.width - self.min_width - padding) {
			self.width = parent.width - (_last.pos_x + _last.width) - padding*2;
		} else {
			self.width = parent.width - padding*2;
		}
		return self;
	}
	
	///@desc stretchVertically(padding) //???//
	static stretchVertically = function(padding) {
		var _last = parent.getLast();
		if (_last) && (_last.pos_y + _last.height < parent.height - self.min_height - padding) {
			self.height = parent.height - (_last.pos_y + _last.height) - padding*2;
		} else {
			self.height = parent.height - padding*2;
		}
		return self;
	}
	
	///@desc Set horizontal element aligment (fa_left, fa_center, fa_right)
	///@return {Struct}
	static setHalign = function(halign) {
		self.halign = halign;
		return self;
	}
	
	///@desc Set vertical element aligment (fa_top, fa_middle, fa_bottom)
	///@return {Struct}
	static setValign = function(valign) {
		self.valign = valign;
		return self;
	}
	
	///@desc Center element horizontally on the parent element
	///@return {Struct}
	static centerHorizontally = function() {
		self.pos_x = floor(self.parent.width / 2) - floor(self.width / 2);
		return self;
	}
	
	///@desc Center element vertically on the parent element
	///@return {Struct}
	static centerVertically = function() {
		self.pos_y = floor(self.parent.height / 2) - floor(self.height / 2);
		return self;
	}
	
	///@desc Recursive function to extend an element by height
	static extendHeight = function() {
		if self.allow_height_extend && self.auto_height {
			var _lower_point = self.getLowerPoint();
			if _lower_point > self.height - self.style.padding {
				// Extend self
				self.height = _lower_point + self.style.padding;
				// Move next in parent down //???//
				if !is_undefined(self.parent) {
					
				}
			}
			self.parent.extendHeight();
		}
	}
	
	///@desc alignAllElements() //???//
	///@return {Struct}
	static alignAllElements = function() {
		for (var i = array_length(self.content) - 1; i >= 0 ; --i) {
			var _element = self.content[i];
			switch(_element.halign) {
				case fa_left:
					//while(_element.pos_x > _element.parent.style.padding || !pointOnElement(_element.parent.pos_x, _element.parent.pos_y)) {
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
			_element.alignAllElements();
		}
		return self;
	}
	
	//Design
	///@desc setStyle(_style)
	///@return {Struct}
	static setStyle = function(_style) {
		self.style = new LuiStyle(_style);
		self.custom_style_is_setted = true;
		array_foreach(self.content, function(_elm) {
			_elm.setStyleChilds(self.style);
		});
		return self;
	}
	///@desc setStyleChilds(_style)
	///@return {Struct}
	static setStyleChilds = function(_style) {
		if self.custom_style_is_setted == false {
			self.style = _style;
		}
		for (var i = array_length(self.content)-1; i >= 0 ; --i) {
			var _element = self.content[i];
			_element.setStyleChilds(_style);
		}
		return self;
	}
	///@desc get style
	static getStyle = function() {
		if (!is_undefined(self.style)) {
			return self.style;
		}
		if (!is_undefined(self.parent)) {
			var _style = self.parent.getStyle();
			if (!is_undefined(_style)) {
				return _style;
			}
		}
		return undefined;
	}
	///@desc Set draw_relative to all descendants
	///@return {Struct}
	static setDrawRelative = function(_relative, _parent_relative = self) {
		for (var i = 0, n = array_length(self.content); i < n; ++i) {
		    self.content[i].draw_relative = _relative;
		    self.content[i].parent_relative = _parent_relative;
			self.content[i].setDrawRelative(_relative, self.content[i].parent_relative);
		}
		return self;
	}
	///@desc Set depth to the element
	///@return {Struct}
	static setDepth = function(_depth) {
		self.z = _depth;
		array_foreach(self.content, function(_elm, _ind) {
			_elm.setDepth(self.z + _ind + 1);
		});
		return self;
	}
	///@desc Update main ui surface
	///@return {Struct}
	static updateMainUiSurface = function() {
		self.main_ui.update_ui_screen_surface = true;
		self.updateParentRelativeSurface();
		return self;
	}
	///@desc Update parent relative surface
	///@return {Struct}
	static updateParentRelativeSurface = function() {
		if !is_undefined(self.parent_relative) {
			self.parent_relative._updateScrollSurface();
		}
		return self;
	}
	
	//Interactivity
	///@desc setCallback(callback)
	///@return {Struct}
	static setCallback = function(callback) {
		if callback == undefined {
			self.callback = function() {show_debug_message(self.name + ": " + string(self.value))};
		} else {
			self.callback = method(self, callback);
		}
		return self;
	}
	
	static isInteracting = function() {
		return self.isInteractingMouse() || self.isInteractingKeyboard();
	}
	
	static isInteractingMouse = function() {
		return self.mouseHoverChilds();
	}
	
	static isInteractingKeyboard = function() {
		return self.waiting_for_keyboard_input;
	}
	
	///@desc mouseHover()
	static mouseHover = function() {
		return self.is_mouse_hovered;
	}
	
	///@desc mouseHoverAny()
	static mouseHoverAny = function() {
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		var _element_x = self.x;
		var _element_y = self.y;
		var _on_this = point_in_rectangle(_mouse_x, _mouse_y, _element_x, _element_y, _element_x + self.width - 1, _element_y + self.height - 1);
		return _on_this && self.visible;
	}
	
	///@desc mouseHoverParent()
	static mouseHoverParent = function() {
		if is_undefined(self.parent) return false;
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		if is_undefined(self.parent_relative) {
			return self.parent.mouseHoverAny(_mouse_x, _mouse_y);
		} else {
			return self.parent_relative.mouseHoverAny(_mouse_x, _mouse_y);
		}
	}
	
	///@desc mouseHoverChilds()
	static mouseHoverChilds = function() {
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		var _on_element = false;
		if self.visible
		for (var i = 0, _n = array_length(self.content); i < _n; ++i) {
		    var _element = self.content[i];
			_on_element = _element.mouseHoverAny();
			if _on_element break;
		}
		return _on_element;
	}
	
	///@desc pointOnElement
	static pointOnElement = function(point_x, point_y) {
		var _abs_x = self.x;
		var _abs_y = self.y;
		return point_in_rectangle(point_x, point_y, _abs_x, _abs_y, _abs_x + self.width - 1, _abs_y + self.height - 1);
	}
	///@desc getTopmostElement
	static getTopmostElement = function(_mouse_x, _mouse_y) {
		var _key = string(floor(_mouse_x / global.lui_screen_grid_size)) + "_" + string(floor(_mouse_y / global.lui_screen_grid_size));
		var _array = array_filter(self.main_ui._screen_grid[$ _key], function(_elm) {
			return _elm.mouseHoverAny() && _elm.mouseHoverParent() && _elm.visible && !_elm.ignore_mouse;
		});
		array_sort(_array, function(_elm1, _elm2) {
			return _elm1.z - _elm2.z;
		});
		return array_last(_array);
	}
	
	///@desc getTopmostElementOld
	static getTopmostElementOld = function(_mouse_x, _mouse_y) {
		var topmost_element = undefined;
		for (var i = array_length(self.content) - 1; i >= 0; --i) {
			var _element = self.content[i];
			if _element.visible && !_element.ignore_mouse && _element.pointOnElement(_mouse_x, _mouse_y) {
				topmost_element = _element.getTopmostElementOld(_mouse_x, _mouse_y);
				if topmost_element == undefined {
					return _element;
				}
				break;
			}
		}
		return topmost_element;
	}
	
	static setNeedToUpdateContent = function(_update_parent) {
		if is_undefined(self.parent) return true;
		self.need_to_update_content = true;
		self.parent.setNeedToUpdateContent(_update_parent);
	}
	
	//Update
	///@desc update()
	static update = function(base_x = 0, base_y = 0) {
		// Limit updates
		if (!self.visible || self.deactivated || self.inside_parent == 0) {
			return false;
		}
		
		// Check if the element is in the area of its parent and call its step function
		if (!self.draw_relative) {
			if (self.inside_parent == 1) {
				self.step();
			}
		} else {
			if (self.inside_parent == 1 || self.inside_parent == 2) {
				self.step();
			}
		}
		
		// Update all elements inside
		var content_length = array_length(self.content);
		for (var i = content_length - 1; i >= 0; --i) {
			var _element = self.content[i];
			
			// Get absolute position
			_element.x = base_x + _element.pos_x;
			_element.y = base_y + _element.pos_y;
			
			// Update element
			_element.update(_element.x, _element.y);
			
			// Update content script if needed
			if (_element.need_to_update_content) {
				_element.onContentUpdate();
				_element.need_to_update_content = false;
			}
			
			// Update current position
			var _cur_x = floor(_element.x);
			var _cur_y = floor(_element.y);
			if (_element.previous_x != _cur_x || _element.previous_y != _cur_y) {
				// Get absolute parent position
				var _p_x = base_x;
				var _p_y = base_y;
				
				// Check if element is inside parent when position updates
				_element.inside_parent = rectangle_in_rectangle(
					_element.x, _element.y, _element.x + _element.width, _element.y + _element.height,
					_p_x, _p_y, _p_x + _element.parent.width, _p_y + _element.parent.height
				);
				
				if (!is_undefined(self.parent_relative)) {
					_p_x = _element.parent_relative.x;
					_p_y = _element.parent_relative.y;
					_element.inside_parent = _element.inside_parent && rectangle_in_rectangle(
						_element.x, _element.y, _element.x + _element.width, _element.y + _element.height,
						_p_x, _p_y, _p_x + _element.parent_relative.width, _p_y + _element.parent_relative.height
					);
				}
				_element.onPositionUpdate();
				self.updateMainUiSurface();
			}
			
			_element.previous_x = _cur_x;
			_element.previous_y = _cur_y;
			
			// Update grid position
			var _grid_x = floor(_element.x / global.lui_screen_grid_accuracy);
			var _grid_y = floor(_element.y / global.lui_screen_grid_accuracy);
			if (_element.grid_previous_x != _grid_x || _element.grid_previous_y != _grid_y) {
				_element._gridUpdate();
			}
			
			_element.grid_previous_x = _grid_x;
			_element.grid_previous_y = _grid_y;
		}
	}
	
	//Render
	///@desc This function draws all nested elements
	static render = function(base_x = 0, base_y = 0) {
		for (var i = 0, n = array_length(self.content); i < n; i++) {
			//Get element
			var _element = self.content[i];
			if !_element.visible continue;
			//Check for allowing to draw
			var _allow_to_draw = _element.inside_parent != 0;
			//Check if the element is in the area of its parent and draw
			if _allow_to_draw {
				//Draw
				var _x = base_x + _element.pos_x;
				var _y = base_y + _element.pos_y;
				_element.draw(_x, _y);
				if _element.render_content_enabled _element.render(_x, _y);
				if global.lui_debug_mode != 0 _element.renderDebug(_x, _y);
			}
		}
	}
	
	///@desc renderDebug()
	///@ignore
	static renderDebug = function(_x = 0, _y = 0) {
		if !is_undefined(self.style.font_debug) {
			draw_set_font(self.style.font_debug);
		}
		var _prev_color = draw_get_color();
		var _prev_alpha = draw_get_alpha();
		draw_set_alpha(0.5);
		draw_set_color(mouseHover() ? c_red : make_color_hsv(self.z % 255 * 10, 255, 255));
		//Rectangles
		draw_rectangle(_x, _y, _x + self.width - 1, _y + self.height - 1, true);
		//Text
		if global.lui_debug_mode == 2 {
			_luiDrawTextDebug(_x, _y, 
			"name: " + string(self.name) + "\n" +
			"x: " + string(self.pos_x) + " y: " + string(self.pos_y) + "\n" +
			"w: " + string(self.width) + " h: " + string(self.height) + "\n" +
			"v: " + string(self.value) + "\n" +
			"hl: " + string(self.halign) + " vl: " + string(self.valign) + "\n" +
			"z: " + string(self.z));
		}
		draw_set_color(_prev_color);
		draw_set_alpha(_prev_alpha);
	}
	
	///@desc _luiDrawTextDebug(x, y, text)
	///@ignore
	static _luiDrawTextDebug = function(_text_x, _text_y, text) {
		var _text_width = string_width(text);
		var _text_height = string_height(text);
		_text_x = clamp(_text_x, 0, display_get_gui_width() - _text_width);
		_text_y = clamp(_text_y, 0, display_get_gui_height() - _text_height);
		draw_set_color(c_black);
		draw_rectangle(_text_x, _text_y, _text_x + _text_width, _text_y + _text_height, false);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);
		draw_text(_text_x, _text_y, text);
	}
	
	///@desc returns text fit to width
	///@ignore
	static _luiGetTextCutoff = function(_string, _width = infinity) {
		// Calculate initial text width
		var _str_to_draw = _string;
		var _str_width = string_width(_str_to_draw);
		
		// Check if the text needs to be truncated
		if (_str_width > _width) {
			// Calculate the width of "..." once, to use in our calculations
			var _ellipsis = "...";
			var _ellipsis_width = string_width(_ellipsis);
			
			// Calculate the width available for the main part of the string
			var _available_width = _width - _ellipsis_width;
			
			// Initialize binary search bounds
			var _low = 1;
			var _high = string_length(_string);
			var _mid;
			
			// Perform binary search to find the cutoff point
			while (_low < _high) {
				_mid = floor((_low + _high) / 2);
				_str_to_draw = string_copy(_string, 1, _mid);
				_str_width = string_width(_str_to_draw);
				
				if (_str_width < _available_width) {
					_low = _mid + 1;
				} else {
					_high = _mid;
				}
			}
			
			// The final string should be within the bounds
			_str_to_draw = string_copy(_string, 1, _high - 1) + _ellipsis;
		}
		
		// Return the final text
		return _str_to_draw;
	};
	
	///@desc draw text fit to width
	///@ignore
	static _luiDrawTextCutoff = function(_x, _y, _string, _width = infinity) {
		// Calculate initial text width
		var _str_to_draw = _string;
		var _str_width = string_width(_str_to_draw);
		
		// Check if the text needs to be truncated
		if (_str_width > _width) {
			// Calculate the width of "..." once, to use in our calculations
			var _ellipsis = "...";
			var _ellipsis_width = string_width(_ellipsis);
			
			// Calculate the width available for the main part of the string
			var _available_width = _width - _ellipsis_width;
			
			// Initialize binary search bounds
			var _low = 1;
			var _high = string_length(_string);
			var _mid;
			
			// Perform binary search to find the cutoff point
			while (_low < _high) {
				_mid = floor((_low + _high) / 2);
				_str_to_draw = string_copy(_string, 1, _mid);
				_str_width = string_width(_str_to_draw);
				
				if (_str_width < _available_width) {
					_low = _mid + 1;
				} else {
					_high = _mid;
				}
			}
			
			// The final string should be within the bounds
			_str_to_draw = string_copy(_string, 1, _high - 1) + _ellipsis;
		}
		
		// Draw the final text
		draw_text(_x, _y, _str_to_draw);
	};
	
	//Clean up
	///@desc destroy()
	static destroy = function() {
		for (var i = array_length(self.content) - 1;  i >= 0; --i) {
			var _element = self.content[i];
			_element.destroy();
		}
		if self == main_ui.element_in_focus {
			main_ui.element_in_focus.removeFocus();
			main_ui.element_in_focus = undefined;
		}
		self.cleanUp();
		self._gridCleanUp();
		self.setNeedToUpdateContent(true);
		self.content = -1;
		global.lui_element_count--;
		self.updateMainUiSurface();
		//Delete self from parent content
		if !is_undefined(parent) {
			if parent.content != -1 {
				array_delete(parent.content, array_find_index(parent.content, function(_elm) {
					return _elm == self;
				}), 1);
			}
		}
	}
	
	///@desc destroyContent()
	static destroyContent = function() {
		if array_length(self.content) > 0 {
			for (var i = array_length(self.content) - 1;  i >= 0; --i) {
			    var _element = self.content[i];
				_element.destroy();
			}
		}
	}
}