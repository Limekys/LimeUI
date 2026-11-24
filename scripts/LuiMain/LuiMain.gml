///@desc Main UI container which would control and render your UI.
function LuiMain() : LuiBase() constructor {
	// STATE AND INITIALIZATION

	self.is_initialized = true;
	self.ignore_mouse = true;

	self.name = "_LUI_MAIN_UI";
	self.width = display_get_gui_width();
	self.height = display_get_gui_height();
	self.is_visible_in_region = true;
	self.pre_draw_list = [];
	self.element_names = {};
	self._elements_by_tag = {};
	self.main_ui = self;
	self.element_in_focus = undefined;
	self.topmost_hovered_element = undefined;
	self.dragging_element = undefined;
	self.display_focused_element = false;
	self._keyboard_navigation_active = false;
	self._keyboard_edit_target = undefined;
	self._keyboard_shortcuts = [];
	self._shortcut_elements = [];
	self._focus_frame_bounds = undefined;
	self.waiting_for_keyboard_input = false;
	self.needs_update_flex = true;
	self.current_debug_mode = 0;
	self.active_animations = [];
	self.prev_mouse_x = -1;
	self.prev_mouse_y = -1;
	self._screen_grid = [];
	self._scroll_updates = [];
	self._layout_revision = 0;
	self._baking = false;
	self._backdrop_surface = -1;
	self._backdrop_blur_surface = -1;
	self._modal_stack = [];
	self._open_popups = [];
	self._right_pressed_element = undefined;
	self._cache_bakes = 0;
	self._clip_stack = [];     // Reusable clip rectangles, one per clipping depth
	self._clip_depth = -1;

	// Init Flex size
	flexpanel_node_style_set_width(self.flex_node, self.width, flexpanel_unit.point);
	flexpanel_node_style_set_height(self.flex_node, self.height, flexpanel_unit.point);

	// LAYOUT AND SCREEN GRID

	///@ignore
	static _recalculateScreenGrid = function() {
		var _cols = ceil(display_get_gui_width() / LUI_GRID_SIZE);
		var _rows = ceil(display_get_gui_height() / LUI_GRID_SIZE);
		for (var _x = 0; _x < _cols; ++_x) {
			if _x >= array_length(self._screen_grid) {
				array_push(self._screen_grid, []);
			}
			var _col = self._screen_grid[_x];
			for (var _y = array_length(_col); _y < _rows; ++_y) {
				array_push(_col, []);
			}
		}
		return self;
	}

	///@desc Calculates and applies each requested Flex layout from the root.
	///@ignore
	static _flushFlexLayout = function() {
		// Allow one follow-up pass for requests raised by layout callbacks.
		for (var _pass = 0; _pass < 2 && self.needs_update_flex; _pass++) {
			self.needs_update_flex = false;
			self._calculateLayout();
			self._updateFlex();
		}
	}

	self._recalculateScreenGrid();

	self.addEvent(LUI_EV_SIZE_UPDATE, function(_e) {
		_e._recalculateScreenGrid();
	});

	_luiInitEaseFunctions();

	// PUBLIC API

	///@desc Registers or replaces a global shortcut for a key press.
	///@arg {Real} _key GameMaker keyboard key code
	///@arg {Function} _callback Callback receiving this LuiMain instance
	///@return {Struct} This LuiMain instance
	static bindShortcut = function(_key, _callback) {
		self.unbindShortcut(_key);
		array_push(self._keyboard_shortcuts, {key: _key, callback: _callback});
		return self;
	}

	///@desc Removes the shortcut registered for a key.
	///@arg {Real} _key GameMaker keyboard key code
	///@return {Struct} This LuiMain instance
	static unbindShortcut = function(_key) {
		for (var i = 0, n = array_length(self._keyboard_shortcuts); i < n; i++) {
			if self._keyboard_shortcuts[i].key == _key {
				array_delete(self._keyboard_shortcuts, i, 1);
				return self;
			}
		}
		return self;
	}

	///@desc Get element by name
	///@arg {String} _name Element name
	///@arg {Bool} [_warn] Log a warning when the name is absent
	///@return {Struct|Real} Element or -1 when absent
	static getElement = function(_name, _warn = false) {
		if variable_struct_exists(self.element_names, _name) {
			return variable_struct_get(self.element_names, _name);
		}
		if _warn {
			_luiPrintWarning($"Can't find element {_name}!");
		}
		return -1;
	}

	///@desc Returns an independent array of elements with the given case-sensitive tag.
	///@arg {String} _tag Element tag
	///@return {Array} Matching elements in registration order
	static getTag = function(_tag) {
		var _elements = self._elements_by_tag[$ _tag];
		if is_undefined(_elements) return [];
		var _count = array_length(_elements);
		var _result = array_create(_count);
		array_copy(_result, 0, _elements, 0, _count);
		return _result;
	}

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
		return self.visible && !self.deactivated
			&& (self.waiting_for_keyboard_input || (self._keyboard_navigation_active && !is_undefined(self.element_in_focus))
				|| !is_undefined(self._activeModal()));
	}

	///@desc Returns whether a widget can handle input with the current modal open.
	///@arg {Struct} _element Widget requesting input
	static isInputAllowed = function(_element) {
		if self.is_destroyed || !self.visible || self.deactivated || _element.is_destroyed || !_element.visible || _element.deactivated return false;
		var _modal = self._activeModal();
		return is_undefined(_modal) || self._isInModal(_element, _modal);
	}

	///@desc Create animation for any variables of target element
	static animate = function(target_element, property, end_value, duration, easing_func = global.Ease.OutQuad) {

		// Delete previous if found to exlude animation conflicts
		for (var i = array_length(self.active_animations) - 1; i >= 0; --i) {
			var _existing_tween = self.active_animations[i];
			if _existing_tween.target == target_element && _existing_tween.property == property {
				array_delete(self.active_animations, i, 1);
				break;
			}
		}

		// Create new tween
		var _tween = new LuiTween(target_element, property, end_value, duration, easing_func);
		array_push(self.active_animations, _tween);

		return _tween;
	}

	///@desc Shows a modal dialog with backdrop blur by default. Set backdrop_blur to 0 to disable it.
	///@arg {Struct} [_params] Message options: text, content, button_text, width, height, backdrop_blur
	///@return {Struct} The opened LuiMessage
	static alert = function(_params = {}) {
		var _message = new LuiMessage(_params, LUI_DEFAULT_ALERT_BLUR);
		self.addContent(_message);
		return _message;
	}

	///@desc Controls the focus rectangle. Arrow keys show it and a mouse press hides it.
	///@arg {bool} _display
	static displayFocusedElement = function(_display) {
		self.display_focused_element = _display;
		if !_display {
			self._focus_frame_bounds = undefined;
		}
	}

	// FRAME UPDATE

	self.base_update = method(self, update);
	///@arg {Struct} [_metrics] Optional output for tree and layout CPU timings in microseconds
	self.update = function(_metrics = undefined) {
		var _measure = is_struct(_metrics);
		var _tree_start = _measure ? get_timer() : 0;

		//var _t = get_timer();
		// Update all elements
		self.base_update();
		if _measure {
			_metrics.tree_us = get_timer() - _tree_start;
		}
		self._updatePopups();
		var _mouse_pressed = mouse_check_button_pressed(mb_left) || mouse_check_button_pressed(mb_right)
			|| mouse_check_button_pressed(mb_middle);
		if _mouse_pressed {
			self._keyboard_navigation_active = false;
			self._keyboard_edit_target = undefined;
			self.displayFocusedElement(false);
		}
		//luiProf("1_base_update", _t);

		// Mouse position
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		var _left_held = mouse_check_button(mb_left);
		var _left_released = mouse_check_button_released(mb_left);
		var _inside_ui = self.visible && !self.deactivated
			&& _mouse_x >= 0 && _mouse_x < self.width && _mouse_y >= 0 && _mouse_y < self.height;
		var _drag = self.dragging_element;
		if !is_undefined(_drag) && (!self.isInputAllowed(_drag) || (!_left_held && (!_inside_ui || !_left_released))) {
			self._cancelPointerDrag();
		}

		//_t = get_timer();

		// Mouse events
		if _inside_ui {
			var _previous_hovered_element = self.topmost_hovered_element;

			// Prioritize dragging element if it exists and mouse is held
			if !is_undefined(self.dragging_element) && (_left_held || _left_released) {
				self.topmost_hovered_element = self.dragging_element;
			} else {
				self.topmost_hovered_element = self._getTopmostElement(_mouse_x, _mouse_y);
			}
			if mouse_check_button_pressed(mb_left) {
				self._closePopupsOutside(self.topmost_hovered_element);
			}
			self._updateRightPointer(_mouse_x, _mouse_y);

			// Update mouse hover state
			if !is_undefined(_previous_hovered_element) && _previous_hovered_element != self.topmost_hovered_element {
				_previous_hovered_element.is_mouse_hovered = false;
				_previous_hovered_element.is_pressed = false;
				_previous_hovered_element._dispatchEvent(LUI_EV_MOUSE_LEAVE);
			}

			if !is_undefined(self.topmost_hovered_element) && self.isInputAllowed(self.topmost_hovered_element) {
				if self.topmost_hovered_element.is_mouse_hovered == false {
					self.topmost_hovered_element.is_mouse_hovered = true;
					self.topmost_hovered_element._dispatchEvent(LUI_EV_MOUSE_ENTER);
				}

				// Handle on mouse pressed
				if !is_undefined(self.topmost_hovered_element) && mouse_check_button_pressed(mb_left) {
					var _pressed_element = self.topmost_hovered_element;
					_pressed_element.is_pressed = true;
					_pressed_element._dispatchEvent(LUI_EV_MOUSE_LEFT_PRESSED);
					self._dispatchPointer(_pressed_element, LUI_EV_POINTER_DOWN, mb_left);
					// Set focus on element
					if self.isInputAllowed(_pressed_element) && self.element_in_focus != _pressed_element {
						// Remove focus from previous element
						if !is_undefined(self.element_in_focus) {
							self.element_in_focus.removeFocus();
							self.element_in_focus = undefined;
						}
						self.element_in_focus = _pressed_element;
						_pressed_element.setFocus();
					}
					// Set dragging element
					if self.isInputAllowed(_pressed_element) && _pressed_element.can_drag {
						_pressed_element.is_dragging = true;
						_pressed_element.drag_offset_x = _mouse_x - _pressed_element.x;
						_pressed_element.drag_offset_y = _mouse_y - _pressed_element.y;
						self.dragging_element = _pressed_element;
						_pressed_element._dispatchEvent(LUI_EV_DRAG_START);
					}
				}

				// Handle on mouse left
				if !is_undefined(self.topmost_hovered_element) && self.isInputAllowed(self.topmost_hovered_element) && mouse_check_button(mb_left) {
					// Call LUI_EV_MOUSE_LEFT event
					var _held_element = self.topmost_hovered_element;
					_held_element._dispatchEvent(LUI_EV_MOUSE_LEFT);
					// Call LUI_EV_DRAGGING event
					if _held_element.can_drag && self.dragging_element == _held_element && self.isInputAllowed(_held_element) {
						var _new_x = _mouse_x - self.topmost_hovered_element.drag_offset_x;
						var _new_y = _mouse_y - self.topmost_hovered_element.drag_offset_y;
						if self.prev_mouse_x != _mouse_x || self.prev_mouse_y != _mouse_y {
							_held_element._dispatchEvent(LUI_EV_DRAGGING, { new_x : _new_x, new_y : _new_y, mouse_x : _mouse_x, mouse_y : _mouse_y });
						}
						self.prev_mouse_x = _mouse_x;
						self.prev_mouse_y = _mouse_y;
					}
				}

				// Handle on mouse released
				if !is_undefined(self.topmost_hovered_element) && self.isInputAllowed(self.topmost_hovered_element) && mouse_check_button_released(mb_left) {
					var _released_element = self.topmost_hovered_element;
					var _modal_before_release = self._activeModal();
					_released_element._dispatchEvent(LUI_EV_MOUSE_LEFT_RELEASED);
					var _click = _released_element.is_pressed && !_released_element.is_destroyed;
					if self.dragging_element == _released_element {
						_click = _click && self._getTopmostElement(_mouse_x, _mouse_y) == _released_element;
					}
					_released_element.is_pressed = false;
					// Clear dragging
					if !is_undefined(self.dragging_element) {
						self.dragging_element.is_dragging = false;
						self.dragging_element._dispatchEvent(LUI_EV_DRAG_END);
						self.dragging_element = undefined;
					}
					// Remove focus from element if clicking outside
					if self._activeModal() == _modal_before_release && !is_undefined(self.element_in_focus) && self.element_in_focus != _released_element {
						self.element_in_focus.removeFocus();
						self.element_in_focus = undefined;
					}
					if _click && self.isInputAllowed(_released_element) {
						self._dispatchPointerClick(_released_element, mb_left);
					}
				}
				var _wheel = mouse_wheel_up() - mouse_wheel_down();
				if _wheel != 0 {
					var _wheel_target = self._getTopmostElement(_mouse_x, _mouse_y);
					if !is_undefined(_wheel_target) && self.isInputAllowed(_wheel_target) {
						_wheel_target._dispatchEvent(LUI_EV_MOUSE_WHEEL);
						self._dispatchBubbledInput(_wheel_target, LUI_EV_POINTER_WHEEL, {
							target: _wheel_target,
							delta: _wheel,
							shift: keyboard_check(vk_shift),
							stop_propagation: false
						});
					}
				}
			} else {
				// Remove focus from element
				if !is_undefined(self.element_in_focus) {
					if mouse_check_button_pressed(mb_left) || mouse_check_button_released(mb_left) {
						self.element_in_focus.removeFocus();
						self.element_in_focus.is_pressed = false;
						self.element_in_focus = undefined;
						self.dragging_element = undefined;
					}
				}
			}
		} else {
			if mouse_check_button_pressed(mb_left) || mouse_check_button_pressed(mb_right) {
				self._closePopupsOutside(undefined);
			}
			if mouse_check_button_released(mb_right) {
				self._right_pressed_element = undefined;
			}
			var _hovered = self.topmost_hovered_element;
			self.topmost_hovered_element = undefined;
			if !is_undefined(_hovered) && !_hovered.is_destroyed {
				_hovered.is_mouse_hovered = false;
				if _hovered != self.dragging_element {
					_hovered.is_pressed = false;
				}
				_hovered._dispatchEvent(LUI_EV_MOUSE_LEAVE);
			}
		}

		//luiProf("2_mouse", _t);

		// Keyboard events
		var _modal = self._activeModal();
		if !_mouse_pressed && self._updateKeyboardEdit() {
			// The focused control owns the navigation keys while editing.
		} else if self.visible && !self.deactivated && keyboard_check_pressed(vk_escape) && array_length(self._open_popups) > 0 {
			var _popup = self._open_popups[array_length(self._open_popups) - 1];
			_popup.close();
		} else if self.visible && !self.deactivated && !is_undefined(_modal) && keyboard_check_pressed(vk_escape) {
			_modal.close();
		} else if !_mouse_pressed && self.visible && !self.deactivated && self._updateKeyboardNavigation() {
			// Navigation keys have already been handled.
		} else if self.visible && !self.deactivated && self._updateKeyboardShortcuts() {
			// The shortcut consumed this key press.
		} else if self.visible && !self.deactivated && !is_undefined(self.element_in_focus) && self.isInputAllowed(self.element_in_focus) {
			var _focused = self.element_in_focus;
			if keyboard_check(vk_anykey) {
				_focused._dispatchEvent(LUI_EV_KEYBOARD_INPUT);
			}
			if self.element_in_focus == _focused && self.isInputAllowed(_focused) && keyboard_check_released(vk_anykey) {
				_focused._dispatchEvent(LUI_EV_KEYBOARD_RELEASE);
			}
			if self.element_in_focus == _focused && is_undefined(self._activeModal()) && keyboard_check_pressed(vk_escape) {
				self._keyboard_navigation_active = false;
				self.displayFocusedElement(false);
				self.element_in_focus = undefined;
				_focused.removeFocus();
			}
		}

		//_t = get_timer();

		// Update animations
		if array_length(self.active_animations) > 0 {
			for (var i = array_length(self.active_animations) - 1; i >= 0; --i) {
				var _tween = self.active_animations[i];
				if _tween.target.is_destroyed {
					array_delete(self.active_animations, i, 1);
					continue;
				}
				// Transform/alpha of the element itself doesn't change its own cached content
				if string_starts_with(_tween.property, "visual_") || string_starts_with(_tween.property, "pivot_") {
					_tween.target._invalidateAncestorCaches();
				} else {
					_tween.target.updateMainUiSurface();
				}
				// If update return false, animate end
				if !_tween.update(DT) {
					array_delete(self.active_animations, i, 1);
				}
			}
		}

		//luiProf("3_anim", _t);

		// Update debug mode states
		if self.current_debug_mode != global.lui_debug_mode {
			self.updateMainUiSurface();
			self.current_debug_mode = global.lui_debug_mode;
		}

		//_t = get_timer();

		var _layout_start = _measure ? get_timer() : 0;

		self._flushFlexLayout();

		var _scrolled = self._scroll_updates;
		self._scroll_updates = [];
		for (var i = 0; i < array_length(_scrolled); i++) {
			var _container = _scrolled[i];
			if !_container.is_destroyed {
				_container._scroll_owner._applyPendingFocusReveal();
				_container.updateMainUiSurface();
				_container._updateFlex(true);
				_container._scroll_owner._updateScrollThumbs();
			}
		}

		if _measure {
			_metrics.layout_us = get_timer() - _layout_start;
		}
	}

	// FRAME RENDER

	///@arg {Struct} [_metrics] Optional output for CPU timings in microseconds and successful cache bakes
	self.render = function(_metrics = undefined) {
		var _measure = is_struct(_metrics);
		if _measure {
			_metrics.cache_us = 0;
			_metrics.draw_us = 0;
			_metrics.bakes = 0;
			self._cache_bakes = 0;
		}
		var _prev_alpha = draw_get_alpha();
		if LUI_FORCE_ALPHA_1 {
			draw_set_alpha(1);
		}

		// Pre draw events
		for (var i = 0, n = array_length(self.pre_draw_list); i < n; ++i) {
			var _element = self.pre_draw_list[i];
			if is_method(_element.preDraw) {
				_element.preDraw();
			}
		}

		if self.visible {

			// Force initial layout if it was not calculated yet
			if self._layout_revision == 0 {
				self._flushFlexLayout();
			}

			// Root container is always visible
			self.is_visible_in_region = true;

			var _cache_start = _measure ? get_timer() : 0;

			// 1. Update cache surfaces (bottom-up)
			for (var i = 0, n = array_length(self.content); i < n; i++) {
				self._prepareCaches(self.content[i]);
			}

			var _draw_start = _measure ? get_timer() : 0;
			if _measure {
				_metrics.cache_us = _draw_start - _cache_start;
				_metrics.bakes = self._cache_bakes;
			}

			// 2. Draw the tree directly (children are already in z order)
			var _gui_w = display_get_gui_width();
			var _gui_h = display_get_gui_height();
			var _identity_matrix = matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1);
			var _root_clip = [0, 0, _gui_w, _gui_h];

			matrix_set(matrix_world, _identity_matrix);
			gpu_set_scissor(0, 0, _gui_w, _gui_h);
			_luiBlendReset();

			var _kids = self._getDrawChildren();
			var _first = 0;
			if array_length(self._modal_stack) > 0 {
				var _layers = [];
				for (var i = 0, n = array_length(_kids); i < n; i++) {
					if !_kids[i]._is_modal {
						array_push(_layers, _kids[i]);
					}
				}
				var _modal_start = array_length(_layers);
				for (var i = 0, n = array_length(self._modal_stack); i < n; i++) {
					array_push(_layers, self._modal_stack[i].dialog);
				}
				_kids = _layers;
				_first = self._drawBackdrop(_kids, _modal_start, _identity_matrix, _root_clip);
			} else if self._backdrop_surface != -1 {
				self._freeBackdrop();
			}
			for (var i = _first, n = array_length(_kids); i < n; i++) {
				self._drawTree(_kids[i], _identity_matrix, 1, _root_clip);
			}

			draw_set_alpha(LUI_FORCE_ALPHA_1 ? 1 : _prev_alpha);
			gpu_set_scissor(0, 0, _gui_w, _gui_h);
			matrix_set(matrix_world, _identity_matrix);

			if _measure {
				_metrics.draw_us = get_timer() - _draw_start;
			}

			// Draw debug rectangles of elements
			if global.lui_debug_mode != 0 {
				for (var i = 0, n = array_length(self.content); i < n; i++) {
					var _element = self.content[i];
					if !_element.is_visible_in_region || !_element.visible || _element.is_destroyed continue;
					_element._renderDebug(_element.x, _element.y, true);
				}
			}

			if self.display_focused_element {
				self._drawFocusFrame(_identity_matrix);
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

		//luiProfFrameEnd(is_undefined(self.topmost_hovered_element) ? "-" : self.topmost_hovered_element.name);
		//
		//if keyboard_check_pressed(vk_f10) {
			//clipboard_set_text(global.lui_spike_log);
			//show_debug_message("Spike log copied");
		//}
		//if keyboard_check_pressed(vk_f9) {
			//global.lui_prof = {};
			//global.lui_spike_log = "";
		//}

		if !LUI_FORCE_ALPHA_1 {
			draw_set_alpha(_prev_alpha);
		}
	}

	// INPUT AND MODALS

	///@ignore
	static _activateElement = function(_element, _event = LUI_EV_CLICK) {
		if self.isInputAllowed(_element) {
			_element._dispatchEvent(_event);
		}
	}

	// KEYBOARD NAVIGATION

	///@ignore
	static _updateKeyboardShortcuts = function() {
		var _focused = self.element_in_focus;
		if !is_undefined(_focused) && self.isInputAllowed(_focused) && is_instanceof(_focused, LuiInput) return false;
		var _root = self._keyboardFocusRoot();
		var _element = self._findShortcutElement(_root);
		if !is_undefined(_element) {
			self._activateElement(_element);
			return true;
		}
		if _root != self || array_length(self._open_popups) > 0 return false;
		if !is_undefined(_focused) && self.isInputAllowed(_focused) {
			if keyboard_check_pressed(vk_escape) {
				var _window = _focused;
				while !is_undefined(_window) {
					if is_instanceof(_window, LuiWindow) && self.isInputAllowed(_window) {
						_window.closeWindow();
						return true;
					}
					_window = _window.parent;
				}
			}
		}
		for (var i = 0, n = array_length(self._keyboard_shortcuts); i < n; i++) {
			var _shortcut = self._keyboard_shortcuts[i];
			if keyboard_check_pressed(_shortcut.key) {
				_shortcut.callback(self);
				return true;
			}
		}
		return false;
	}

	///@ignore
	static _findShortcutElement = function(_root) {
		var _best = undefined;
		for (var i = array_length(self._shortcut_elements) - 1; i >= 0; i--) {
			var _element = self._shortcut_elements[i];
			if !keyboard_check_pressed(_element._shortcut_key) || !_element.is_visible_in_region
				|| !self.isInputAllowed(_element) || !self._isInModal(_element, _root)
				|| !self._hasFocusListener(_element, LUI_EV_CLICK) continue;
			var _parent = _element.parent;
			while !is_undefined(_parent) && _parent.visible && !_parent.deactivated && !_parent.is_destroyed {
				_parent = _parent.parent;
			}
			if !is_undefined(_parent) continue;
			if is_undefined(_best) || _compareDepthArrays(_element.depth_array, _best.depth_array) > 0 {
				_best = _element;
			}
		}
		return _best;
	}

	///@ignore
	static _updateKeyboardNavigation = function() {
		var _dx = (keyboard_check_pressed(vk_right) ? 1 : 0) - (keyboard_check_pressed(vk_left) ? 1 : 0);
		var _dy = (keyboard_check_pressed(vk_down) ? 1 : 0) - (keyboard_check_pressed(vk_up) ? 1 : 0);
		if _dx != 0 || _dy != 0 {
			self._keyboard_navigation_active = true;
			self.displayFocusedElement(true);
			self._moveKeyboardFocus(_dx, _dx == 0 ? _dy : 0);
			return true;
		}

		var _focused = self.element_in_focus;
		if !self._keyboard_navigation_active || !keyboard_check_pressed(vk_enter)
			|| is_undefined(_focused) || !self.isInputAllowed(_focused) return false;
		if !self._isInModal(_focused, self._keyboardFocusRoot()) return false;
		if self._hasFocusListener(_focused, LUI_EV_KEYBOARD_ADJUST) {
			self._keyboard_edit_target = _focused;
			return true;
		}
		if !self._hasFocusListener(_focused, LUI_EV_CLICK) return false;

		self._activateElement(_focused);
		return true;
	}

	///@ignore
	static _updateKeyboardEdit = function() {
		var _target = self._keyboard_edit_target;
		if is_undefined(_target) return false;
		if self.element_in_focus != _target || !self.isInputAllowed(_target)
			|| !self._isInModal(_target, self._keyboardFocusRoot()) || !self._hasFocusListener(_target, LUI_EV_KEYBOARD_ADJUST) {
			self._keyboard_edit_target = undefined;
			return false;
		}
		if keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_escape) {
			self._keyboard_edit_target = undefined;
			return true;
		}
		var _direction = (keyboard_check_pressed(vk_right) ? 1 : 0) - (keyboard_check_pressed(vk_left) ? 1 : 0);
		if _direction != 0 {
			_target._dispatchEvent(LUI_EV_KEYBOARD_ADJUST, _direction);
		}
		return true;
	}

	///@ignore
	static _keyboardFocusRoot = function() {
		for (var i = array_length(self._open_popups) - 1; i >= 0; i--) {
			var _panel = self._open_popups[i].panel;
			if self.isInputAllowed(_panel) return _panel;
		}
		return self._activeModal() ?? self;
	}

	///@ignore
	static _hasFocusListener = function(_element, _event) {
		var _listeners = _element.event_listeners[$ _event];
		return is_array(_listeners) && array_length(_listeners) > 0;
	}

	///@ignore
	static _isKeyboardFocusable = function(_element) {
		return _element._keyboard_focusable
			?? (!_element.ignore_mouse && (self._hasFocusListener(_element, LUI_EV_CLICK)
				|| self._hasFocusListener(_element, LUI_EV_KEYBOARD_INPUT)
				|| self._hasFocusListener(_element, LUI_EV_KEYBOARD_RELEASE)
				|| self._hasFocusListener(_element, LUI_EV_KEYBOARD_ADJUST)));
	}

	///@ignore
	static _moveKeyboardFocus = function(_dx, _dy) {
		var _root = self._keyboardFocusRoot();
		var _focused = self.element_in_focus;
		var _origin = undefined;
		if !is_undefined(_focused) && self.isInputAllowed(_focused)
			&& self._isInModal(_focused, _root) && self._isKeyboardFocusable(_focused) {
			_origin = _focused.getLayoutBounds();
		}
		var _search = {origin: _origin, dx: _dx, dy: _dy, best: undefined, score: infinity, aligned: false};
		self._findKeyboardFocus(_root, false, _search);
		var _next = _search.best;
		if is_undefined(_next) || _next == _focused return;

		if !is_undefined(_focused) && !_focused.is_destroyed {
			self.element_in_focus = undefined;
			_focused.removeFocus();
		}
		if !self.isInputAllowed(_next) || !self._isInModal(_next, self._keyboardFocusRoot()) return;

		self.element_in_focus = _next;
		_next.setFocus();
		if self.element_in_focus == _next && self.isInputAllowed(_next) {
			self._revealKeyboardFocus(_next);
		}
	}

	///@desc Searches layout bounds, including offscreen rows inside scroll panels.
	///@ignore
	static _findKeyboardFocus = function(_element, _inside_scroll, _search) {
		if !_element.visible || _element.is_destroyed || _element.deactivated return;
		if !_element.is_visible_in_region && (!_inside_scroll || is_undefined(_search.origin)) return;
		if _element != self && self._isKeyboardFocusable(_element) {
			var _bounds = _element.getLayoutBounds();
			if _bounds.width > 0 && _bounds.height > 0 {
				self._scoreKeyboardFocus(_element, _bounds, _search);
			}
		}
		if is_undefined(_search.origin) && !is_undefined(_search.best) return;

		var _can_reveal = _inside_scroll || !is_undefined(_element._scroll_owner);
		var _children = _element.content;
		for (var i = 0; i < array_length(_children); i++) {
			// Root contains registered modals, which are searched separately.
			var _child = _children[i];
			if _child._is_modal continue;
			self._findKeyboardFocus(_child, _can_reveal, _search);
			if is_undefined(_search.origin) && !is_undefined(_search.best) return;
		}
	}

	///@ignore
	static _scoreKeyboardFocus = function(_element, _bounds, _search) {
		var _origin = _search.origin;
		if is_undefined(_origin) {
			_search.best = _element;
			return;
		}
		var _x = _bounds.left + _bounds.width * 0.5 - (_origin.left + _origin.width * 0.5);
		var _y = _bounds.top + _bounds.height * 0.5 - (_origin.top + _origin.height * 0.5);
		var _forward = _x * _search.dx + _y * _search.dy;
		if _forward <= 0.5 return;

		var _horizontal = _search.dx != 0;
		var _cross = abs(_horizontal ? _y : _x);
		var _span = (_horizontal ? _origin.height + _bounds.height : _origin.width + _bounds.width) * 0.5;
		var _aligned = _cross < _span;
		var _score = _forward + 2 * _cross;
		if (_aligned && !_search.aligned) || (_aligned == _search.aligned && _score < _search.score) {
			_search.best = _element;
			_search.aligned = _aligned;
			_search.score = _score;
		}
	}

	///@ignore
	static _revealKeyboardFocus = function(_element) {
		var _bounds = _element.getLayoutBounds();
		var _node = _element;
		while !is_undefined(_node) {
			if !is_undefined(_node._scroll_owner) {
				_node._scroll_owner._revealFocusBounds(_bounds);
			}
			_node = _node.parent;
		}
	}

	///@ignore
	static _drawFocusFrame = function(_identity_matrix) {
		var _focused = self.element_in_focus;
		if is_undefined(_focused) || !self.isInputAllowed(_focused) return;

		if _focused.is_visible_in_region {
			var _matrix = _identity_matrix;
			var _element = _focused;
			while !is_undefined(_element) && _element != self {
				if _element._hasVisualTransform() {
					_matrix = matrix_multiply(_matrix, _element._buildVisualMatrix());
				}
				_element = _element.parent;
			}
			var _target = _luiTransformRect(_matrix, _focused.x, _focused.y, _focused.x + _focused.width, _focused.y + _focused.height);
			if is_undefined(self._focus_frame_bounds) {
				self._focus_frame_bounds = _target;
			} else {
				var _blend = 1 - exp(-20 * min(delta_time / 1000000, 0.1));
				var _bounds = self._focus_frame_bounds;
				for (var i = 0; i < 4; i++) {
					_bounds[i] = lerp(_bounds[i], _target[i], _blend);
				}
				self._focus_frame_bounds = _bounds;
			}
		}
		var _frame = self._focus_frame_bounds;
		if is_undefined(_frame) return;

		var _alpha = draw_get_alpha();
		draw_set_alpha(1);
		var _color = self._keyboard_edit_target == _focused ? #FFD37A : c_white;
		draw_rectangle_color(_frame[0] - 1, _frame[1] - 1, _frame[2] + 1, _frame[3] + 1, _color, _color, _color, _color, true);
		draw_set_alpha(_alpha);
	}

	// POPUPS AND POINTER ROUTING

	///@ignore
	static _registerPopup = function(_owner, _panel, _close, _place) {
		self._unregisterPopup(_panel);
		array_push(self._open_popups, {owner: _owner, panel: _panel, close: _close, place: _place});
	}

	///@ignore
	static _unregisterPopup = function(_panel) {
		for (var i = array_length(self._open_popups) - 1; i >= 0; i--) {
			if self._open_popups[i].panel == _panel {
				array_delete(self._open_popups, i, 1);
				return;
			}
		}
	}

	///@ignore
	static _closePopupsOutside = function(_target) {
		for (var i = array_length(self._open_popups) - 1; i >= 0; i--) {
			var _popup = self._open_popups[i];
			if !self._isInModal(_target, _popup.owner) && !self._isInModal(_target, _popup.panel) {
				_popup.close();
			}
		}
	}

	///@ignore
	static _updatePopups = function() {
		for (var i = array_length(self._open_popups) - 1; i >= 0; i--) {
			var _popup = self._open_popups[i];
			if _popup.panel.is_destroyed || !self.isInputAllowed(_popup.owner) || !_popup.owner.is_visible_in_region {
				_popup.close();
			} else {
				_popup.place();
			}
		}
	}

	///@ignore
	static _raiseOwnedPopups = function(_ancestor) {
		for (var i = 0; i < array_length(self._open_popups); i++) {
			var _popup = self._open_popups[i];
			if self._isInModal(_popup.owner, _ancestor) {
				_popup.panel.bringToFront();
			}
		}
	}

	///@ignore
	static _updateRightPointer = function(_mouse_x, _mouse_y) {
		var _pressed = mouse_check_button_pressed(mb_right);
		var _released = mouse_check_button_released(mb_right);
		if !_pressed && !_released return;

		var _target = self._getTopmostElement(_mouse_x, _mouse_y);
		if _pressed {
			self._closePopupsOutside(_target);
			self._right_pressed_element = undefined;
			if !is_undefined(_target) && self.isInputAllowed(_target) {
				self._right_pressed_element = _target;
				_target._dispatchEvent(LUI_EV_MOUSE_RIGHT_PRESSED);
				self._dispatchPointer(_target, LUI_EV_POINTER_DOWN, mb_right);
			}
		}
		if _released {
			var _origin = self._right_pressed_element;
			self._right_pressed_element = undefined;
			if is_undefined(_target) || !self.isInputAllowed(_target) return;

			_target._dispatchEvent(LUI_EV_MOUSE_RIGHT_RELEASED);
			if _origin == _target && self.isInputAllowed(_target) {
				self._dispatchPointerClick(_target, mb_right);
			}
		}
	}

	///@ignore
	static _dispatchPointerClick = function(_target, _button) {
		self._dispatchPointer(_target, LUI_EV_POINTER_CLICK, _button);
		self._activateElement(_target, _button == mb_right ? LUI_EV_RIGHT_CLICK : LUI_EV_CLICK);
	}

	///@ignore
	static _dispatchPointer = function(_target, _event, _button) {
		self._dispatchBubbledInput(_target, _event, {target: _target, button: _button, stop_propagation: false});
	}

	///@ignore
	static _dispatchBubbledInput = function(_target, _event, _data) {
		if !self.isInputAllowed(_target) return;
		var _wheel = _event == LUI_EV_POINTER_WHEEL;
		var _modal = self._activeModal();
		var _current = _target;
		while !is_undefined(_current) {
			var _next = _current.parent;
			for (var i = array_length(self._open_popups) - 1; i >= 0; i--) {
				var _popup = self._open_popups[i];
				if _popup.panel == _current {
					_next = _wheel ? undefined : _popup.owner;
					break;
				}
			}
			if !_current.is_destroyed {
				_current._dispatchEvent(_event, _data);
			}
			if _data.stop_propagation || self._activeModal() != _modal || _target.is_destroyed return;
			if _wheel && self.isInputAllowed(_current) {
				_current._handlePointerWheel(_data);
				if _data.stop_propagation || _current == _modal return;
			}
			_current = _next;
		}
	}

	///@desc Returns topmost element on UI
	///@ignore
	static _getTopmostElement = function(_mouse_x, _mouse_y) {
		var _grid = self.main_ui._screen_grid;
		var _cx = floor(_mouse_x / LUI_GRID_SIZE);
		var _cy = floor(_mouse_y / LUI_GRID_SIZE);
		if _cx < 0 || _cx >= array_length(_grid) return undefined;
		var _col = _grid[_cx];
		if _cy < 0 || _cy >= array_length(_col) return undefined;
		var _cell = _col[_cy];

		var _best = undefined;
		var _modal = self._activeModal();
		for (var i = array_length(_cell) - 1; i >= 0; --i) {
			var _e = _cell[i];
			if !_e.visible || _e.is_destroyed || _e.ignore_mouse continue;
			var _region = _e.view_region;
			if _mouse_x < _region.x1 || _mouse_x >= _region.x2 || _mouse_y < _region.y1 || _mouse_y >= _region.y2 continue;
			if !is_undefined(_modal) && !self._isInModal(_e, _modal) continue;
			// Not above the current best: skip without the expensive hover checks
			if !is_undefined(_best) && _compareDepthArrays(_e.depth_array, _best.depth_array) <= 0 continue;
			if !_e.isMouseHoveredExc() || !_e.isMouseHoveredParents() continue;
			_best = _e;
		}
		return _best;
	}

	///@ignore
	static _activeModal = function() {
		for (var i = array_length(self._modal_stack) - 1; i >= 0; i--) {
			var _dialog = self._modal_stack[i].dialog;
			if _dialog.visible && !_dialog.is_destroyed return _dialog;
		}
		return undefined;
	}

	///@ignore
	static _cancelPointerDrag = function() {
		var _drag = self.dragging_element;
		self.dragging_element = undefined;
		if is_undefined(_drag) || _drag.is_destroyed return;

		_drag.is_pressed = false;
		_drag.is_dragging = false;
		_drag._dispatchEvent(LUI_EV_MOUSE_LEFT_RELEASED);
		if !_drag.is_destroyed {
			_drag._dispatchEvent(LUI_EV_DRAG_END);
		}
	}

	///@ignore
	static _isInModal = function(_element, _dialog) {
		while !is_undefined(_element) {
			if _element == _dialog return true;
			_element = _element.parent;
		}
		return false;
	}

	///@ignore
	static _pushModal = function(_dialog, _initial_focus) {
		var _previous_focus = self.element_in_focus;
		_dialog._is_modal = true;
		array_push(self._modal_stack, {dialog: _dialog, previous_focus: _previous_focus});
		self._updatePopups();
		self._right_pressed_element = undefined;
		if !is_undefined(_previous_focus) {
			_previous_focus.removeFocus();
		}
		self.element_in_focus = _initial_focus;
		_initial_focus.setFocus();

		var _drag = self.dragging_element;
		self.dragging_element = undefined;
		if !is_undefined(_drag) && !_drag.is_destroyed {
			_drag.is_dragging = false;
			_drag._dispatchEvent(LUI_EV_DRAG_END);
		}
		var _hovered = self.topmost_hovered_element;
		self.topmost_hovered_element = undefined;
		if !is_undefined(_hovered) && !_hovered.is_destroyed {
			_hovered.is_mouse_hovered = false;
			_hovered.is_pressed = false;
			_hovered._dispatchEvent(LUI_EV_MOUSE_LEAVE);
		}
	}

	///@ignore
	static _popModal = function(_dialog) {
		var _count = array_length(self._modal_stack);
		for (var i = _count - 1; i >= 0; i--) {
			var _entry = self._modal_stack[i];
			if _entry.dialog != _dialog continue;
			array_delete(self._modal_stack, i, 1);
			if self._isInModal(self.topmost_hovered_element, _dialog) {
				self.topmost_hovered_element = undefined;
			}
			if self._isInModal(self.dragging_element, _dialog) {
				self.dragging_element = undefined;
			}
			var _restore = _entry.previous_focus;
			for (var _next = i; _next < _count - 1; _next++) {
				var _later = self._modal_stack[_next];
				if self._isInModal(_later.previous_focus, _dialog) {
					_later.previous_focus = _restore;
				}
			}
			if i == _count - 1 && !is_undefined(_restore) && _restore.visible && !_restore.deactivated
				&& _restore.main_ui == self && self.isInputAllowed(_restore) {
				self.element_in_focus = _restore;
				_restore.setFocus();
			}
			return;
		}
	}

	// TREE DRAWING AND CLIPPING

	///@desc Draws element with its subtree.
	/// Invariant on entry: matrix_world == _pm, scissor == _clip. Restored on exit.
	///@ignore
	static _drawTree = function(_el, _pm, _pa, _clip) {
		if !_el.visible || _el.is_destroyed || !_el.is_visible_in_region return;

		var _a = _pa * _el.visual_alpha;
		if _a <= 0 return;

		var _has_t = _el._hasVisualTransform();
		var _m = _has_t ? matrix_multiply(_el._buildVisualMatrix(), _pm) : _pm;
		if _has_t {
			matrix_set(matrix_world, _m);
		}

		if _el._cache_active && surface_exists(_el._cached_surface) {
			self._blitCache(_el, _a);
		} else {
			self._drawSelfAndChildren(_el, _m, _a, _clip);
		}

		if _has_t {
			matrix_set(matrix_world, _pm);
		}
	}

	///@desc Own draw (with own material) + children (with clipping if the element clips its content).
	/// Invariant on entry: matrix_world == _m, scissor == _clip. Restored on exit.
	///@ignore
	static _drawSelfAndChildren = function(_el, _m, _a, _clip) {
		if is_method(_el.draw) {
			draw_set_alpha(_a);
			var _mat = _el.material;
			var _own_mat = !is_undefined(_mat) && !_mat.group;   // group materials are applied on cache blit
			if _own_mat {
				shader_set(_mat.shader);
				if is_callable(_mat.apply) {
					_mat.apply(_el, _mat);
				}
			}
			_el.draw();
			if _own_mat {
				shader_reset();
			}
		}

		var _kids = _el._getDrawChildren();
		var _n = array_length(_kids);
		if _n == 0 return;

		var _child_clip = _clip;
		var _clipping = _el.draw_content_in_cutted_region;
		if _clipping {
			_child_clip = self._pushClip(_clip, _el, _m);
			if _child_clip[2] <= _child_clip[0] || _child_clip[3] <= _child_clip[1] {
				self._clip_depth--;
				return;
			}
			_luiApplyClip(_child_clip);
		}

		for (var i = 0; i < _n; i++) {
			self._drawTree(_kids[i], _m, _a, _child_clip);
		}

		if _clipping {
			_luiApplyClip(_clip);
			self._clip_depth--;
		}
	}

	///@desc Next slot of the preallocated clip stack filled with (_clip ∩ children clip of _el)
	///@ignore
	static _pushClip = function(_clip, _el, _m) {
		self._clip_depth++;
		if self._clip_depth >= array_length(self._clip_stack) {
			array_push(self._clip_stack, [0, 0, 0, 0]);
		}
		var _c = self._clip_stack[self._clip_depth];
		_luiClipChildrenInto(_c, _clip, _el, _m);
		return _c;
	}

	// SURFACE CACHES

	///@desc Bottom-up: decides which elements use a cache this frame and (re)bakes dirty ones.
	/// Cache is used for: explicit cache_as_surface, group alpha (visual_alpha < 1 with children), group material.
	///@ignore
	static _prepareCaches = function(_el) {
		if !_el.visible || _el.is_destroyed || !_el.is_visible_in_region return;

		if _el._last_visual_alpha != _el.visual_alpha {
			_el._last_visual_alpha = _el.visual_alpha;
			_el._invalidateAncestorCaches();
		}

		var _has_kids = array_length(_el.content) > 0;
		if _has_kids {
			for (var i = 0, n = array_length(_el.content); i < n; i++) {
				self._prepareCaches(_el.content[i]);
			}
		}

		var _mat = _el.material;
		var _group_mat = !is_undefined(_mat) && _mat.group;
		var _group_alpha = _has_kids && _el.visual_alpha < 1 && _el.visual_alpha > 0;
		var _was_active = _el._cache_active;
		if _el.cache_as_surface || _group_alpha || _group_mat {
			_el._cache_active = self._bakeCache(_el);
		} else if _was_active {
			_el._cache_active = false;
			_el._freeCache();
		}
		if _was_active && !_el._cache_active {
			_el._invalidateAncestorCaches();
		}
	}

	///@desc Renders the element and its children into a premultiplied surface.
	/// The root's visual transform and alpha are applied only on blit.
	///@ignore
	static _bakeCache = function(_el) {
		var _pad = _el.cache_padding;
		var _ox = floor(_el.x);
		var _oy = floor(_el.y);
		var _w = ceil(ceil(_el.x + _el.width) - _ox + _pad * 2);
		var _h = ceil(ceil(_el.y + _el.height) - _oy + _pad * 2);

		if _w < 1 || _h < 1 || _w > LUI_CACHE_MAX_SIZE || _h > LUI_CACHE_MAX_SIZE {
			_el._freeCache();
			return false;
		}

		if surface_exists(_el._cached_surface) {
			if surface_get_width(_el._cached_surface) != _w || surface_get_height(_el._cached_surface) != _h {
				_el._freeCache();
			}
		}
		if !surface_exists(_el._cached_surface) {
			_el._cached_surface = surface_create(_w, _h);
			_el._is_cache_dirty = true;
		}
		if !surface_exists(_el._cached_surface) return false;
		if !_el._is_cache_dirty return true;

		var _prev_matrix = matrix_get(matrix_world);
		var _prev_scissor = gpu_get_scissor();
		var _prev_alpha = draw_get_alpha();
		if !surface_set_target(_el._cached_surface) {
			_el._freeCache();
			return false;
		}

		draw_clear_alpha(c_black, 0);
		self._baking = true;
		_luiBlendBake();

		var _m = matrix_build(_pad - _ox, _pad - _oy, 0, 0, 0, 0, 1, 1, 1);
		var _clip = [0, 0, _w, _h];
		matrix_set(matrix_world, _m);
		gpu_set_scissor(0, 0, _w, _h);
		self._drawSelfAndChildren(_el, _m, 1, _clip);

		_luiBlendReset();
		self._baking = false;
		surface_reset_target();
		gpu_set_scissor(_prev_scissor);
		matrix_set(matrix_world, _prev_matrix);
		draw_set_alpha(_prev_alpha);

		_el._is_cache_dirty = false;
		self._cache_bakes++;
		// Ancestor surfaces may contain the old pixels or the direct-draw fallback.
		_el._invalidateAncestorCaches();
		return true;
	}

	///@desc Draws a cached surface (premultiplied) with group alpha and optional group material
	///@ignore
	static _blitCache = function(_el, _a) {
		var _v = floor(255 * _a);
		var _mat = _el.material;
		var _group_mat = !is_undefined(_mat) && _mat.group;
		if _group_mat {
			shader_set(_mat.shader);
			if is_callable(_mat.apply) {
				_mat.apply(_el, _mat);
			}
		}
		_luiBlendBlit();
		draw_surface_ext(_el._cached_surface,
			floor(_el.x) - _el.cache_padding, floor(_el.y) - _el.cache_padding,
			1, 1, 0, make_colour_rgb(_v, _v, _v), _a);
		if _group_mat {
			shader_reset();
		}
		if self._baking {
			_luiBlendBake();
		} else {
			_luiBlendReset();
		}
	}

	// MODAL BACKDROP

	///@desc Composites the root children behind the topmost blurred modal.
	///@ignore
	static _drawBackdrop = function(_children, _modal_start, _matrix, _clip) {
		var _index = 0;
		var _radius = 0;
		for (var i = array_length(_children) - 1; i >= max(1, _modal_start); i--) {
			var _child = _children[i];
			if !_child.visible || _child.is_destroyed || !_child.is_visible_in_region || _child.visual_alpha <= 0 continue;
			if _child.backdrop_blur > 0 {
				_index = i;
				_radius = _child.backdrop_blur;
				break;
			}
		}

		var _width = ceil(_clip[2]);
		var _height = ceil(_clip[3]);
		if _index == 0 || !shader_is_compiled(shd_lui_backdrop_blur)
			|| _width < 1 || _height < 1 || _width > LUI_CACHE_MAX_SIZE || _height > LUI_CACHE_MAX_SIZE {
			self._freeBackdrop();
			return 0;
		}
		var _step_uniform = shader_get_uniform(shd_lui_backdrop_blur, "u_blur_step");
		if _step_uniform < 0 {
			self._freeBackdrop();
			return 0;
		}

		if surface_exists(self._backdrop_surface) {
			if surface_get_width(self._backdrop_surface) != _width || surface_get_height(self._backdrop_surface) != _height {
				self._freeBackdrop();
			}
		}
		if !surface_exists(self._backdrop_surface) {
			self._backdrop_surface = surface_create(_width, _height);
		}
		if !surface_exists(self._backdrop_surface) return 0;
		if !surface_exists(self._backdrop_blur_surface) {
			self._backdrop_blur_surface = surface_create(_width, _height);
		}
		if !surface_exists(self._backdrop_blur_surface) {
			self._freeBackdrop();
			return 0;
		}
		if !surface_set_target(self._backdrop_surface) {
			self._freeBackdrop();
			return 0;
		}

		matrix_set(matrix_world, _matrix);
		_luiApplyClip(_clip);
		draw_clear_alpha(c_black, 0);
		self._baking = true;
		_luiBlendBake();
		for (var i = 0; i < _index; i++) {
			self._drawTree(_children[i], _matrix, 1, _clip);
		}
		self._baking = false;
		surface_reset_target();
		matrix_set(matrix_world, _matrix);
		_luiApplyClip(_clip);

		if surface_set_target(self._backdrop_blur_surface) {
			matrix_set(matrix_world, _matrix);
			gpu_set_scissor(0, 0, _width, _height);
			draw_clear_alpha(c_black, 0);

			var _filter = gpu_get_texfilter_ext(0);
			gpu_set_texfilter_ext(0, true);
			var _spacing = _radius / 5;
			var _source_texture = surface_get_texture(self._backdrop_surface);
			shader_set(shd_lui_backdrop_blur);
			shader_set_uniform_f(_step_uniform, _spacing * texture_get_texel_width(_source_texture), 0);
			gpu_set_blendmode_ext(bm_one, bm_zero);
			draw_surface_ext(self._backdrop_surface, 0, 0, 1, 1, 0, c_white, 1);
			shader_reset();

			surface_reset_target();
			matrix_set(matrix_world, _matrix);
			_luiApplyClip(_clip);
			var _blur_texture = surface_get_texture(self._backdrop_blur_surface);
			shader_set(shd_lui_backdrop_blur);
			shader_set_uniform_f(_step_uniform, 0, _spacing * texture_get_texel_height(_blur_texture));
			_luiBlendBlit();
			draw_surface_ext(self._backdrop_blur_surface, 0, 0, 1, 1, 0, c_white, 1);
			shader_reset();
			gpu_set_texfilter_ext(0, _filter);
		} else {
			_luiBlendBlit();
			draw_surface_ext(self._backdrop_surface, 0, 0, 1, 1, 0, c_white, 1);
			self._freeBackdrop();
		}
		_luiBlendReset();
		return _index;
	}

	///@ignore
	static _freeBackdrop = function() {
		if surface_exists(self._backdrop_surface) {
			surface_free(self._backdrop_surface);
		}
		self._backdrop_surface = -1;
		if surface_exists(self._backdrop_blur_surface) {
			surface_free(self._backdrop_blur_surface);
		}
		self._backdrop_blur_surface = -1;
	}

	// DEBUG

	///@desc Draw debug grid info
	///@ignore
	static _drawScreenGrid = function() {
		draw_set_alpha(1);
		draw_set_color(c_red);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_font(fDebug);

		var _gui_width = display_get_gui_width();
		var _gui_height = display_get_gui_height();

		var _width = ceil(_gui_width / LUI_GRID_SIZE);
		var _height = ceil(_gui_height / LUI_GRID_SIZE);

		for (var _x = 0; _x <= _width; ++_x) {
			var _x_pos = _x * LUI_GRID_SIZE;
			draw_line(_x_pos, 0, _x_pos, _gui_height);

			for (var _y = 0; _y <= _height; ++_y) {
				var _y_pos = _y * LUI_GRID_SIZE;

				if _x == 0 {
					draw_line(0, _y_pos, _gui_width, _y_pos);
				}

				var _array = [];
				if _x < array_length(self._screen_grid) && _y < array_length(self._screen_grid[_x]) {
					_array = self._screen_grid[_x][_y];
				}
				draw_text(_x_pos + 2, _y_pos + 1, $"{_x}_{_y}");

				var _elements_in_cell = array_length(_array);
				for (var i = 0, n = min(18, _elements_in_cell); i < n; ++i) {
					if i mod 2 == 0 {
						draw_set_color(c_orange);
					} else {
						draw_set_color(c_red);
					}
					draw_text(_x_pos + 2, _y_pos + 1 + 12 + 6 * i, string_copy(_array[i].name, 0, 18));
				}
				draw_set_color(c_red);
				if _elements_in_cell > 18 {
					draw_text(_x_pos + 2, _y_pos + 1 + 12 + 6 * 18, $"and {_elements_in_cell - 18} elements...");
				}
			}
		}
	};

	// CLEANUP

	self.addEvent(LUI_EV_DESTROY, function(_e) {
		_e._freeBackdrop();
		_e.pre_draw_list = -1;
		_e._keyboard_shortcuts = [];
		_e._shortcut_elements = [];
		_e.element_in_focus = undefined;
		_e.dragging_element = undefined;
		_e.active_animations = -1;
		_e._screen_grid = undefined;
		delete _e.element_names;
		_e._elements_by_tag = {};
		global.lui_element_count = 0;
		global.lui_id_count = 0;
		global.lui_max_z = 0;
	});
}
