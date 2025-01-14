///@desc Slider with a limited value from and to, e.g. to change the volume.
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
///@arg {Real} value_min
///@arg {Real} value_max
///@arg {Real} value
///@arg {Real} rounding
///@arg {Function} callback
function LuiSlider(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = "LuiSlider", value_min = 0, value_max = 100, value = 0, rounding = 0, callback = undefined) : LuiBase() constructor {
	
	self.name = name;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	initElement();
	setCallback(callback);
	
	self.value = value;
	self.value_min = min(value_min, value_max);
	self.value_max = max(value_min, value_max);
	self.rounding = rounding;
	self.dragging = false;
	
	static _calcValue = function(value) {
		if self.rounding > 0 {
			return round(value / (self.rounding)) * (self.rounding);
		} else {
			return value;
		}
	}
	
	static setRounding = function(rounding) {
		self.rounding = rounding;
		return self;
	}
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		// Value
		var _bar_value = Range(self.value, self.value_min, self.value_max, 0, 1);
		// Base
		if !is_undefined(self.style.sprite_progress_bar) {
			var _blend_color = self.style.color_progress_bar;
			if self.deactivated {
				_blend_color = merge_colour(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_progress_bar, 0, draw_x, draw_y, width, height, _blend_color, 1);
		}
		// Bar value
		if !is_undefined(self.style.sprite_progress_bar_value) {
			var _blend_color = self.style.color_progress_bar_value;
			if self.deactivated {
				_blend_color = merge_colour(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_progress_bar_value, 0, draw_x, draw_y, width * _bar_value, height, _blend_color, 1);
		}
		// Border
		if !is_undefined(self.style.sprite_progress_bar_border) {
			draw_sprite_stretched_ext(self.style.sprite_progress_bar_border, 0, draw_x, draw_y, width, height, self.style.color_progress_bar_border, 1);
		}
		// Text value
		if !is_undefined(self.style.font_sliders) {
			draw_set_font(self.style.font_sliders);
		}
		if !self.deactivated {
			draw_set_color(self.style.color_font);
		} else {
			draw_set_color(merge_colour(self.style.color_font, c_black, 0.5));
		}
		if !self.dragging {
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_text(draw_x + self.width div 2, draw_y + self.height div 2, self.value);
		}
		// Slider knob
		var _knob_width = self.height;
		if !is_undefined(self.style.sprite_slider_knob) {
			var _slider_knob_nineslice = sprite_get_nineslice(self.style.sprite_slider_knob);
			var _nineslice_left_right = _slider_knob_nineslice.left + _slider_knob_nineslice.right;
			_knob_width = _nineslice_left_right == 0 ? sprite_get_width(self.style.sprite_slider_knob) : _nineslice_left_right;
		}
		var _knob_x = clamp(draw_x + self.width * _bar_value - _knob_width div 2, draw_x, draw_x + self.width - _knob_width);
		var _knob_extender = 1;
		if !is_undefined(self.style.sprite_slider_knob) {
			var _blend_color = self.style.color_progress_bar;
			if !self.deactivated {
				if self.mouseHover() {
					_blend_color = merge_colour(self.style.color_progress_bar, self.style.color_hover, 0.5);
				}
			} else {
				_blend_color = merge_colour(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_slider_knob, 0, _knob_x - _knob_extender, draw_y - _knob_extender, _knob_width + _knob_extender*2, self.height + _knob_extender*2, _blend_color, 1);
		}
		// Knob border
		if !is_undefined(self.style.sprite_slider_knob_border) {
			draw_sprite_stretched_ext(self.style.sprite_slider_knob_border, 0, _knob_x - _knob_extender, draw_y - _knob_extender, _knob_width + _knob_extender*2, self.height + _knob_extender*2, self.style.color_progress_bar_border, 1);
		}
		// Popup text value when dragging
		if self.dragging {
			draw_set_halign(fa_center);
			draw_set_valign(fa_bottom);
			draw_text(_knob_x + _knob_width div 2, draw_y - 4, self.value);
		}
	}
	
	self.step = function() {
		if (self.dragging) {
			if mouse_check_button(mb_left) {
				// Calculate new value
				var x1 = self.x;
				var y1 = self.y;
				var x2 = x1 + self.width;
				var _new_value = clamp(((device_mouse_x_to_gui(0) - view_get_xport(view_current)) - x1) / (x2 - x1) * (self.value_max - self.value_min) + self.value_min, self.value_min, self.value_max);
				// Rounding
				_new_value = _calcValue(_new_value);
				self.set(_new_value);
			} else {
				self.dragging = false;
			}
		}
	}
	
	self.onMouseLeftPressed = function() {
		self.dragging = true;
	}
	
	self.onMouseWheel = function() {
		var _wheel_step = 2;
		var _wheel_up = mouse_wheel_up() ? 1 : 0;
		var _wheel_down = mouse_wheel_down() ? 1 : 0;
		var _wheel = _wheel_up - _wheel_down;
		var _new_value = clamp(self.value + _wheel * _wheel_step, self.value_min, self.value_max);
		_new_value = _calcValue(_new_value);
		self.set(_new_value);
	}
	
	self.onValueUpdate = function() {
		self.callback();
	}
}