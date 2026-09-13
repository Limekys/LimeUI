///@desc Main UI container which would control and render your UI.
function LuiMain() : LuiBase() constructor {
	
	self.is_initialized = true;
	self.ignore_mouse = true;
	
	// Main variables
	self.name = "_LUI_MAIN_UI";
	self.width = display_get_gui_width();
	self.height = display_get_gui_height();
	self.is_visible_in_region = true;
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
	            if _tween.target.is_destroyed continue;
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
	
	    if self.visible {
			
	        // Force initial layout if it was not calculated yet
	        if (self.needs_update_flex) {
	            self.needs_update_flex = false;
	            self._calculateLayout();
	            self._updateFlex(self.flex_node);
	        }
	        
	        // Root container is always visible for command collection
	        self.is_visible_in_region = true;
	        
	        // 1. Update cache surfaces for elements that need it (Bottom-Up)
	        for (var i = 0; i < array_length(self.content); i++) {
	            self._updateCachedSurfacesRecursive(self.content[i]);
	        }
	
	        // 2. Collect draw commands (Command Buffer)
	        var _commands = [];
	        var _identity_matrix = matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1);
	        for (var i = 0; i < array_length(self.content); i++) {
	            self._collectDrawCommands(self.content[i], _commands, _identity_matrix, 1.0);
	        }
	
	        // 3. Sort commands by depth
	        array_sort(_commands, function(a, b) { 
	            return _compareDepthArrays(a.depth_array, b.depth_array); 
	        });
	        
	        // 4. Execute draw commands
	        var _gui_w = display_get_gui_width();
	        var _gui_h = display_get_gui_height();
	        
	        // Set proper blend equation for alpha compositing
	        gpu_set_blendequation_sepalpha(bm_eq_add, bm_eq_max);
	        
	        for (var i = 0; i < array_length(_commands); i++) {
	            var _cmd = _commands[i];
	            
	            // Save current matrix
	            var _prev_matrix = matrix_get(matrix_world);
	            
	            // Apply element's visual matrix (includes parent hierarchy)
	            matrix_set(matrix_world, _cmd.matrix);
	            
	            // Calculate scissor by walking up the parent hierarchy
	            var _final_scissor_x = 0;
	            var _final_scissor_y = 0;
	            var _final_scissor_w = _gui_w;
	            var _final_scissor_h = _gui_h;
	            
	            var _ancestor = _cmd.element.parent;
	            while (!is_undefined(_ancestor)) {
	                if (_ancestor.draw_content_in_cutted_region) {
	                    var _style = _ancestor.getStyle();
	                    var _ancestor_x1 = _ancestor.x + _style.render_region_offset.left;
	                    var _ancestor_y1 = _ancestor.y + _style.render_region_offset.top;
	                    var _ancestor_x2 = _ancestor.x + _ancestor.width - _style.render_region_offset.right;
	                    var _ancestor_y2 = _ancestor.y + _ancestor.height - _style.render_region_offset.bottom;
	                    
	                    var _new_x1 = max(_final_scissor_x, _ancestor_x1);
	                    var _new_y1 = max(_final_scissor_y, _ancestor_y1);
	                    var _new_x2 = min(_final_scissor_x + _final_scissor_w, _ancestor_x2);
	                    var _new_y2 = min(_final_scissor_y + _final_scissor_h, _ancestor_y2);
	                    
	                    _final_scissor_x = _new_x1;
	                    _final_scissor_y = _new_y1;
	                    _final_scissor_w = max(0, _new_x2 - _new_x1);
	                    _final_scissor_h = max(0, _new_y2 - _new_y1);
	                }
	                _ancestor = _ancestor.parent;
	            }
	            
	            // Apply scissor
	            gpu_set_scissor(floor(_final_scissor_x), floor(_final_scissor_y), ceil(_final_scissor_w), ceil(_final_scissor_h));
	            
	            // Apply accumulated visual alpha
	            var _cmd_prev_alpha = draw_get_alpha();
	            draw_set_alpha(_cmd.alpha);
	            
	            if (_cmd.type == "surface") {
	                // Draw cached surface as a single sprite at element's position
	                draw_surface_ext(_cmd.surface, _cmd.element.x, _cmd.element.y, 1, 1, 0, c_white, _cmd.alpha);
	            } else if (_cmd.type == "draw_func") {
	                // Draw element normally
	                if (is_method(_cmd.element.draw)) {
	                    _cmd.element.draw();
	                }
	            }
	            
	            // Restore alpha and matrix
	            draw_set_alpha(_cmd_prev_alpha);
	            matrix_set(matrix_world, _prev_matrix);
	        }
	        
	        // Reset blend equation
	        gpu_set_blendequation(bm_eq_add);
	        
	        // Reset scissor
	        gpu_set_scissor(0, 0, _gui_w, _gui_h);
	
	        // Draw debug rectangles of elements
	        if global.lui_debug_mode != 0 {
	            matrix_set(matrix_world, _identity_matrix); // Reset matrix for debug drawing
	            for (var i = 0, n = array_length(self.content); i < n; i++) {
	                var _element = self.content[i];
	                if !_element.is_visible_in_region || !_element.visible || _element.is_destroyed continue;
	                _element._renderDebug(_element.x, _element.y, true);
	            }
	        }
	        
	        // Draw other stuff (focused element, etc)
	        if self.display_focused_element {
	            if !is_undefined(self.element_in_focus) {
	                var _elm = self.element_in_focus;
	                draw_rectangle_color(_elm.x - 1, _elm.y - 1, _elm.x + _elm.width, _elm.y + _elm.height, c_white, c_white, c_white, c_white, true);
	            }
	        }
	    }
	    
	    // Reset matrix for tooltips and overlays
	    matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1));
	    
	    // Get topmost element
	    var _element = self.topmost_hovered_element;
	    // Draw tooltip text
	    if !is_undefined(_element) {
	        if _element.tooltip != "" {
	            var _style = self.getStyle();
	            var _padding = _style.padding; 
	            var _padding_text = _style.padding; 
	            draw_set_font(_style.font_default);
	            var _width = string_width(_element.tooltip) + _padding_text*2;
	            var _height = string_height(_element.tooltip) + _padding_text*2;
	            var _mouse_x = clamp(device_mouse_x_to_gui(0) + 16, _padding, self.width - _width - _padding);
	            var _mouse_y = clamp(device_mouse_y_to_gui(0) + 16, _padding, self.height - _height - _padding);
	            
	            if !is_undefined(_style.sprite_tooltip) {
	                draw_sprite_stretched_ext(_style.sprite_tooltip, 0, _mouse_x, _mouse_y, _width, _height, _style.color_primary, LUI_FORCE_ALPHA_1 ? 1 : _prev_alpha);
	            }
	            if !is_undefined(_style.sprite_tooltip_border) {
	                draw_sprite_stretched_ext(_style.sprite_tooltip_border, 0, _mouse_x, _mouse_y, _width, _height, _style.color_border, LUI_FORCE_ALPHA_1 ? 1 : _prev_alpha);
	            }
	            draw_set_color(_style.color_text);
	            draw_set_halign(fa_left);
	            draw_set_valign(fa_top);
	            draw_text(_mouse_x + _padding_text, _mouse_y + _padding_text, _element.tooltip);
	        }
	    }
	
	    if global.lui_debug_render_grid {
	        self._drawScreenGrid();
	    }
	
	    if global.lui_debug_mode != 0 && !is_undefined(_element) {
	        var _mouse_x = device_mouse_x_to_gui(0) + 32;
	        var _mouse_y = device_mouse_y_to_gui(0) + 32;
	        _element._renderDebugInfo(_mouse_x, _mouse_y);
	    }
	    
	    if !LUI_FORCE_ALPHA_1 { draw_set_alpha(_prev_alpha); }
	}
	
	// DIALOGS
	
	///@desc Show a modal message dialog (convenience wrapper for LuiMessage widget)
	///@arg {Struct} [_params] Parameters: text, button_text, width, height
	static alert = function(_params = {}) {
		var _message = new LuiMessage(_params);
		self.addContent(_message);
		return _message;
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
	
	///@desc Recursively draws an element and its descendants into the currently targeted surface
	///@ignore
	static _drawElementTreeToSurface = function(_elem, _parent_matrix) {
	    if (!_elem.visible || _elem.is_destroyed) return;
	    
	    // Build this element's visual matrix
	    var _visual_matrix = _elem._buildVisualMatrix();
	    
	    // Combine with parent matrix to get absolute transform within the surface
	    var _current_matrix = matrix_multiply(_visual_matrix, _parent_matrix);
	    
	    // Draw this element's own content (background, borders, text, etc.)
	    if (is_method(_elem.draw)) {
	        matrix_set(matrix_world, _current_matrix);
	        var _prev_alpha = draw_get_alpha();
	        draw_set_alpha(_elem.visual_alpha);
	        _elem.draw();
	        draw_set_alpha(_prev_alpha);
	    }
	    
	    // Recursively draw all children
	    for (var i = 0; i < array_length(_elem.content); i++) {
	        self._drawElementTreeToSurface(_elem.content[i], _current_matrix);
	    }
	}
	
	///@desc Renders the element and all its descendants into its cached surface
	///@ignore
	static _updateCachedSurface = function(_element) {
	    if (!_element.cache_as_surface) return;
	    
	    var _w = max(1, ceil(_element.width));
	    var _h = max(1, ceil(_element.height));
	    
	    // Recreate surface if size changed
	    if (surface_exists(_element._cached_surface)) {
	        if (surface_get_width(_element._cached_surface) != _w || 
	            surface_get_height(_element._cached_surface) != _h) {
	            surface_resize(_element._cached_surface, _w, _h);
	            _element._is_cache_dirty = true;
	        }
	    } else {
	        _element._cached_surface = surface_create(_w, _h);
	        _element._is_cache_dirty = true;
	    }
	    
	    // Skip if cache is still valid
	    if (!_element._is_cache_dirty) return;
	    
	    // Render into the cached surface
	    surface_set_target(_element._cached_surface);
	    draw_clear_alpha(c_black, 0);
	    
	    var _prev_matrix = matrix_get(matrix_world);
	    
	    // Offset matrix so element's top-left corner becomes (0, 0) on the surface
	    var _offset_matrix = matrix_build(-_element.x, -_element.y, 0, 0, 0, 0, 1, 1, 1);
	    
	    // Set proper blend equation for alpha compositing inside the surface
	    gpu_set_blendequation_sepalpha(bm_eq_add, bm_eq_max);
	    
	   // Draw the panel's own background/borders first (using offset matrix)
		// IMPORTANT: Always draw with alpha = 1. The element's visual_alpha is applied
		// later when the cached surface is drawn to the screen via draw_surface_ext.
		if (is_method(_element.draw)) {
		    matrix_set(matrix_world, _offset_matrix);
		    var _prev_alpha = draw_get_alpha();
		    draw_set_alpha(1);
		    _element.draw();
		    draw_set_alpha(_prev_alpha);
		}
	    
	    // Then draw all children recursively using the class method
	    for (var i = 0; i < array_length(_element.content); i++) {
	        self._drawElementTreeToSurface(_element.content[i], _offset_matrix);
	    }
	    
	    // Reset blend equation
	    gpu_set_blendequation(bm_eq_add);
	    
	    matrix_set(matrix_world, _prev_matrix);
	    surface_reset_target();
	    
	    _element._is_cache_dirty = false;
	}
	
	///@desc Recursively updates all cached surfaces (bottom-up)
	///@ignore
	static _updateCachedSurfacesRecursive = function(_element) {
	    if (!_element.visible || _element.is_destroyed) return;
	    
	    // Update children first (bottom-up)
	    for (var i = 0; i < array_length(_element.content); i++) {
	        self._updateCachedSurfacesRecursive(_element.content[i]);
	    }
	    
	    // Then update this element's cache
	    if (_element.cache_as_surface) {
	        self._updateCachedSurface(_element);
	    }
	}
	
	///@desc Recursively collects draw commands into the command buffer
	///@ignore
	static _collectDrawCommands = function(_element, _commands, _parent_matrix, _parent_alpha) {
	    if (!_element.visible || _element.is_destroyed) return;
	    
	    // Calculate visual matrix for this element
	    var _visual_matrix = _element._buildVisualMatrix();
	    
	    // Combine with parent matrix (parent transforms affect children)
	    var _current_matrix = matrix_multiply(_visual_matrix, _parent_matrix);
	    
	    // Accumulate alpha from parent
	    var _current_alpha = _parent_alpha * _element.visual_alpha;
	    
	    // If element is cached as surface, draw it as a single texture
	    if (_element.cache_as_surface && surface_exists(_element._cached_surface)) {
	        array_push(_commands, {
	            type: "surface",
	            element: _element,
	            surface: _element._cached_surface,
	            matrix: _current_matrix,
	            alpha: _current_alpha,
	            depth_array: _element.depth_array,
	        });
	        // Do NOT recurse into children - they are baked into the surface
	        return;
	    }
	    
	    // Normal element - draw its own draw method
	    if (is_method(_element.draw)) {
	        array_push(_commands, {
	            type: "draw_func",
	            element: _element,
	            matrix: _current_matrix,
	            alpha: _current_alpha,
	            depth_array: _element.depth_array,
	        });
	    }
	    
	    // Recurse into children with current matrix and alpha
	    for (var i = 0; i < array_length(_element.content); i++) {
	        self._collectDrawCommands(_element.content[i], _commands, _current_matrix, _current_alpha);
	    }
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