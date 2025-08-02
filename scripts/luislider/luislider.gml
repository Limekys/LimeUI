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
	self.knob_width = height;
	self.bar_value = Range(value, min_value, max_value, 0, 1);
	
	// Calculate knob width in constructor
	static _initKnobWidth = function() {
		if !is_undefined(self.style.sprite_slider_knob) {
			var _slider_knob_nineslice = sprite_get_nineslice(self.style.sprite_slider_knob);
			var _nineslice_left_right = _slider_knob_nineslice.left + _slider_knob_nineslice.right;
			self.knob_width = _nineslice_left_right == 0 ? sprite_get_width(self.style.sprite_slider_knob) : _nineslice_left_right;
		}
	}
	
	self.draw = function() {
		// Calculate colors based on state
		var _blend_back = self.style.color_back;
		var _blend_accent = self.style.color_accent;
		var _blend_secondary = self.style.color_secondary;
		var _blend_text = self.style.color_text;
		var _blend_border = self.style.color_border;
		if self.deactivated {
			_blend_back = merge_color(_blend_back, c_black, 0.5);
			_blend_accent = merge_color(_blend_accent, c_black, 0.5);
			_blend_secondary = merge_color(_blend_secondary, c_black, 0.5);
			_blend_text = merge_color(_blend_text, c_black, 0.5);
		} else if self.isMouseHovered() {
			_blend_secondary = merge_color(_blend_secondary, self.style.color_hover, 0.5);
		}
		
		// Base
		if !is_undefined(self.style.sprite_progress_bar) {
			draw_sprite_stretched_ext(self.style.sprite_progress_bar, 0, self.x, self.y, self.width, self.height, _blend_back, 1);
		}
		
		// Bar value
		if !is_undefined(self.style.sprite_progress_bar_value) {
			draw_sprite_stretched_ext(self.style.sprite_progress_bar_value, 0, self.x, self.y, self.width * self.bar_value, self.height, _blend_accent, 1);
		}
		
		// Border
		if !is_undefined(self.style.sprite_progress_bar_border) {
			draw_sprite_stretched_ext(self.style.sprite_progress_bar_border, 0, self.x, self.y, self.width, self.height, _blend_border, 1);
		}
		
		// Text
		if !is_undefined(self.style.font_default) {
			draw_set_font(self.style.font_default);
		}
		draw_set_color(_blend_text);
		draw_set_halign(fa_center);
		draw_set_valign(self.is_dragging ? fa_bottom : fa_middle);
		var _text_x = self.is_dragging ? self.x + self.width * self.bar_value : self.x + self.width div 2;
		var _text_y = self.is_dragging ? self.y - 4 : self.y + self.height div 2;
		draw_text(_text_x, _text_y, self.value);
		
		// Slider knob
		var _knob_x = clamp(self.x + self.width * self.bar_value - self.knob_width div 2, self.x, self.x + self.width - self.knob_width);
		var _knob_extender = 1;
		if !is_undefined(self.style.sprite_slider_knob) {
			draw_sprite_stretched_ext(self.style.sprite_slider_knob, 0, _knob_x - _knob_extender, self.y - _knob_extender, self.knob_width + _knob_extender*2, self.height + _knob_extender*2, _blend_secondary, 1);
		}
		
		// Knob border
		if !is_undefined(self.style.sprite_slider_knob_border) {
			draw_sprite_stretched_ext(self.style.sprite_slider_knob_border, 0, _knob_x - _knob_extender, self.y - _knob_extender, self.knob_width + _knob_extender*2, self.height + _knob_extender*2, _blend_border, 1);
		}
	}
	
	self.addEvent(LUI_EV_CREATE, function(_element) {
		_element._initKnobWidth();
	});
	
	self.addEvent(LUI_EV_MOUSE_WHEEL, function(_element) {
		var _wheel_step = max(_element.rounding, (_element.max_value - _element.min_value) * 0.02);
		var _wheel_up = mouse_wheel_up() ? 1 : 0;
		var _wheel_down = mouse_wheel_down() ? 1 : 0;
		var _wheel = _wheel_up - _wheel_down;
		var _new_value = clamp(_element.value + _wheel * _wheel_step, _element.min_value, _element.max_value);
		_new_value = _element._calculateValue(_new_value);
		_element.set(_new_value);
	});
	
	self.addEvent(LUI_EV_VALUE_UPDATE, function(_element) {
		_element.callback(); //???//обратная совместимость
		// Animate knob slider
		var _target_bar_value = Range(_element.value, _element.min_value, _element.max_value, 0, 1);
		_element.main_ui.animate(_element, "bar_value", _target_bar_value, 0.1);
	});
	
	self.addEvent(LUI_EV_DRAGGING, function(_element, _data) {
		var x1 = _element.x;
		var x2 = x1 + _element.width;
		var _new_value = _element._calculateValue((_data.mouse_x - x1) / (x2 - x1) * (_element.max_value - _element.min_value) + _element.min_value);
		_element.set(_new_value);
	});
}