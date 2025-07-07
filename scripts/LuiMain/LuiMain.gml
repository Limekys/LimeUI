/// @desc Main UI container wich would be controll and render your UI.
function LuiMain() : LuiBase() constructor {
	
	// Main variables
	self.name = "__lui_main_ui";
	self.width = display_get_gui_width();
	self.height = display_get_gui_height();
	self.ui_screen_surface = -1;
	self.needs_redraw_surface = true;
	self.pre_draw_list = [];
	self.element_names = {};
	self.main_ui = self;
	self.element_in_focus = undefined;
	self.topmost_hovered_element = undefined;
	self.dragging_element = undefined;
	self.display_focused_element = false;
	self.waiting_for_keyboard_input = false;
	self.needs_update_flex = true;
	
	// Init Flex
	self.flex_node = flexpanel_create_node({name: self.name, data: {}});
	flexpanel_node_style_set_width(self.flex_node, self.width, flexpanel_unit.point);
	flexpanel_node_style_set_height(self.flex_node, self.height, flexpanel_unit.point);
	var _data = flexpanel_node_get_data(self.flex_node);
	_data.element = self;
	
	// Init Screen grid
	self._screen_grid = {};
	static recalculateScreenGrid = function() {
		for (var _x = 0, _width = ceil(display_get_gui_width() / LUI_GRID_SIZE); _x < _width; ++_x) {
			for (var _y = 0, _height = ceil(display_get_gui_height() / LUI_GRID_SIZE); _y < _height; ++_y) {
				var _key = string(_x) + "_" + string(_y);
				if !is_array(self._screen_grid[$ _key]) {
					self._screen_grid[$ _key] = array_create(0);
				}
			}
		}
		return self;
	}
	self.recalculateScreenGrid();
	
	// Recalculate grid size on size change
	self.onSizeUpdate = function() {
		self.recalculateScreenGrid();
	}
	
	// Update
	self.base_update = method(self, update);
	self.update = function() {
		
		// Update all elements
		self.base_update();
			
		// Mouse position
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
			
		// Mouse events
		if self.visible && !self.deactivated && (_mouse_x >= 0 && _mouse_x < self.width && _mouse_y >= 0 && _mouse_y < self.height) {
			var _previous_hovered_element = self.topmost_hovered_element;
			
			// Prioritize dragging element if it exists and mouse is held
			if (!is_undefined(self.dragging_element) && mouse_check_button(mb_left)) {
				self.topmost_hovered_element = self.dragging_element;
			} else {
				self.topmost_hovered_element = self.getTopmostElement(_mouse_x, _mouse_y);
			}
			
			// Update mouse hover state
			if !is_undefined(_previous_hovered_element) && _previous_hovered_element != self.topmost_hovered_element {
				_previous_hovered_element.is_mouse_hovered = false;
				// Call onMouseLeave method
				if is_method(_previous_hovered_element.onMouseLeave) {
					_previous_hovered_element.onMouseLeave();
				}
				self.updateMainUiSurface();
			}
			
			if (!is_undefined(self.topmost_hovered_element) && !self.topmost_hovered_element.deactivated) {
				if self.topmost_hovered_element.is_mouse_hovered == false {
					self.topmost_hovered_element.is_mouse_hovered = true;
					// Call onMouseEnter method
					if is_method(self.topmost_hovered_element.onMouseEnter) {
						self.topmost_hovered_element.onMouseEnter();
					}
					self.updateMainUiSurface();
				}
				
				// Handle on mouse pressed
				if (mouse_check_button_pressed(mb_left)) {
					// Call onMouseLeftPressed method
					if is_method(self.topmost_hovered_element.onMouseLeftPressed) {
						self.topmost_hovered_element.onMouseLeftPressed();
					}
					// Set focus on element
					if self.element_in_focus != self.topmost_hovered_element {
						// Remove focus from previous element
						if !is_undefined(self.element_in_focus) {
							self.element_in_focus.removeFocus();
							self.element_in_focus = undefined;
						}
						self.topmost_hovered_element.setFocus();
						self.element_in_focus = self.topmost_hovered_element;
					}
					// Set dragging element
					if (self.topmost_hovered_element.can_drag) {
						self.topmost_hovered_element.is_dragging = true;
						self.topmost_hovered_element.drag_offset_x = _mouse_x - self.topmost_hovered_element.x;
						self.topmost_hovered_element.drag_offset_y = _mouse_y - self.topmost_hovered_element.y;
						self.dragging_element = self.topmost_hovered_element;
					}
					self.updateMainUiSurface();
				}
				
				// Handle on mouse left
				if (mouse_check_button(mb_left)) {
					// Call onMouseLeft method
					if is_method(self.topmost_hovered_element.onMouseLeft) {
						self.topmost_hovered_element.onMouseLeft();
					}
					// Handle dragging
					if (self.topmost_hovered_element.can_drag && !is_undefined(self.dragging_element)) {
						var _new_pos_x = clamp(_mouse_x - self.topmost_hovered_element.drag_offset_x, 0, self.width - self.topmost_hovered_element.width);
						var _new_pos_y = clamp(_mouse_y - self.topmost_hovered_element.drag_offset_y, 0, self.height - self.topmost_hovered_element.height);
						if self.topmost_hovered_element.x != _new_pos_x || self.topmost_hovered_element.y != _new_pos_y {
							self.topmost_hovered_element.setPosition(_new_pos_x, _new_pos_y);
							if is_method(self.topmost_hovered_element.onDragging) {
								self.topmost_hovered_element.onDragging();
							}
							self.updateMainUiSurface();
						}
					}
				}
				
				// Handle on mouse released
				if (mouse_check_button_released(mb_left)) {
					// Call onMouseLeftReleased method
					if is_method(self.topmost_hovered_element.onMouseLeftReleased) {
						self.topmost_hovered_element.onMouseLeftReleased();
					}
					// Clear dragging
					if !is_undefined(self.dragging_element) {
						self.dragging_element.is_dragging = false;
						self.dragging_element = undefined;
					}
					// Remove focus from element if clicking outside
					if !is_undefined(self.element_in_focus) && self.element_in_focus != self.topmost_hovered_element {
						self.element_in_focus.removeFocus();
						self.element_in_focus = undefined;
					}
					self.updateMainUiSurface();
				}
				if is_method(self.topmost_hovered_element.onMouseWheel) && (mouse_wheel_down() || mouse_wheel_up()) {
					self.topmost_hovered_element.onMouseWheel();
				}
			} else {
				// Remove focus from element
				if !is_undefined(self.element_in_focus) {
					if (mouse_check_button_pressed(mb_left) || mouse_check_button_released(mb_left)) {
						self.element_in_focus.removeFocus();
						self.element_in_focus = undefined;
						self.dragging_element = undefined;
						self.updateMainUiSurface();
					}
				}
			}
		} else {
			// Clear dragging element if mouse is outside UI
			self.dragging_element = undefined;
		}
		
		// Keyboard events
		if self.visible && !self.deactivated && !is_undefined(self.element_in_focus) {
			if is_method(self.element_in_focus.onKeyboardInput) && keyboard_check(vk_anykey) {
				self.element_in_focus.onKeyboardInput();
			}
			if is_method(self.element_in_focus.onKeyboardRelease) && keyboard_check_released(vk_anykey) {
				self.element_in_focus.onKeyboardRelease();
			}
			if keyboard_check_pressed(vk_escape) {
				self.element_in_focus.removeFocus();
				self.element_in_focus = undefined;
				self.updateMainUiSurface();
			}
		}
		
		// Update layout and all flex data
		if self.needs_update_flex {
			self.needs_update_flex = false;
			self.flexCalculateLayout();
			self.flexUpdate(self.flex_node);
		}
	}
	
	// Render
	self.base_render = method(self, render);
	self.render = function() {
		 
		// Get previous alpha
		var _prev_alpha = draw_get_alpha();
		
		// Set alpha before render
		if LUI_FORCE_ALPHA_1 {
			draw_set_alpha(1);
		}
		
		// Pre draw events
		for (var i = 0, n = array_length(self.pre_draw_list); i < n; ++i) {
			var _element = self.pre_draw_list[i];
			if is_method(_element.preDraw) _element.preDraw();
		}
		
		// Create main ui surface
		if !surface_exists(self.ui_screen_surface) {
			self.ui_screen_surface = surface_create(self.width, self.height);
			self.needs_redraw_surface = true;
		}
		
		// Check surface size
		if surface_get_width(self.ui_screen_surface) != self.width || surface_get_height(self.ui_screen_surface) != self.height {
			surface_resize(self.ui_screen_surface, self.width, self.height);
		}
		
		// Update main ui surface
		if self.needs_redraw_surface {
			// Set alpha 1 for drawing surface
			draw_set_alpha(1);
			
			// Set ui surface
			surface_set_target(self.ui_screen_surface);
			draw_clear_alpha(c_black, 0);
			gpu_set_blendequation_sepalpha(bm_eq_add, bm_eq_max);
			
			// Draw all elements
			self.base_render();
			
			// Reset ui surface
			gpu_set_blendequation(bm_eq_add);
			surface_reset_target();
			self.needs_redraw_surface = false;
			
			// Reset alpha
			draw_set_alpha(LUI_FORCE_ALPHA_1 ? 1 : _prev_alpha);
		}
		
		// Draw all to screen
		if self.visible {
			//Draw main ui surface
			draw_surface_ext(self.ui_screen_surface, self.x, self.y, 1, 1, 0, c_white, LUI_FORCE_ALPHA_1 ? 1 : _prev_alpha);
			//Draw other stuff
			if self.display_focused_element {
				if !is_undefined(self.element_in_focus) {
					var _elm_x = self.element_in_focus.x;
					var _elm_y = self.element_in_focus.y;
					var _elm_w = self.element_in_focus.width;
					var _elm_h = self.element_in_focus.height;
					draw_rectangle_color(_elm_x - 1, _elm_y - 1, _elm_x + _elm_w, _elm_y + _elm_h, c_white, c_white, c_white, c_white, true);
				}
			}
		}
		
		// Get topmost element
		var _element = self.topmost_hovered_element;
		
		// Draw tooltip text
		if !is_undefined(_element) {
			if _element.tooltip != "" {
				var _padding = self.style.padding; //Screen border indentation
				var _padding_text = self.style.padding; //Text border indentation inside tooltip box
				draw_set_font(self.style.font_default);
				var _width = string_width(_element.tooltip) + _padding_text*2;
				var _height = string_height(_element.tooltip) + _padding_text*2;
				var _mouse_x = clamp(device_mouse_x_to_gui(0) + 16, _padding, self.width - _width - _padding);
				var _mouse_y = clamp(device_mouse_y_to_gui(0) + 16, _padding, self.height - _height - _padding);
				// Draw tooltip sprite back
				if !is_undefined(self.style.sprite_tooltip) {
					draw_sprite_stretched_ext(self.style.sprite_tooltip, 0, _mouse_x, _mouse_y, _width, _height, self.style.color_primary, LUI_FORCE_ALPHA_1 ? 1 : _prev_alpha);
				}
				// Draw tooltip sprite border
				if !is_undefined(self.style.sprite_tooltip_border) {
					draw_sprite_stretched_ext(self.style.sprite_tooltip_border, 0, _mouse_x, _mouse_y, _width, _height, self.style.color_border, LUI_FORCE_ALPHA_1 ? 1 : _prev_alpha);
				}
				// Draw text
				draw_set_color(self.style.color_text);
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				draw_text(_mouse_x + _padding_text, _mouse_y + _padding_text, _element.tooltip);
			}
		}
		
		// Draw debug screen grid
		if global.lui_debug_render_grid {
			self._drawScreenGrid();
		}
		
		// Draw debug info under mouse
		if global.lui_debug_mode != 0 && !is_undefined(_element) {
			//Mouse coords
			var _mouse_x = device_mouse_x_to_gui(0) + 32;
			var _mouse_y = device_mouse_y_to_gui(0) + 32;
			//Text
			_element._renderDebugInfo(_mouse_x, _mouse_y);
		}
	}
	
	// Cleanup
	self.onDestroy = function() {
		if surface_exists(self.ui_screen_surface) {
			surface_free(self.ui_screen_surface);
		}
		self.pre_draw_list = -1;
		self.element_in_focus = undefined;
		self.dragging_element = undefined; // Clear dragging element
		delete self._screen_grid;
		delete self.element_names;
		global.lui_element_count = 0;
		global.lui_max_z = 0;
	}
	
	// CHECKERS
	
	///@desc Return true if we interacting with UI at the moment with mouse or keyboard
	static isInteracting = function() {
		return self.isInteractingKeyboard() || self.isInteractingMouse();
	}
	
	///@desc Return true if we interacting with UI at the moment with mouse
	static isInteractingMouse = function() {
		return self.visible && !self.deactivated && !is_undefined(self.topmost_hovered_element);
	}
	
	///@desc Return true if we interacting with UI at the moment with keyboard
	static isInteractingKeyboard = function() {
		return self.visible && !self.deactivated && self.waiting_for_keyboard_input;
	}
	
	// GETTERS
	
	///@desc Get element by name
	///@return {Struct}
	static getElement = function(_name) {
		if variable_struct_exists(self.element_names, _name) {
			return variable_struct_get(self.element_names, _name);
		} else {
			if LUI_LOG_ERROR_MODE >= 1 print($"LIME_UI.ERROR: Can't find element {_name}!");
			return -1;
		}
	}
}