///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {Real} value_min
///@arg {Real} value_max
///@arg {Real} value
///@arg {Function} callback
function LuiSlider(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, value_min = 0, value_max = 100, value = 0, callback = undefined) : LuiBase() constructor {
	
	self.name = "LuiSlider";
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	init_element();
	set_callback(callback);
	
	self.value_min = min(value_min, value_max);
	self.value_max = max(value_min, value_max);
	self.integers_only = false;
	self.dragging = false;
	self.value = value;
	
	self.render_mode = 1;
	///@desc 0 - raw value, 1 - integer only //???//
	self.set_render_mode = function(mode) {
		render_mode = mode;
		return self;
	}
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		//Bar
		var _bar_value = Range(self.value, self.value_min, self.value_max, 0, 1);
		//Base
		if !is_undefined(self.style.sprite_progress_bar) {
			draw_sprite_stretched_ext(self.style.sprite_progress_bar, 0, draw_x, draw_y, width, height, self.style.color_progress_bar, 1);
		}
		//Value
		if !is_undefined(self.style.sprite_progress_bar_value) {
			draw_sprite_stretched_ext(self.style.sprite_progress_bar_value, 0, draw_x, draw_y, width * _bar_value, height, self.style.color_progress_bar_value, 1);
		}
		//Border
		if !is_undefined(self.style.sprite_progress_bar_border) {
			draw_sprite_stretched_ext(self.style.sprite_progress_bar_border, 0, draw_x, draw_y, width, height, self.style.color_progress_bar_border, 1);
		}
		//Text value
		var _value = render_mode == 0 ? string(self.value) : string(round(self.value));
		if !is_undefined(self.style.font_sliders) draw_set_font(self.style.font_sliders);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text(draw_x + self.width div 2, draw_y + self.height div 2, _value);
		//Slider knob
		var _knob_width = self.height;
		if !is_undefined(self.style.sprite_slider_knob) {
			var _nineslice_left_right = sprite_get_nineslice(self.style.sprite_slider_knob).left + sprite_get_nineslice(self.style.sprite_slider_knob).right;
			_knob_width = _nineslice_left_right == 0 ? sprite_get_width(self.style.sprite_slider_knob) : _nineslice_left_right;
		}
		var _knob_x = clamp(draw_x + self.width * _bar_value - _knob_width div 2, draw_x, draw_x + self.width - _knob_width);
		var _knob_extender = 1;
		if !is_undefined(self.style.sprite_slider_knob) {
			var _blend_color = self.style.color_progress_bar;
			if !self.deactivated && self.mouse_hover() _blend_color = merge_colour(self.style.color_progress_bar, self.style.color_hover, 0.5);
			draw_sprite_stretched_ext(self.style.sprite_slider_knob, 0, _knob_x - _knob_extender, draw_y - _knob_extender, _knob_width + _knob_extender*2, self.height + _knob_extender*2, _blend_color, 1);
		}
		//Knob border
		if !is_undefined(self.style.sprite_slider_knob_border) {
			draw_sprite_stretched_ext(self.style.sprite_slider_knob_border, 0, _knob_x - _knob_extender, draw_y - _knob_extender, _knob_width + _knob_extender*2, self.height + _knob_extender*2, self.style.color_progress_bar_border, 1);
		}
	}
	
	self.step = function() {
		var x1 = self.x;
		var y1 = self.y;
		var x2 = x1 + self.width;
		var y2 = y1 + self.height;
		
		if mouse_check_button_pressed(mb_left) && mouse_hover() {
			self.dragging = true;
		}
		
		if (self.dragging) {
			if mouse_check_button(mb_left) {
				self.value = clamp(((device_mouse_x_to_gui(0) - view_get_xport(view_current)) - x1) / (x2 - x1) * (self.value_max - self.value_min) + self.value_min, self.value_min, self.value_max);
				if (self.integers_only) {
				    self.value = round(self.value);
				}
				self.callback();
			} else {
				self.dragging = false;
			}
		}
	}
	
	return self;
}