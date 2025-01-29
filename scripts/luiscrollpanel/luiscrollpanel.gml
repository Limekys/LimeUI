///@desc Panel with the ability to scroll down/up.
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
function LuiScrollPanel(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = "LuiScrollPanel") : LuiBase() constructor {
	
	self.name = name;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	initElement();
	
	self.scroll_container = undefined;
	self.scroll_offset_y = 0;
	self.scroll_target_offset_y = 0;
	self.region_offset = undefined;
	self.drag_start_y = -1;
	self.drag_y = -1;
	
	self.draw_content_in_cutted_region = true;
	
	self.onCreate = function() {
		self._initScrollContainer();
		self.addContentOriginal(self.scroll_container);
		if self.auto_height {
			self.setSize(LUI_AUTO, self.scroll_container.height);
		}
		
	}
	
	///@desc Change getContainer function for compatibility with setFlex... functions
	self.getContainer = function() {
		self._initScrollContainer();
		return self.container;
	}
	
	///@desc Set offset region for render content
	///@arg {array} _region array[left, right, top, bottom]
	static setRegionOffset = function(_region) {
		self.region_offset = {
			left : _region[0],
			right : _region[1],
			top : _region[2],
			bottom : _region[3]
		}
	}
	
	///@desc Create scroll container
	static _initScrollContainer = function() {
		if is_undefined(self.scroll_container) {
			self.scroll_container = new LuiAbsContainer(0, 0, LUI_AUTO, LUI_AUTO, $"_scroll_container_{self.element_id}");
			self.setContainer(self.scroll_container);
		}
	}
	
	///@desc Original addContent for compatibility
	self.addContentOriginal = method(self, addContent);
	
	///@desc Redirect addContent to scroll_container
	self.addContent = function(elements) {
		self._initScrollContainer();
		self.scroll_container.addContent(elements);
		return self;
	}
	
	///@desc Delete scroll panel content
	static cleanScrollPanel = function() {
		self.scroll_container.destroyContent();
		self.scroll_offset_y = 0;
		self.scroll_target_offset_y = 0;
	}
	
	///@ignore
	static _applyScroll = function() {
		self.scroll_container.setPosition(LUI_AUTO, self.scroll_offset_y);
	}
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		//Panel
		if !is_undefined(self.style.sprite_panel) {
			var _blend_color = self.style.color_main;
			if self.deactivated {
				_blend_color = merge_colour(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_panel, 0, draw_x, draw_y, self.width, self.height, _blend_color, 1);
		}
		//Scroll slider
		var _scroll_slider_offset = 8;
		var _scroll_slider_x = draw_x + self.width - _scroll_slider_offset - _scroll_slider_offset div 2;
		if !is_undefined(self.style.sprite_scroll_slider_back) {
			draw_sprite_stretched_ext(self.style.sprite_scroll_slider_back, 0, _scroll_slider_x, draw_y + _scroll_slider_offset, _scroll_slider_offset, self.height - _scroll_slider_offset*2, self.style.color_scroll_slider_back, 1);
		}
		if !is_undefined(self.style.sprite_scroll_slider) && array_length(self.content) > 0 {
			var _scroll_slider_y = Range(self.scroll_offset_y, 0, -(self.scroll_container.height - self.height), 0, self.height - self.style.padding - _scroll_slider_offset);
			draw_sprite_stretched_ext(self.style.sprite_scroll_slider, 0, _scroll_slider_x, draw_y + _scroll_slider_offset + _scroll_slider_y, _scroll_slider_offset, _scroll_slider_offset, self.style.color_scroll_slider, 1);
		}
		//Panel border
		if !is_undefined(self.style.sprite_panel_border) {
			draw_sprite_stretched_ext(self.style.sprite_panel_border, 0, draw_x, draw_y, self.width, self.height, self.style.color_border, 1);
		}
	}
	
	self.step = function() {
		// Mouse wheel input
		if mouseHoverAny() {
			var _wheel_up = mouse_wheel_up() ? 1 : 0;
			var _wheel_down = mouse_wheel_down() ? 1 : 0;
			var _wheel = _wheel_up - _wheel_down;
			if _wheel != 0 {
				self.scroll_target_offset_y += self.style.scroll_step * _wheel;
				self.scroll_target_offset_y = clamp(self.scroll_target_offset_y, -(self.scroll_container.height - self.height), 0);
			}
			// Touch compatibility
			if self.drag_start_y == -1 && mouse_check_button_pressed(mb_left) {
				self.drag_start_y = device_mouse_y_to_gui(0);
			}
		}
		// Touch compatibility
		if self.drag_start_y != -1 {
			if mouse_check_button(mb_left) 
				&& (is_undefined(self.main_ui.element_in_focus) || (!is_undefined(self.main_ui.element_in_focus) && is_undefined(self.main_ui.element_in_focus.callback))) {
				self.drag_y = device_mouse_y_to_gui(0);
				self.scroll_target_offset_y = self.scroll_target_offset_y - self.drag_start_y + self.drag_y;
				self.drag_start_y = SmoothApproachDelta(self.drag_start_y, self.drag_y, 1.1);
				self.scroll_target_offset_y = clamp(self.scroll_target_offset_y, -(self.scroll_container.height - self.height), 0);
			}
			if mouse_check_button_released(mb_left) {
				self.drag_start_y = -1;
			}
		}
		// Scrolling
		if self.scroll_offset_y != self.scroll_target_offset_y {
			self.scroll_offset_y = SmoothApproachDelta(self.scroll_offset_y, self.scroll_target_offset_y, 2, 1);
			self._applyScroll();
		}
	}
}