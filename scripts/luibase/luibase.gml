///@desc The basic constructor of all elements, which contains all the basic functions and logic of each element.
function LuiBase() constructor {
	if !variable_global_exists("lui_element_count") variable_global_set("lui_element_count", 0);
	if !variable_global_exists("lui_z_index") variable_global_set("lui_z_index", 0);
	
	self.element_id = global.lui_element_count++;
	self.name = "LuiBase";							//Unique element identifier
	self.value = undefined;							//Value
	self.style = undefined;							//Style struct
	self.x = 0;										//Actual x position on the screen
	self.y = 0;										//Actual y position on the screen
	self.z = 0;										//Depth
	self.pos_x = 0;									//Offset x position this element relative parent //???//
	self.pos_y = 0;									//Offset y position this element relative parent //???//
	self.target_x = 0;								//Target x position this element relative parent (for animation) //???//
	self.target_y = 0;								//Target y position this element relative parent (for animation) //???//
	self.start_x = -1;								//First x position
	self.start_y = -1;								//First y position
	self.previous_x = -1;							//Previous floor(x) position on the screen
	self.previous_y = -1;							//Previous floor(y) position on the screen
	self.grid_previous_x1 = -1;						//Previous floor(x / LUI_GRID_ACCURACY) left position on the grid
	self.grid_previous_y1 = -1;						//Previous floor(y / LUI_GRID_ACCURACY) top position on the grid
	self.grid_previous_x2 = -1;						//Previous floor((x + width) / LUI_GRID_ACCURACY) right position on the grid
	self.grid_previous_y2 = -1;						//Previous floor((y + width) / LUI_GRID_ACCURACY) bottom position on the grid
	self.width = 32;								//Actual width
	self.height = 32;								//Actual height
	self.target_width = 32;							//Target width (for animation) //???//
	self.target_height = 32;						//Target height (for animation) //???//
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
	self.delayed_content = undefined;
	self.container = self; 							//Sometimes the container may not be the element itself, but the element inside it (for example: LuiTab, LuiScrollPanel...)
	self.deactivated = false;
	self.visible = true;
	self.visibility_switching = true;
	self.has_focus = false;
	self.inside_parent = 2;
	self.ignore_mouse = false;
	self.render_content_enabled = true;
	self.need_to_update_content = false;
	self.main_ui = undefined;
	self.tooltip = "";
	self.binding_variable = -1;
	self.is_mouse_hovered = false;
	self.is_adding = false;
	self.is_custom_style_setted = false;
	self.draw_content_in_cutted_region = false;
	self.flex_node = undefined;
	self.render_region_offset = {
		left : 0,
		right : 0,
		top : 0,
		bottom : 0
	};
	self._grid_location = []; 						//Screen grid to optimize the search for items under the mouse cursor
	
	// Custom methods for element
	
	//Called after this item has been added somewhere
	self.onCreate = undefined;
	
	///@desc step()
	self.step = undefined;
	
	///@desc Called when adding or deleting elements inside
	self.onContentUpdate = undefined;
	
	///@desc Pre draw method call before draw method (for surfaces for example)
	self.preDraw = undefined;
	
	///@desc Draw method for element
	self.draw = undefined;
	
	///@desc Called when this element is deleted (for example to clear surfaces)
	self.onDestroy = undefined;
	
	///@desc Called when you click on an element with the left mouse button
	self.onMouseLeft = undefined;
	
	///@desc Called once when you click on an element with the left mouse button
	self.onMouseLeftPressed = undefined;
	
	///@desc Called once when the mouse left button is released
	self.onMouseLeftReleased = undefined;
	
	///@desc Called when the mouse wheel moves up or down
	self.onMouseWheel = undefined;
	
	///@desc Called once when mouse enter on an element
	self.onMouseEnter = undefined;
	
	///@desc Called once when mouse leave from an element
	self.onMouseLeave = undefined;
	
	///@desc Called during keyboard input if the item is in focus
	self.onKeyboardInput = undefined;
	
	///@desc Called during keyboard release if the item is in focus
	self.onKeyboardRelease = undefined;
	
	///@desc Called when element change his position
	self.onPositionUpdate = undefined;
	
	///@desc Called once when an element gets the focus
	self.onFocusSet = undefined;
	
	///@desc Called once when an element has lost focus
	self.onFocusRemove = undefined;
	
	///@desc Called when an element has change value
	self.onValueUpdate = undefined;
	
	///@desc Called when an element has change visible to true
	self.onShow = undefined;
	
	///@desc Called when an element has change visible to false
	self.onHide = undefined;
	
	///@desc Called when element change his size
	self.onSizeUpdate = undefined;
	
	// GETTERS
	
	///@desc Get value of this element
	static get = function() {
		return self.value;
	}
	
	///@desc Get style
	static getStyle = function() {
		return self.style;
		//if (!is_undefined(self.style)) {
			//return self.style;
		//}
		//if (!is_undefined(self.parent)) {
			//var _style = self.parent.getStyle();
			//if (!is_undefined(_style)) {
				//return _style;
			//}
		//}
		//return undefined;
	}
	
	///@desc Get first element in content array
	static getFirst = function() {
		return array_first(self.content);
	};
	
	///@desc Get last element in content array
	static getLast = function() {
		return array_last(self.content);
	};
	
	///@desc Get container element
	self.getContainer = function() {
		return self.container;
	}
	
	///@desc Returns topmost element on UI
	static getTopmostElement = function(_mouse_x, _mouse_y) {
		var _key = string(floor(_mouse_x / LUI_GRID_SIZE)) + "_" + string(floor(_mouse_y / LUI_GRID_SIZE));
		var _array = array_filter(self.main_ui._screen_grid[$ _key], function(_elm) {
			return _elm.visible && !_elm.ignore_mouse && _elm.isMouseHoveredExc() && _elm.isMouseHoveredParents();
		});
		array_sort(_array, function(_elm1, _elm2) {
			return _elm1.z - _elm2.z;
		});
		return array_last(_array);
	}
	
	// SETTERS
	
	///@desc Set value
	static set = function(_value) {
		if self.value != _value {
			self.value = _value;
			if self.binding_variable != -1 {
				self.updateToBinding();
			}
			if is_method(self.onValueUpdate) self.onValueUpdate();
			self.updateMainUiSurface();
		}
		return self;
	}
	
	///@desc Set element unique identificator name (Used for get element from main ui container via getElement())
	static setName = function(_string) {
		if is_undefined(self.main_ui) || !variable_struct_exists(self.main_ui, "element_names") {
			self.name = _string;
		} else {
			if !variable_struct_exists(self.main_ui.element_names, _string) {
				self._deleteElementName();
				self.name = _string;
				self._registerElementName();
			} else {
				if LUI_LOG_ERROR_MODE == 2 print($"LIME_UI.WARNING: Element name \"{_string}\" already exists! Please give another name!");
			}
		}
		return self;
	}
	
	///@desc Set flexpanel(element) position type (default is flexpanel_position_type.relative)
	///@arg {constant.flexpanel_position_type} [_type]
	static setPositionType = function(_type = flexpanel_position_type.relative) {
		var _flex_node = self.flex_node;
		flexpanel_node_style_set_position_type(_flex_node, _type);
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set flexpanel(element) X position
	///@arg {real} [_x] left = X
	static setPosX = function(_x = LUI_AUTO) {
		var _flex_node = self.flex_node;
		if _x != LUI_AUTO {
			flexpanel_node_style_set_position(_flex_node, flexpanel_edge.left, _x, flexpanel_unit.point);
			self.auto_x = false;
		}
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set flexpanel(element) Y position
	///@arg {real} [_y] top = Y
	static setPosY = function(_y = LUI_AUTO) {
		var _flex_node = self.flex_node;
		if _y != LUI_AUTO {
			flexpanel_node_style_set_position(_flex_node, flexpanel_edge.top, _y, flexpanel_unit.point);
			self.auto_y = false;
		}
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set flexpanel(element) right position
	///@arg {real} [_r] right
	static setPosR = function(_r = LUI_AUTO) {
		var _flex_node = self.flex_node;
		if _r != LUI_AUTO {
			flexpanel_node_style_set_position(_flex_node, flexpanel_edge.right, _r, flexpanel_unit.point);
		}
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set flexpanel(element) bottom position
	///@arg {real} [_b] bottom
	static setPosB = function(_b = LUI_AUTO) {
		var _flex_node = self.flex_node;
		if _b != LUI_AUTO {
			flexpanel_node_style_set_position(_flex_node, flexpanel_edge.top, _b, flexpanel_unit.point);
		}
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set flexpanel(element) position
	///@arg {real} [_x] left = X
	///@arg {real} [_y] top = Y
	///@arg {real} [_r] right
	///@arg {real} [_b] bottom
	static setPosition = function(_x = LUI_AUTO, _y = LUI_AUTO, _r = LUI_AUTO, _b = LUI_AUTO) {
		var _flex_node = self.flex_node;
		if _x != LUI_AUTO {
			flexpanel_node_style_set_position(_flex_node, flexpanel_edge.left, _x, flexpanel_unit.point);
			self.auto_x = false;
		}
		if _y != LUI_AUTO {
			flexpanel_node_style_set_position(_flex_node, flexpanel_edge.top, _y, flexpanel_unit.point);
			self.auto_y = false;
		}
		if _r != LUI_AUTO {
			flexpanel_node_style_set_position(_flex_node, flexpanel_edge.right, _r, flexpanel_unit.point);
		}
		if _b != LUI_AUTO {
			flexpanel_node_style_set_position(_flex_node, flexpanel_edge.bottom, _b, flexpanel_unit.point);
		}
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set flexpanel(element) width
	///@arg {real} [_width]
	static setWidth = function(_width = LUI_AUTO) {
		var _flex_node = self.flex_node;
		if _width != LUI_AUTO {
			flexpanel_node_style_set_width(_flex_node, _width, flexpanel_unit.point);
		}
		self.updateMainUiFlex();
		if is_method(self.onSizeUpdate) self.onSizeUpdate();
		return self;
	}
	
	///@desc Set flexpanel(element) height
	///@arg {real} [_height]
	static setHeight = function(_height = LUI_AUTO) {
		var _flex_node = self.flex_node;
		if _height != LUI_AUTO {
			flexpanel_node_style_set_height(_flex_node, _height, flexpanel_unit.point);
		}
		self.updateMainUiFlex();
		if is_method(self.onSizeUpdate) self.onSizeUpdate();
		return self;
	}
	
	///@desc Set flexpanel(element) size
	///@arg {real} [_width]
	///@arg {real} [_height]
	static setSize = function(_width = LUI_AUTO, _height = LUI_AUTO) {
		var _flex_node = self.flex_node;
		if _width != LUI_AUTO {
			flexpanel_node_style_set_width(_flex_node, _width, flexpanel_unit.point);
		}
		if _height != LUI_AUTO {
			flexpanel_node_style_set_height(_flex_node, _height, flexpanel_unit.point);
		}
		self.updateMainUiFlex();
		if is_method(self.onSizeUpdate) self.onSizeUpdate();
		return self;
	}
	
	///@desc Set flexpanel(element) min width
	///@arg {real} [_min_width]
	static setMinWidth = function(_min_width = LUI_AUTO) {
		var _flex_node = self.flex_node;
		if _min_width != LUI_AUTO {
			flexpanel_node_style_set_min_width(_flex_node, _min_width, flexpanel_unit.point);
		}
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set flexpanel(element) max width
	///@arg {real} [_max_width]
	static setMaxWidth = function(_max_width = LUI_AUTO) {
		var _flex_node = self.flex_node;
		if _max_width != LUI_AUTO {
			flexpanel_node_style_set_max_width(_flex_node, _max_width, flexpanel_unit.point);
		}
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set flexpanel(element) min height
	///@arg {real} [_min_height]
	static setMinHeight = function(_min_height = LUI_AUTO) {
		var _flex_node = self.flex_node;
		if _min_height != LUI_AUTO {
			flexpanel_node_style_set_min_height(_flex_node, _min_height, flexpanel_unit.point);
		}
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set flexpanel(element) max height
	///@arg {real} [_max_height]
	static setMaxHeight = function(_max_height = LUI_AUTO) {
		var _flex_node = self.flex_node;
		if _max_height != LUI_AUTO {
			flexpanel_node_style_set_max_height(_flex_node, _max_height, flexpanel_unit.point);
		}
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set flexpanel(element) min/max sizes
	///@arg {real} [_min_width]
	///@arg {real} [_max_width]
	///@arg {real} [_min_height]
	///@arg {real} [_max_height]
	static setMinMaxSize = function(_min_width = LUI_AUTO, _max_width = LUI_AUTO, _min_height = LUI_AUTO, _max_height = LUI_AUTO) {
		var _flex_node = self.flex_node;
		if _min_width != LUI_AUTO {
			flexpanel_node_style_set_min_width(_flex_node, _min_width, flexpanel_unit.point);
		}
		if _max_width != LUI_AUTO {
			flexpanel_node_style_set_max_width(_flex_node, _max_width, flexpanel_unit.point);
		}
		if _min_height != LUI_AUTO {
			flexpanel_node_style_set_min_height(_flex_node, _min_height, flexpanel_unit.point);
		}
		if _max_height != LUI_AUTO {
			flexpanel_node_style_set_max_height(_flex_node, _max_height, flexpanel_unit.point);
		}
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set flexpanel padding
	///@arg {real} _padding
	static setFlexPadding = function(_padding) {
		var _flex_node = self.getContainer().flex_node;
		flexpanel_node_style_set_padding(_flex_node, flexpanel_edge.all_edges, _padding);
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set flexpanel border
	///@arg {constant.flexpanel_edge} _edge
	///@arg {real} _border
	static setFlexBorder = function(_edge, _border) {
		var _flex_node = self.getContainer().flex_node;
		flexpanel_node_style_set_border(_flex_node, _edge, _border);
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set flexpanel gap
	///@arg {real} _gap
	static setFlexGap = function(_gap) {
		var _flex_node = self.getContainer().flex_node;
		flexpanel_node_style_set_gap(_flex_node, flexpanel_gutter.all_gutters, _gap);
		self.updateMainUiFlex();
		return self;
	}
	
	
	///@desc Set flexpanel direction (default is flexpanel_flex_direction.column)
	///@arg {constant.flexpanel_flex_direction} [_direction]
	static setFlexDirection = function(_direction = flexpanel_flex_direction.column) {
		var _flex_node = self.getContainer().flex_node;
		flexpanel_node_style_set_flex_direction(_flex_node, _direction);
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set flexpanel wrap type (default is flexpanel_wrap.no_wrap)
	///@arg {constant.flexpanel_wrap} [_wrap]
	static setFlexWrap = function(_wrap = flexpanel_wrap.no_wrap) {
		var _flex_node = self.getContainer().flex_node;
		flexpanel_node_style_set_flex_wrap(_flex_node, _wrap);
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set flexpanel grow (default is 1)
	///@arg {real} [_grow]
	static setFlexGrow = function(_grow = 1) {
		var _flex_node = self.flex_node;
		flexpanel_node_style_set_flex_grow(_flex_node, _grow);
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set flexpanel shrink type (default is 1)
	///@arg {real} [_shrink]
	static setFlexShrink = function(_shrink = 1) {
		var _flex_node = self.flex_node;
		flexpanel_node_style_set_flex_shrink(_flex_node, _shrink);
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set flexpanel justify content (default is flexpanel_justify.start)
	///@arg {constant.flexpanel_justify} [_flex_justify]
	static setFlexJustifyContent = function(_flex_justify = flexpanel_justify.start) {
		var _flex_node = self.getContainer().flex_node;
		flexpanel_node_style_set_justify_content(_flex_node, _flex_justify);
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set flexpanel align items (default is flexpanel_align.stretch)
	///@arg {constant.flexpanel_align} [_flex_align]
	static setFlexAlignItems = function(_flex_align = flexpanel_align.stretch) {
		var _flex_node = self.getContainer().flex_node;
		flexpanel_node_style_set_align_items(_flex_node, _flex_align);
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set flexpanel align self
	///@arg {constant.flexpanel_align} _flex_align
	static setFlexAlignSelf = function(_flex_align) {
		var _flex_node = self.flex_node;
		flexpanel_node_style_set_align_self(_flex_node, _flex_align);
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set flexpanel align content (default is flexpanel_justify.start)
	///@arg {constant.flexpanel_justify} [_flex_justify]
	static setFlexAlignContent = function(_flex_justify = flexpanel_justify.start) {
		var _flex_node = self.getContainer().flex_node;
		flexpanel_node_style_set_align_content(_flex_node, _flex_justify);
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set flexpanel display(flex) or not(none) (default is flexpanel_display.flex)
	///@arg {constant.flexpanel_display} [_flex_display]
	static setFlexDisplay = function(_flex_display = flexpanel_display.flex) {
		var _flex_node = self.flex_node;
		flexpanel_node_style_set_display(_flex_node, _flex_display);
		self.updateMainUiFlex();
		return self;
	}
	
	///@desc Set container, Sometimes the container may not be the element itself, but the element inside it (for example: LuiTab, LuiScrollPanel...)
	static setContainer = function(_container) {
		self.container = _container;
		return self;
	}
	
	///@desc setFocus
	static setFocus = function() {
		self.has_focus = true;
		if is_method(self.onFocusSet) self.onFocusSet();
		return self;
	}
	
	///@desc Set popup text to element when mouse on it
	static setTooltip = function(_string) {
		self.tooltip = _string;
		return self;
	}
	
	///@desc Binds the object/struct variable to the element value
	static setBinding = function(_source, _variable) {
		if (_source != noone && _variable != "") {
			self.binding_variable = {
				source : _source,
				variable : _variable
			}
			if LUI_LOG_ERROR_MODE == 2 && !variable_instance_exists(_source, _variable) {
				print($"LIME_UI.WARNING({self.name}): Can't find variable '{_variable}'!");
			}
		} else {
			if LUI_LOG_ERROR_MODE >= 1 print($"LIME_UI.ERROR({self.name}): Wrong variable name or instance!");
		}
		return self;
	}
	
	///@desc Set style
	static setStyle = function(_style) {
		self.style = new LuiStyle(_style);
		self.is_custom_style_setted = true;
		array_foreach(self.content, function(_elm) {
			_elm.setStyleChilds(self.style);
		});
		
		// Flex
		flexpanel_node_style_set_padding(self.flex_node, flexpanel_edge.all_edges, self.style.padding);
		flexpanel_node_style_set_gap(self.flex_node, flexpanel_gutter.all_gutters, self.style.padding);
		
		return self;
	}
	
	///@desc Set style for child elements
	static setStyleChilds = function(_style) {
		if self.is_custom_style_setted == false {
			self.style = _style;
		}
		for (var i = array_length(self.content)-1; i >= 0 ; --i) {
			var _element = self.content[i];
			_element.setStyleChilds(_style);
		}
		return self;
	}
	
	///@desc Set callback function
	static setCallback = function(callback) {
		if callback == undefined {
			if LUI_DEBUG_CALLBACK {
				self.callback = function() {show_debug_message(self.name + ": " + string(self.value))};
			} else {
				self.callback = function() { };
			}
		} else {
			self.callback = method(self, callback);
		}
		return self;
	}
	
	///@desc Set flag to update content
	static setNeedToUpdateContent = function(_update_parent) {
		if is_undefined(self.parent) return true;
		self.need_to_update_content = true;
		self.parent.setNeedToUpdateContent(_update_parent);
	}
	
	///@desc Set element visibility
	static setVisible = function(_visible) {
		if self.visibility_switching {
			if self.visible != _visible {
				// Change visible
				self.visible = _visible;
				// Events onShow / onHide
				if _visible {
					if is_method(self.onShow) self.onShow();
				} else {
					if is_method(self.onHide) self.onHide();
				}
				// Grid and flex update
				if !is_undefined(self.main_ui)  {
					self._gridUpdate();
					self.updateMainUiFlex();
				}
				// Main surface update 
				self.updateMainUiSurface();
			}
		}
		return self;
	}
	
	///@desc Enable or disable visibility switching by function setVisible()
	static setVisibilitySwitching = function(_allow) {
		self.visibility_switching = _allow;
		return self;
	}
	
	///@desc Set offset region for render content
	///@arg {struct} _region struct{left, right, top, bottom} or array [left, right, top, bottom]
	static setRenderRegionOffset = function(_region = {left : 0, right : 0, top : 0, bottom : 0}) {
		if is_struct(_region) {
			render_region_offset = _region;
		} else if is_array(_region) {
			if array_length(_region) != 4 {
				array_resize(_region, 4);
			}
			render_region_offset = {
				left : _region[0],
				right : _region[1],
				top : _region[2],
				bottom : _region[3]
			}
		} else if LUI_LOG_ERROR_MODE == 2 print($"LIME_UI.WARNING: setRenderRegionOffset: Wrong type appear, when struct or array is expected!");
		
		return self;
	}
	
	///@desc Enables/Disables mouse ignore mode
	static setMouseIgnore = function(_ignore = true) {
		self.ignore_mouse = _ignore;
		return self;
	}
	
	// SYSTEM
	
	///@desc Added elements into container of these element
	///@arg {Any} elements
	///@arg {Real} _custom_padding
	static addContent = function(elements, _custom_padding = LUI_AUTO) {
		
		// Convert to array if one element
		if !is_array(elements) elements = [elements];
		
		// Update array with delayed content for unordered adding
		if is_undefined(self.main_ui) {
			if !is_array(self.delayed_content) self.delayed_content = [];
			self.delayed_content = array_concat(self.delayed_content, elements);
			return self;
		}
		
		var _elements_count = array_length(elements);
		
		// Take ranges from array
		var _ranges = [];
		if is_array(elements[_elements_count - 1]) {
			if array_length(elements[_elements_count - 1]) != _elements_count - 1 {
				if LUI_LOG_ERROR_MODE == 2 {
					print($"LIME_UI.WARNING: Incorrect number of set ratios for elements. Elements {_elements_count - 1}, and relations {array_length(elements[_elements_count - 1])}");
					//???// Добавить возможность использования не подходящего количества соотношений, 
					//		если больше чем надо, выбирать из первых доступных по порядку, 
					//		если меньше оставшиеся подсчитывать соотношение из имеющихся
				}
			}
			_ranges = elements[_elements_count - 1];
			_elements_count--;
		}
		
		// Adding
		for (var i = 0; i < _elements_count; i++) {
			
			// Get element
			var _element = elements[i];
			
			// Recursion prevention
			if _element.is_adding continue;
			_element.is_adding = true;
			
			// Inherit variables
			_element.parent = self;
			_element.main_ui = self.main_ui;
			_element.style = self.style;
			
			// Set visible
			//_element.visible = self.visible; //???//
			
			// Get custom padding
			var _padding = _custom_padding;
			if _padding == LUI_AUTO {
				_padding = _element.style.padding;
			}
			
			// Flex setting up
			flexpanel_node_style_set_min_width(_element.flex_node, _element.style.min_width, flexpanel_unit.point); 	// min width
			flexpanel_node_style_set_min_height(_element.flex_node, _element.style.min_height, flexpanel_unit.point); 	// min height
			flexpanel_node_style_set_gap(_element.flex_node, flexpanel_gutter.all_gutters, _padding); 					// gap
			flexpanel_node_style_set_padding(_element.flex_node, flexpanel_edge.all_edges, _padding); 					// padding
			if array_length(_ranges) == _elements_count  {
				flexpanel_node_style_set_flex(_element.flex_node, _ranges[i]);
			}
			flexpanel_node_insert_child(self.flex_node, _element.flex_node, flexpanel_node_get_num_children(self.flex_node)); 	// binding
			
			// Register element name
			_element._registerElementName();
			
			// Add to content array
			array_push(self.content, _element);
			
			_element._addDelayedContent();
			
			// Call custom method create
			if is_method(_element.onCreate) _element.onCreate();
			
			_element.is_adding = false;
		}
		// Apply alignment
		self.flexCalculateLayout();
		self.flexUpdateAll();
		self.setNeedToUpdateContent(true);
		return self;
	}
	
	///@desc This function updates all nested elements
	static update = function() {
		// Limit updates
		if (!self.visible || self.deactivated || self.inside_parent == 0) {
			return false;
		}
		
		// Check if the element is in the area of its parent and call its step function
		if (self.inside_parent && is_method(self.step)) {
			self.step();
		}
		
		// Update all elements inside
		var content_length = array_length(self.content);
		for (var i = content_length - 1; i >= 0; --i) {
			var _element = self.content[i];
			
			// On position update logic
			var _cur_x = floor(_element.x);
			var _cur_y = floor(_element.y);
			if (_element.previous_x != _cur_x || _element.previous_y != _cur_y) {
				// Check if element is inside parents
				_element.inside_parent = isInsideParents(_element.x, _element.y, _element.x + _element.width, _element.y + _element.height);
				if _element.inside_parent {
					// Call onPositionUpdate method of each element
					if is_method(_element.onPositionUpdate) _element.onPositionUpdate();
					// Update main surface
					_element.updateMainUiSurface();
				}
			}
			
			// Save previous position
			_element.previous_x = _cur_x;
			_element.previous_y = _cur_y;
			
			if !_element.inside_parent {
				_element._gridDelete();
				continue;
			}
			
			// Update element
			_element.update();
			
			// Update binding variable
			if _element.binding_variable != -1 && _element.get() != variable_instance_get(_element.binding_variable.source, _element.binding_variable.variable) {
				_element.updateFromBinding();
			}
			
			// Call onContentUpdate of each lement if need it
			if (_element.need_to_update_content) {
				if is_method(_element.onContentUpdate) _element.onContentUpdate();
				_element.need_to_update_content = false;
			}
			
			// Update grid position
			var _grid_x1 = floor(_element.x / LUI_GRID_ACCURACY);
			var _grid_y1 = floor(_element.y / LUI_GRID_ACCURACY);
			var _grid_x2 = floor((_element.x + _element.width) / LUI_GRID_ACCURACY);
			var _grid_y2 = floor((_element.y + _element.height) / LUI_GRID_ACCURACY);
			if (_element.grid_previous_x1 != _grid_x1 || _element.grid_previous_y1 != _grid_y1) 
			|| (_element.grid_previous_x2 != _grid_x2 || _element.grid_previous_y2 != _grid_y2) {
				_element._gridUpdate();
			}
			
			// Save grid previous position
			_element.grid_previous_x1 = _grid_x1;
			_element.grid_previous_y1 = _grid_y1;
			_element.grid_previous_x2 = _grid_x2;
			_element.grid_previous_y2 = _grid_y2;
		}
	}
	
	///@desc This function draws all nested elements
	static render = function() {
		for (var i = 0, n = array_length(self.content); i < n; i++) {
			// Get element
			var _element = self.content[i];
			// Restriction
			if !_element.visible || !_element.inside_parent continue;
			// Draw self
			if is_method(_element.draw) _element.draw();
			// Draw content
			if _element.render_content_enabled {
				if self.draw_content_in_cutted_region {
					var _gpu_scissor = gpu_get_scissor();
					var _x = self.x + self.render_region_offset.left;
					var _y = self.y + self.render_region_offset.top;
					var _w = self.width - self.render_region_offset.left - self.render_region_offset.right;
					var _h = self.height - self.render_region_offset.top - self.render_region_offset.bottom;
					gpu_set_scissor(_x, _y, _w, _h);
				}
				_element.render();
				if self.draw_content_in_cutted_region {
					gpu_set_scissor(_gpu_scissor);
				}
			}
		}
		if global.lui_debug_mode != 0 {
			for (var i = 0, n = array_length(self.content); i < n; i++) {
				//Get element
				var _element = self.content[i];
				if !_element.visible || !_element.inside_parent continue;
				_element._renderDebug(_element.x, _element.y);
			}
			
		}
	}
	
	///@desc Centers the content. Calls setFlexJustifyContent and setFlexAlignItems with centering
	static centerContent = function() {
		self.setFlexJustifyContent(flexpanel_justify.center)
			.setFlexAlignItems(flexpanel_align.center);
		return self;
	}
	
	///@desc Remove focus from element
	static removeFocus = function() {
		self.has_focus = false;
		if is_method(self.onFocusRemove) self.onFocusRemove();
		return self;
	}
	
	///@desc Activate an element
	static activate = function() {
		self.deactivated = false;
		array_foreach(self.content, function(_elm) {
			_elm.activate();
		});
		return self;
	}
	
	///@desc Deactivate an element
	static deactivate = function() {
		self.deactivated = true;
		array_foreach(self.content, function(_elm) {
			_elm.deactivate();
		});
		return self;
	}
	
	///@desc Calculate all sizes and positions of elements
	static flexCalculateLayout = function() {
		if !is_undefined(self.main_ui) {
			flexpanel_calculate_layout(self.main_ui.flex_node, self.main_ui.width, self.main_ui.height, flexpanel_direction.LTR);
			return true;
		}
		return false;
	}
	
	///@desc Update position, size and z depth for specified flex node
	static flexUpdate = function(_node) {
		
		// Dont update not inside parents elements
		if !self.inside_parent exit;
		
		// Get layout data
		var _pos = flexpanel_node_layout_get_position(_node, false);
		
		// Update element
		var _data = flexpanel_node_get_data(_node);
		var _element = _data.element;
		_element.x = _pos.left;
		_element.y = _pos.top;
		_element.pos_x = _pos.left;
		_element.pos_y = _pos.top;
		_element.width = _pos.width;
		_element.height = _pos.height;
		if (_element.start_x == -1) {
			_element.start_x = _element.x;
		}
		if (_element.start_y == -1) {
			_element.start_y = _element.y;
		}
		_element.z = global.lui_z_index++;
		
		// Call for children (recursive)
		var _children_count = flexpanel_node_get_num_children(_node);
		for (var i = 0; i < _children_count; i++) {
			// Dont update not inside parents elements
			if !_element.inside_parent continue;
			// Get child node
			var _child = flexpanel_node_get_child(_node, i);
			// Update child node
			_element.flexUpdate(_child);
		}
	}
	
	///@desc Update position, size and z depth of all elements with depth reset
	static flexUpdateAll = function() {
		if !is_undefined(main_ui) {
			// Reset z depth index
			global.lui_z_index = 0;
			// Update all elements
			flexUpdate(self.main_ui.flex_node);
		}
	}
	
	///@desc Update element value from binding variable
	static updateFromBinding = function() {
		var _source = binding_variable.source;
		var _variable = binding_variable.variable;
		if (_source != noone && variable_instance_exists(_source, _variable)) {
			var _source_value = variable_instance_get(_source, _variable);
			set(_source_value);
		} else {
			if LUI_LOG_ERROR_MODE >= 1 print($"LIME_UI.ERROR({self.name}): The binding variable is no longer available!");
		}
	}
	
	///@desc Update binding variable from element value
	static updateToBinding = function() {
		var _source = binding_variable.source;
		var _variable = binding_variable.variable;
		if (_source != noone && variable_instance_exists(_source, _variable)) {
			var _element_value = get();
			variable_instance_set(_source, _variable, _element_value);
		} else {
			if LUI_LOG_ERROR_MODE >= 1 print($"LIME_UI.ERROR({self.name}): The binding variable is no longer available!");
		}
	}
	
	///@desc Update main ui surface
	static updateMainUiSurface = function() {
		if is_undefined(self.main_ui) return self;
		self.main_ui.needs_redraw_surface = true;
		return self;
	}
	
	///@desc Update main ui flex
	static updateMainUiFlex = function() {
		if is_undefined(self.main_ui) return self;
		self.main_ui.needs_update_flex = true;
		return self;
	}
	
	///@desc Returns true if the mouse is hovered over this element
	static isMouseHovered = function() {
		return self.is_mouse_hovered;
	}
	
	///@desc Returns true if the mouse is hovered over this element, excluding all elements above it
	static isMouseHoveredExc = function() {
		if !self.visible return false;
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		var _element_x = self.x;
		var _element_y = self.y;
		var _on_this = point_in_rectangle(_mouse_x, _mouse_y, _element_x, _element_y, _element_x + self.width - 1, _element_y + self.height - 1);
		return _on_this;
	}
	
	///@desc Returns true if the mouse is hovered over this element and its parent
	static isMouseHoveredParents = function() {
		if is_undefined(self.parent) return true;
		if self.isMouseHoveredExc() {
			return self.parent.isMouseHoveredParents();
		} else {
			return false;
		}
	}
	
	///@desc Returns true if the specified rectangle is within the parent and its parents at the same time
	static isInsideParents = function(_x1, _y1, _x2, _y2) {
		if is_undefined(self.parent) return true;
		var _parent_x = self.parent.x;
		var _parent_y = self.parent.y;
		var _inside_parent = rectangle_in_rectangle(
			_x1, _y1, _x2, _y2,
			_parent_x, _parent_y, _parent_x + self.parent.width, _parent_y + self.parent.height
		);
		if _inside_parent {
			return self.parent.isInsideParents(_x1, _y1, _x2, _y2);
		} else {
			return false;
		}
	}
	
	///@desc Returns true if the mouse is hovered over the descendants of this element
	static isMouseHoveredChilds = function() {
		if !self.visible return false;
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		var _on_element = false;
		for (var i = 0, _n = array_length(self.content); i < _n; ++i) {
		    var _element = self.content[i];
			if _element.isMouseHoveredChilds() {
				return true;
			}
		}
		return self.isMouseHovered() ? true : false;
	}
	
	///@desc Destroys self and all nested elements
	static destroy = function() {
		for (var i = array_length(self.content) - 1; i >= 0; --i) {
			
			//var _element = self.content[i];
			//_element.destroy();
			
			var _error = false;
			try {
				var _element = self.content[i];
				_element.destroy();
			} catch(_e) {
				_error = true;
			} finally {
				if _error {} //???//
				//print("============ERROR===========");
			}
		}
		if self == main_ui.element_in_focus {
			self.main_ui.element_in_focus.removeFocus();
			self.main_ui.element_in_focus = undefined;
		}
		if is_method(self.onDestroy) self.onDestroy();
		self._deleteElementName();
		self._gridCleanUp();
		self.setNeedToUpdateContent(true);
		self.content = -1;
		flexpanel_node_style_set_display(self.flex_node, flexpanel_display.none);
		self.flexCalculateLayout();
		self.flex_node = flexpanel_delete_node(self.flex_node, false);
		self.updateMainUiFlex();
		self.updateMainUiSurface();
		global.lui_element_count--;
		//Delete self from parent content
		if !is_undefined(parent) {
			if parent.content != -1 {
				var _ind = array_find_index(parent.content, function(_elm) {
					return _elm == self;
				});
				array_delete(parent.content, _ind, 1);
			}
		}
	}
	
	///@desc Destroys all nested elements
	static destroyContent = function() {
		if array_length(self.content) > 0 {
			for (var i = array_length(self.content) - 1;  i >= 0; --i) {
			    var _element = self.content[i];
				_element.destroy();
			}
		}
	}
	
	// PRIVATE SYSTEM
	
	///@desc Init element variables
	///@ignore
	static _initElement = function() {
		if self.pos_x == LUI_AUTO {
			self.auto_x = true;
			self.pos_x = 0;
		}
		if self.pos_y == LUI_AUTO {
			self.auto_y = true;
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
		self._initFlexNode();
	}
	
	///@desc Initialize flex node
	///@ignore
	static _initFlexNode = function() {
		// Flex node (default for all elements)
		self.flex_node = flexpanel_create_node({
			name: self.name, 
			data: {}
		});
		
		// Position X
		if !self.auto_x {
			flexpanel_node_style_set_position(self.flex_node, flexpanel_edge.left, self.pos_x, flexpanel_unit.point);
		}
		
		// Position Y
		if !self.auto_y {
			flexpanel_node_style_set_position(self.flex_node, flexpanel_edge.top, self.pos_y, flexpanel_unit.point);
		}
		
		// Width
		if !self.auto_width {
			flexpanel_node_style_set_width(self.flex_node, self.width, flexpanel_unit.point);
		} else {
			flexpanel_node_style_set_width(self.flex_node, 100, flexpanel_unit.percent);
			flexpanel_node_style_set_flex_shrink(self.flex_node, 1);
		}
		
		// Height
		if !self.auto_height {
			flexpanel_node_style_set_height(self.flex_node, self.height, flexpanel_unit.point);
		}
		
		var _data = flexpanel_node_get_data(self.flex_node);
		_data.element = self;
	}
	
	///@desc Adds elements from a delayed array
	///@ignore
	static _addDelayedContent = function() {
		if is_array(self.delayed_content) {
			if !is_undefined(self.delayed_content) && array_length(self.delayed_content) > 0 {
				self.addContent(self.delayed_content);
				self.delayed_content = -1;
			}
		}
	}
	
	///@desc Render debug info of element
	///@ignore
	static _renderDebug = function(_x = 0, _y = 0) {
		// Set font
		if !is_undefined(self.style.font_debug) {
			draw_set_font(self.style.font_debug);
		}
		// Remember prev colors
		var _prev_color = draw_get_color();
		var _prev_alpha = draw_get_alpha();
		// Set colors
		if isMouseHovered() {
			draw_set_alpha(1);
			draw_set_color(c_red);
		} else {
			draw_set_alpha(0.5);
			draw_set_color(make_color_hsv(self.element_id * 20 % 255, 255, 255));
		}
		// Draw rectangles
		if isMouseHovered() {
			draw_rectangle(_x-1, _y-1, _x + self.width - 1 + 1, _y + self.height - 1 + 1, true);
		} else {
			draw_rectangle(_x, _y, _x + self.width - 1, _y + self.height - 1, true);
		}
		// Draw text
		if global.lui_debug_mode == 2 {
			_luiDrawTextDebug(_x, _y, 
			"id: " + string(self.element_id) + "\n" +
			"name: " + string(self.name) + "\n" +
			"x: " + string(self.pos_x) + (self.auto_x ? " (auto)" : "") + " y: " + string(self.pos_y) + (self.auto_y ? " (auto)" : "") + "\n" +
			"w: " + string(self.width) + (self.auto_width ? " (auto)" : "") + " h: " + string(self.height) + (self.auto_height ? " (auto)" : "") + "\n" +
			"v: " + string(self.value) + "\n" +
			"content: " + string(array_length(self.content)) + "/" + string(array_length(self.delayed_content)) + "\n" +
			"parent: " + (is_undefined(self.parent) ? "undefined" : self.parent.name) + "\n" +
			"z: " + string(self.z));
		}
		// Reset colors
		draw_set_color(_prev_color);
		draw_set_alpha(_prev_alpha);
	}
	
	///@desc Draw debug text with rectangle
	///@ignore
	static _luiDrawTextDebug = function(_x, _y, text) {
		var _text_width = string_width(text);
		var _text_height = string_height(text);
		_x = clamp(_x, 0, display_get_gui_width() - _text_width);
		_y = clamp(_y, 0, display_get_gui_height() - _text_height);
		draw_set_color(c_black);
		draw_rectangle(_x, _y, _x + _text_width, _y + _text_height, false);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);
		draw_text(_x, _y, text);
	}
	
	///@desc Returns text fit to width
	///@return {string}
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
	
	///@desc Draw text fit to width
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
	
	///@ignore
	static _registerElementName = function() {
		if !variable_struct_exists(self.main_ui.element_names, self.name) {
			variable_struct_set(self.main_ui.element_names, self.name, self);
		} else {
			if LUI_LOG_ERROR_MODE == 2 print($"LIME_UI.WARNING: Element name \"{self.name}\" already exists! A new name will be given automatically");
			var _new_name = self.name + "_" + string(self.element_id) + "_" + md5_string_utf8(self.name + string(self.element_id));
			variable_struct_set(self.main_ui.element_names, _new_name, self);
			self.name = _new_name;
		}
	}
	///@ignore
	static _deleteElementName = function() {
		if self != self.main_ui {
			if variable_struct_exists(self.main_ui.element_names, self.name) {
				variable_struct_remove(self.main_ui.element_names, self.name);
			} else {
				if LUI_LOG_ERROR_MODE >= 1 print($"LIME_UI.ERROR: Can't find name \"{self.name}\"!");
			}
		}
	}
	
	///@desc Add element in system ui grid
	///@ignore
	static _gridAdd = function() {
		if (!self.inside_parent || !self.visible) {
			return false;
		}
	
		// Calculate the start and end cells that the element intersects
		var _elm_x_start = floor(self.x / LUI_GRID_SIZE);
		var _elm_y_start = floor(self.y / LUI_GRID_SIZE);
		var _elm_x_end = floor((self.x + self.width) / LUI_GRID_SIZE);
		var _elm_y_end = floor((self.y + self.height) / LUI_GRID_SIZE);
	
		// Restrict grid pass to only the required cells
		for (var _x = _elm_x_start; _x <= _elm_x_end; ++_x) {
			for (var _y = _elm_y_start; _y <= _elm_y_end; ++_y) {
				var _key = string(_x) + "_" + string(_y);
				
				if (variable_struct_exists(self.main_ui._screen_grid, _key)) {
					var _array = self.main_ui._screen_grid[$ _key];
					_array[array_length(_array)] = self;
					self._grid_location[array_length(self._grid_location)] = _key;
				}
			}
		}
	};
	
	///@desc Delete lement from system ui grid
	///@ignore
	static _gridDelete = function() {
		var _grid_location_length = array_length(self._grid_location);
		for (var i = _grid_location_length - 1; i >= 0; --i) {
			var _key = self._grid_location[i];
			
			if (variable_struct_exists(self.main_ui._screen_grid, _key)) {
				var _array = self.main_ui._screen_grid[$ _key];
				var _array_length = array_length(_array);
				for (var j = _array_length-1; j >= 0; --j) {
					if (_array[j].element_id == self.element_id) {
						array_delete(_array, j, 1);
						break;
					}
				}
			}
		}
		
		self._grid_location = [];
	};
	
	///@desc Update element in system ui grid
	///@ignore
	static _gridUpdate = function() {
		self._gridDelete();
		self._gridAdd();
	}
	
	///@desc Delete element from grid and clean up array
	///@ignore
	static _gridCleanUp = function() {
		self._gridDelete();
		self._grid_location = -1;
	}
	
	///@desc Draw debug grid info
	///@ignore
	static _drawScreenGrid = function() {
		draw_set_alpha(1);
		draw_set_color(c_red);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_font(fDebug);
		
		var gui_width = display_get_gui_width();
		var gui_height = display_get_gui_height();
		
		var _width = ceil(gui_width / LUI_GRID_SIZE);
		var _height = ceil(gui_height / LUI_GRID_SIZE);
		
		for (var _x = 0; _x <= _width; ++_x) {
			var x_pos = _x * LUI_GRID_SIZE;
			draw_line(x_pos, 0, x_pos, gui_height);
			
			for (var _y = 0; _y <= _height; ++_y) {
				var y_pos = _y * LUI_GRID_SIZE;
				
				if _x == 0 draw_line(0, y_pos, gui_width, y_pos);
				
				var _key = string(_x) + "_" + string(_y);
				var _array = self.main_ui._screen_grid[$ _key];
				draw_text(x_pos + 2, y_pos + 1, string(_key));
				
				var _elements_in_cell = array_length(_array);
				for (var i = 0, n = min(18, _elements_in_cell); i < n; ++i) {
					if i mod 2 == 0 draw_set_color(c_orange); else draw_set_color(c_red);
					draw_text(x_pos + 2, y_pos + 1 + 12 + 6 * i, string_copy(_array[i].name, 0, 18));
				}
				draw_set_color(c_red);
				if _elements_in_cell > 18 {
					draw_text(x_pos + 2, y_pos + 1 + 12 + 6 * 18, $"and {array_length(_array) - 18} elements...");
				}
			}
		}
	};
}