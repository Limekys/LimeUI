///@desc Main UI container which would control and render your UI.
function LuiMain() : LuiBase() constructor {
	
	self.is_initialized = true;
	self.ignore_mouse = true;
	
	// Main variables
	self.name = "_LUI_MAIN_UI";
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
	self.current_debug_mode = 0;
	self.active_animations = [];
	self.prev_mouse_x = -1;
	self.prev_mouse_y = -1;
	self._screen_grid = {};
	self.rectangles_to_redraw = [];
	self.elements_to_update_flex = [];
	
	// Init Flex size
	flexpanel_node_style_set_width(self.flex_node, self.width, flexpanel_unit.point);
	flexpanel_node_style_set_height(self.flex_node, self.height, flexpanel_unit.point);
	
	// Init Screen grid
	///@ignore
	static _recalculateScreenGrid = function() {
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
	self._recalculateScreenGrid();
	
	// Recalculate grid size on size change
	self.addEvent(LUI_EV_SIZE_UPDATE, function(_e) {
		_e._recalculateScreenGrid();
	});
	
	// Init easing functions
	_luiInitEaseFunctions();
	
	// SYSTEM
	
	///@desc Create animation for any variables of target element
	static animate = function(target_element, property, end_value, duration, easing_func = global.Ease.OutQuad) {
	    
		// Delete previous if found to exlude animation conflicts
		for (var i = array_length(self.active_animations) - 1; i >= 0; --i) {
	        var _existing_tween = self.active_animations[i];
	        if (_existing_tween.target == target_element && _existing_tween.property == property) {
	            array_delete(self.active_animations, i, 1);
	            break;
	        }
	    }
		
		// Create new tween
		var _tween = new LuiTween(target_element, property, end_value, duration, easing_func);
	    array_push(self.active_animations, _tween);
		
		return _tween;
	}
	
	///@desc Set flag to display or not display white rectangle on focused element
	///@arg {bool} _display
	static displayFocusedElement = function(_display) {
		self.display_focused_element = _display;
	}
	
	// CHECKERS
	
	///@desc Return true if we interacting with UI at the moment with mouse or keyboard
	///@return {bool}
	static isInteracting = function() {
		return self.isInteractingKeyboard() || self.isInteractingMouse();
	}
	
	///@desc Return true if we interacting with UI at the moment with mouse
	///@return {bool}
	static isInteractingMouse = function() {
		return self.visible && !self.deactivated && !is_undefined(self.topmost_hovered_element);
	}
	
	///@desc Return true if we interacting with UI at the moment with keyboard
	///@return {bool}
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
			_luiPrintError($"Can't find element {_name}!");
			return -1;
		}
	}
	
	// UPDATE
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
				self.topmost_hovered_element = self._getTopmostElement(_mouse_x, _mouse_y);
			}
			
			// Update mouse hover state
			if !is_undefined(_previous_hovered_element) && _previous_hovered_element != self.topmost_hovered_element {
				_previous_hovered_element.is_mouse_hovered = false;
				_previous_hovered_element.is_pressed = false;
				_previous_hovered_element._dispatchEvent(LUI_EV_MOUSE_LEAVE);
			}
			
			if (!is_undefined(self.topmost_hovered_element) && !self.topmost_hovered_element.deactivated) {
				if self.topmost_hovered_element.is_mouse_hovered == false {
					self.topmost_hovered_element.is_mouse_hovered = true;
					self.topmost_hovered_element._dispatchEvent(LUI_EV_MOUSE_ENTER);
				}
				
				// Handle on mouse pressed
				if (mouse_check_button_pressed(mb_left)) {
					self.topmost_hovered_element.is_pressed = true;
					self.topmost_hovered_element._dispatchEvent(LUI_EV_MOUSE_LEFT_PRESSED);
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
						self.topmost_hovered_element._dispatchEvent(LUI_EV_DRAG_START);
					}
				}
				
				// Handle on mouse left
				if (mouse_check_button(mb_left)) {
					// Call LUI_EV_MOUSE_LEFT event
					self.topmost_hovered_element._dispatchEvent(LUI_EV_MOUSE_LEFT);
					// Call LUI_EV_DRAGGING event
					if (self.topmost_hovered_element.can_drag && !is_undefined(self.dragging_element)) {
						var _new_x = _mouse_x - self.topmost_hovered_element.drag_offset_x;
						var _new_y = _mouse_y - self.topmost_hovered_element.drag_offset_y;
						if self.prev_mouse_x != _mouse_x || self.prev_mouse_y != _mouse_y {
							self.topmost_hovered_element._dispatchEvent(LUI_EV_DRAGGING, { new_x : _new_x, new_y : _new_y, mouse_x : _mouse_x, mouse_y : _mouse_y });
						}
						self.prev_mouse_x = _mouse_x;
						self.prev_mouse_y = _mouse_y;
					}
				}
				
				// Handle on mouse released
				if (mouse_check_button_released(mb_left)) {
					self.topmost_hovered_element._dispatchEvent(LUI_EV_MOUSE_LEFT_RELEASED);
					if (self.topmost_hovered_element.is_pressed) {
                        self.topmost_hovered_element._dispatchEvent(LUI_EV_CLICK);
                    }
					self.topmost_hovered_element.is_pressed = false;
					// Clear dragging
					if !is_undefined(self.dragging_element) {
						self.dragging_element.is_dragging = false;
						self.dragging_element._dispatchEvent(LUI_EV_DRAG_END);
						self.dragging_element = undefined;
					}
					// Remove focus from element if clicking outside
					if !is_undefined(self.element_in_focus) && self.element_in_focus != self.topmost_hovered_element {
						self.element_in_focus.removeFocus();
						self.element_in_focus = undefined;
					}
				}
				if (mouse_wheel_down() || mouse_wheel_up()) {
					self.topmost_hovered_element._dispatchEvent(LUI_EV_MOUSE_WHEEL);
				}
			} else {
				// Remove focus from element
				if !is_undefined(self.element_in_focus) {
					if (mouse_check_button_pressed(mb_left) || mouse_check_button_released(mb_left)) {
						self.element_in_focus.removeFocus();
						self.element_in_focus.is_pressed = false;
						self.element_in_focus = undefined;
						self.dragging_element = undefined;
					}
				}
			}
		} else {
			// Clear dragging element if mouse is outside UI
			self.dragging_element = undefined;
			// Reset is_pressed state
			if !is_undefined(self.topmost_hovered_element) {
                self.topmost_hovered_element.is_pressed = false;
            }
		}
		
		// Keyboard events
		if self.visible && !self.deactivated && !is_undefined(self.element_in_focus) {
			if keyboard_check(vk_anykey) {
				self.element_in_focus._dispatchEvent(LUI_EV_KEYBOARD_INPUT);
			}
			if keyboard_check_released(vk_anykey) {
				self.element_in_focus._dispatchEvent(LUI_EV_KEYBOARD_RELEASE);
			}
			if keyboard_check_pressed(vk_escape) { //???//
				self.element_in_focus.removeFocus();
				self.element_in_focus = undefined;
			}
		}
		
		// Update animations
	    if (array_length(self.active_animations) > 0) {
	        for (var i = array_length(self.active_animations) - 1; i >= 0; --i) {
	            var _tween = self.active_animations[i];
	            _tween.target.updateMainUiSurface();
				// If update return false, animate end
	            if (!_tween.update(DT)) {
	                array_delete(self.active_animations, i, 1);
	            }
	        }
	        // Redraw surface on active animations
	        //if (array_length(self.active_animations) > 0) {
	            //self.updateMainUiSurface();
	        //}
	    }
		
		// Update debug mode states
		if self.current_debug_mode != global.lui_debug_mode {
			self.updateMainUiSurface();
			self.current_debug_mode = global.lui_debug_mode;
		}
		
		// Update layout and all flex data
		if self.needs_update_flex {
			self.needs_update_flex = false;
			self._calculateLayout();
			self._updateFlex(self.flex_node);
		}
		
		// Update list of elements to update flex
		if array_length(self.elements_to_update_flex) > 0 {
			self._calculateLayout();
			while (array_length(self.elements_to_update_flex) > 0) {
				var _e = array_pop(self.elements_to_update_flex);
				if is_undefined(_e) continue;
				_e._updateFlex(_e.flex_node);
			}
		}
	}
	
	// RENDER
	self.base_render = method(self, render);
	self.render = function() {
		 
		var _prev_alpha = draw_get_alpha();
		if LUI_FORCE_ALPHA_1 { draw_set_alpha(1); }
		
		// Pre draw events
		for (var i = 0, n = array_length(self.pre_draw_list); i < n; ++i) {
			var _element = self.pre_draw_list[i];
			if is_method(_element.preDraw) _element.preDraw();
		}
		
		// >> Surface render logic start
		
		// First frame all screen redraw
		var _is_first_draw = !surface_exists(self.ui_screen_surface);
		if (_is_first_draw) {
			self.ui_screen_surface = surface_create(self.width, self.height);
			self._addRedrawRect(0, 0, self.width, self.height);
		}
		
		// Redraw all screen on resizing
		if surface_get_width(self.ui_screen_surface) != self.width || surface_get_height(self.ui_screen_surface) != self.height {
			surface_resize(self.ui_screen_surface, self.width, self.height);
			self._addRedrawRect(0, 0, self.width, self.height);
		}
		
		// Dirty rectangles redraw logic
		if (array_length(self.rectangles_to_redraw) > 0) {
			surface_set_target(self.ui_screen_surface);
			
			// Save original gpu scissors
			var _original_scissor = gpu_get_scissor();
			
			// Iterate over all “dirty” rectangles
			for (var i = 0; i < array_length(self.rectangles_to_redraw); i++) {
				var _rect = self.rectangles_to_redraw[i];
				
				// 1. Set scissors
				gpu_set_scissor(floor(_rect.x1), floor(_rect.y1), ceil(_rect.x2 - _rect.x1), ceil(_rect.y2 - _rect.y1));
				
				// 2. Clean up this area
				var _prev_bm = gpu_get_blendmode();
				gpu_set_blendmode_ext(bm_zero, bm_zero);
				draw_rectangle(_rect.x1, _rect.y1, _rect.x2, _rect.y2, false);
				gpu_set_blendmode(_prev_bm);
				
				// 3. Find all elements that intersect with this area
				var _elements_to_draw = self._getElementsInRect(_rect);
				
				// 4. We sort them by depth (z) to maintain the rendering order.
				array_sort(_elements_to_draw, function(a, b) { return _compareDepthArrays(a.depth_array, b.depth_array); });
				
				// 5. Drawing each element
				gpu_set_blendequation_sepalpha(bm_eq_add, bm_eq_max);
				for (var j = 0; j < array_length(_elements_to_draw); j++) {
					var _element = _elements_to_draw[j];
					if (_element.visible && _element.is_visible_in_region && !_element.is_destroyed) {
						
						// 1. Calculating the area for rendering
						var _final_scissor_x = floor(_rect.x1);
						var _final_scissor_y = floor(_rect.y1);
						var _final_scissor_w = ceil(_rect.x2 - _rect.x1);
						var _final_scissor_h = ceil(_rect.y2 - _rect.y1);
						
						// 2. Going up the ancestral hierarchy
						var _ancestor = _element.parent;
						while (!is_undefined(_ancestor)) {
							// 3. If an ancestor requires content to be cut off
							if (_ancestor.draw_content_in_cutted_region) {
								// Calculating the ancestor's cutoff region
								var _ancestor_x1 = _ancestor.x + _ancestor.style.render_region_offset.left;
								var _ancestor_y1 = _ancestor.y + _ancestor.style.render_region_offset.top;
								var _ancestor_x2 = _ancestor.x + _ancestor.width - _ancestor.style.render_region_offset.right;
								var _ancestor_y2 = _ancestor.y + _ancestor.height - _ancestor.style.render_region_offset.bottom;
								
								// 4. Find the intersection of the current clipping region and the ancestor region.
								var _new_x1 = max(_final_scissor_x, _ancestor_x1);
								var _new_y1 = max(_final_scissor_y, _ancestor_y1);
								var _new_x2 = min(_final_scissor_x + _final_scissor_w, _ancestor_x2);
								var _new_y2 = min(_final_scissor_y + _final_scissor_h, _ancestor_y2);
								
								// 5. Updating the final cutoff area
								_final_scissor_x = _new_x1;
								_final_scissor_y = _new_y1;
								_final_scissor_w = max(0, _new_x2 - _new_x1);
								_final_scissor_h = max(0, _new_y2 - _new_y1);
							}
							_ancestor = _ancestor.parent;
						}
						
						// 6. Apply the final calculated cutoff region
						gpu_set_scissor(
							floor(_final_scissor_x), 
							floor(_final_scissor_y), 
							ceil(_final_scissor_w), 
							ceil(_final_scissor_h)
						);
						
						// 7. Draw element
						if is_method(_element.draw) {
							_element.draw();
						}
					}
				}
				gpu_set_blendequation(bm_eq_add);
			}
			
			// Restoring gpu scissors
			gpu_set_scissor(_original_scissor.x, _original_scissor.y, _original_scissor.w, _original_scissor.h);
			
			surface_reset_target();
			
			// Clear the rects list after rendering
			if global.lui_debug_mode == 0 {
				self.rectangles_to_redraw = [];
			}
			
			// << Surface render logic end
		}
		
		// Draw all to screen
		if self.visible {
			// Draw main ui surface
			draw_surface_ext(self.ui_screen_surface, self.x, self.y, 1, 1, 0, c_white, LUI_FORCE_ALPHA_1 ? 1 : _prev_alpha);
			
			// Draw debug rectangles of elements
			if global.lui_debug_mode != 0 {
				for (var i = 0, n = array_length(self.content); i < n; i++) {
					//Get element
					var _element = self.content[i];
					// Restriction
					if !_element.is_visible_in_region || !_element.visible || _element.is_destroyed continue;
					// Draw debug
					if !_element.visible || !_element.is_visible_in_region continue;
					_element._renderDebug(_element.x, _element.y, true);
				}
			}
			
			// Draw debug rects
			if global.lui_debug_mode > 0 {
				for (var i = 0; i < array_length(self.rectangles_to_redraw); i++) {
					var _rect = self.rectangles_to_redraw[i];
					draw_set_color(c_red);
					draw_set_alpha(0.5);
					draw_rectangle(floor(_rect.x1), floor(_rect.y1), ceil(_rect.x2), ceil(_rect.y2), false);
				}
				self.rectangles_to_redraw = [];
			}
			
			// Draw other stuff
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
	
	// PRIVATE
	
	///@desc Returns topmost element on UI
	///@ignore
	static _getTopmostElement = function(_mouse_x, _mouse_y) {
	    var _key = string(floor(_mouse_x / LUI_GRID_SIZE)) + "_" + string(floor(_mouse_y / LUI_GRID_SIZE));
	    var _array = self.main_ui._screen_grid[$ _key];
		
	    if (is_undefined(_array) || array_length(_array) == 0) {
	        return undefined;
	    }
		
	    // Filter elements under cursor
	    var _filtered = array_filter(_array, function(_elm, _ind) {
	        return _elm.visible && !_elm.ignore_mouse && _elm.isMouseHoveredExc() && _elm.isMouseHoveredParents();
	    });
		
	    if (array_length(_filtered) == 0) {
	        return undefined;
	    }
		
	    // Sort by depth_array
	    array_sort(_filtered, function(elm1, elm2) {
	        return _compareDepthArrays(elm2.depth_array, elm1.depth_array);
	    });
		
		// Return top front element
	    return _filtered[0];
	}
	
	///@desc Adds a rectangle to the list of areas needing a redraw. Merges overlapping rectangles.
	///@arg {real} _x1
	///@arg {real} _y1
	///@arg {real} _x2
	///@arg {real} _y2
	///@ignore
	static _addRedrawRect = function(_x1, _y1, _x2, _y2) {
	    // Normilize coords
	    var x1 = min(_x1, _x2);
	    var y1 = min(_y1, _y2);
	    var x2 = max(_x1, _x2);
	    var y2 = max(_y1, _y2);
	
	    var _new_rect = { x1: x1, y1: y1, x2: x2, y2: y2 };
	    var _rects = self.rectangles_to_redraw;
	
	    // If list is empty add new
	    if (array_length(_rects) == 0) {
	        array_push(_rects, _new_rect);
	        return self;
	    }
	
	    // Array for remove rects
	    var _to_remove = [];
	
	    // Check all rects and merge
	    for (var i = 0; i < array_length(_rects); i++) {
	        var _existing = _rects[i];
	
	        // Check
	        if (_new_rect.x1 <= _existing.x2 + 1 && 
	            _new_rect.x2 >= _existing.x1 - 1 &&
	            _new_rect.y1 <= _existing.y2 + 1 && 
	            _new_rect.y2 >= _existing.y1 - 1) {
	            
	            // Merge
	            _new_rect.x1 = min(_new_rect.x1, _existing.x1);
	            _new_rect.y1 = min(_new_rect.y1, _existing.y1);
	            _new_rect.x2 = max(_new_rect.x2, _existing.x2);
	            _new_rect.y2 = max(_new_rect.y2, _existing.y2);
	
	            // Mark to remove old rect
	            array_push(_to_remove, i);
	        }
	    }
	
	    // Delete old rects
	    for (var j = array_length(_to_remove) - 1; j >= 0; j--) {
	        array_delete(_rects, _to_remove[j], 1);
	    }
	
	    // Add new merged rect
	    array_push(_rects, _new_rect);
	
	    return self;
	}
	
	///@desc Returns all elements intersecting with a given rectangle
	///@ignore
	static _getElementsInRect = function(_rect) {
		var _elements_in_rect = [];
		var _checked_elements = {};
		
		var _x_start = floor(_rect.x1 / LUI_GRID_SIZE);
		var _y_start = floor(_rect.y1 / LUI_GRID_SIZE);
		var _x_end = floor(_rect.x2 / LUI_GRID_SIZE);
		var _y_end = floor(_rect.y2 / LUI_GRID_SIZE);
		
		for (var _x = _x_start; _x <= _x_end; ++_x) {
			for (var _y = _y_start; _y <= _y_end; ++_y) {
				var _key = string(_x) + "_" + string(_y);
				if (variable_struct_exists(self._screen_grid, _key)) {
					var _cell_array = self._screen_grid[$ _key];
					for (var i = 0; i < array_length(_cell_array); i++) {
						var _elm = _cell_array[i];
						// Check that the element has not yet been processed and actually intersects
						if (!variable_struct_exists(_checked_elements, _elm.element_id) &&
							_elm.x < _rect.x2 && _elm.x + _elm.width > _rect.x1 &&
							_elm.y < _rect.y2 && _elm.y + _elm.height > _rect.y1) {
							
							array_push(_elements_in_rect, _elm);
							_checked_elements[$ string(_elm.element_id)] = true;
						}
					}
				}
			}
		}
		return _elements_in_rect;
	}
	
	///@desc Add element to list for update flex node
	///@ignore
	static _addFlexUpdate = function(_element) {
		array_push(self.elements_to_update_flex, _element);
		self.elements_to_update_flex = array_unique(self.elements_to_update_flex);
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
				var _array = self._screen_grid[$ _key];
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
	
	// Cleanup
	self.addEvent(LUI_EV_DESTROY, function(_e) {
		if surface_exists(_e.ui_screen_surface) {
			surface_free(_e.ui_screen_surface);
		}
		_e.pre_draw_list = -1;
		_e.element_in_focus = undefined;
		_e.dragging_e = undefined;
		_e.active_animations = -1;
		delete _e._screen_grid;
		delete _e.element_names;
		global.lui_element_count = 0;
		global.lui_id_count = 0;
		global.lui_max_z = 0;
	});
}