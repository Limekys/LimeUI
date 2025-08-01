///@desc Slider with a limited value from and to, e.g. to change the volume.
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
///@arg {Real} min_value
///@arg {Real} max_value
///@arg {Real} value
///@arg {Real} rounding
///@arg {Function} callback
function LuiSlider(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = LUI_AUTO_NAME, min_value = 0, max_value = 100, value = 0, rounding = 0, callback = undefined)
 : LuiProgressBar(x, y, width, height, name, min_value, max_value, true, value, rounding) constructor {
	
	setCallback(callback);
	
	self.can_drag = true;
	
	self.draw = function() {
		// Value
		var _bar_value = Range(self.value, self.min_value, self.max_value, 0, 1);
		// Base
		if !is_undefined(self.style.sprite_progress_bar) {
			var _blend_color = self.style.color_back;
			if self.deactivated {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_progress_bar, 0, self.x, self.y, width, height, _blend_color, 1);
		}
		// Bar value
		if !is_undefined(self.style.sprite_progress_bar_value) {
			var _blend_color = self.style.color_accent;
			if self.deactivated {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_progress_bar_value, 0, self.x, self.y, width * _bar_value, height, _blend_color, 1);
		}
		// Border
		if !is_undefined(self.style.sprite_progress_bar_border) {
			draw_sprite_stretched_ext(self.style.sprite_progress_bar_border, 0, self.x, self.y, width, height, self.style.color_border, 1);
		}
		// Text value
		if !is_undefined(self.style.font_default) {
			draw_set_font(self.style.font_default);
		}
		if !self.deactivated {
			draw_set_color(self.style.color_text);
		} else {
			draw_set_color(merge_color(self.style.color_text, c_black, 0.5));
		}
		if !self.is_dragging {
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_text(self.x + self.width div 2, self.y + self.height div 2, self.value);
		}
		// Slider knob
		var _knob_width = self.height;
		if !is_undefined(self.style.sprite_slider_knob) {
			var _slider_knob_nineslice = sprite_get_nineslice(self.style.sprite_slider_knob);
			var _nineslice_left_right = _slider_knob_nineslice.left + _slider_knob_nineslice.right;
			_knob_width = _nineslice_left_right == 0 ? sprite_get_width(self.style.sprite_slider_knob) : _nineslice_left_right;
		}
		var _knob_x = clamp(self.x + self.width * _bar_value - _knob_width div 2, self.x, self.x + self.width - _knob_width);
		var _knob_extender = 1;
		if !is_undefined(self.style.sprite_slider_knob) {
			var _blend_color = self.style.color_secondary;
			if !self.deactivated {
				if self.isMouseHovered() {
					_blend_color = merge_color(self.style.color_secondary, self.style.color_hover, 0.5);
				}
			} else {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_slider_knob, 0, _knob_x - _knob_extender, self.y - _knob_extender, _knob_width + _knob_extender*2, self.height + _knob_extender*2, _blend_color, 1);
		}
		// Knob border
		if !is_undefined(self.style.sprite_slider_knob_border) {
			draw_sprite_stretched_ext(self.style.sprite_slider_knob_border, 0, _knob_x - _knob_extender, self.y - _knob_extender, _knob_width + _knob_extender*2, self.height + _knob_extender*2, self.style.color_border, 1);
		}
		// Popup text value when dragging
		if self.is_dragging {
			draw_set_halign(fa_center);
			draw_set_valign(fa_bottom);
			draw_text(_knob_x + _knob_width div 2, self.y - 4, self.value);
		}
	}
	
	self.addEvent(LUI_EV_MOUSE_WHEEL, function(_element) {
		var _wheel_step = max(_element.rounding, (_element.max_value - _element.min_value) * 0.02);
		var _wheel_up = mouse_wheel_up() ? 1 : 0;
		var _wheel_down = mouse_wheel_down() ? 1 : 0;
		var _wheel = _wheel_up - _wheel_down;
		var _new_value = clamp(_element.value + _wheel * _wheel_step, _element.min_value, _element.max_value);
		_new_value = _calcValue(_new_value);
		_element.set(_new_value);
	});
	
	self.addEvent(LUI_EV_VALUE_UPDATE, function(_element) {
		_element.callback(); //???//обратная совместимость
	});
	
	self.addEvent(LUI_EV_DRAGGING, function(_element, _data) {
		var x1 = _element.x;
		var x2 = x1 + _element.width;
		var _new_value = _calcValue((_data.mouse_x - x1) / (x2 - x1) * (_element.max_value - _element.min_value) + _element.min_value);
		_element.set(_new_value);
	});
}