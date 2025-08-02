///@desc A progress bar for display loading/filling anything
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
///@arg {Real} min_value
///@arg {Real} max_value
///@arg {Bool} display_value
///@arg {Real} value
///@arg {Real} rounding
function LuiProgressBar(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = LUI_AUTO_NAME, min_value = 0, max_value = 100, display_value = true, value = 0, rounding = 0) : LuiBase() constructor {
	
	self.name = name;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	_initElement();
	
	self.value = value;
	self.min_value = min(min_value, max_value);
	self.max_value = max(min_value, max_value);
	self.rounding = rounding;
	self.display_value = display_value;
	self.bar_height = self.height;
	self.bar_value = Range(value, min_value, max_value, 0, 1);
	
	///@desc Set min value
	///@arg {real} _min_value
	static setMinValue = function(_min_value) {
		self.min_value = _min_value;
		self.set(self._calculateValue(self.get()));
		return self;
	}
	
	///@desc Set max value
	///@arg {real} _max_value
	static setMaxValue = function(_max_value) {
		self.max_value = _max_value;
		self.set(self._calculateValue(self.get()));
		return self;
	}
	
	///@desc Set state of value (show/hide)
	///@arg {bool} _display_value True - show value, False - hide value
	static setDisplayValue = function(_display_value) {
		self.display_value = _display_value;
		return self;
	}
	
	///@desc Sets the rounding rule for the value (0 - no rounding, 0.1 - round to tenths...).
	///@arg {real} _rounding
	static setRounding = function(_rounding) {
		self.rounding = _rounding;
		return self;
	}
	
	///@desc Sets bar height
	///@arg {real} _height
	static setBarHeight = function(_height) {
		self.bar_height = _height;
		return self;
	}
	
	///@desc Calculate final value with rounding and clamping
	///@ignore
	static _calculateValue = function(_value) {
		var _new_value = self.rounding > 0 ? round(_value / self.rounding) * self.rounding : _value;
		return clamp(_new_value, self.min_value, self.max_value);
	}
	
	self.draw = function() {
		// Calculate colors
		var _blend_back = self.style.color_back;
		var _blend_accent = self.style.color_accent;
		var _blend_text = self.style.color_text;
		var _blend_border = self.style.color_border;
		if self.deactivated {
			_blend_back = merge_color(_blend_back, c_black, 0.5);
			_blend_accent = merge_color(_blend_accent, c_black, 0.5);
			_blend_text = merge_color(_blend_text, c_black, 0.5);
		}
		
		// Calculate bar position
		var _bar_x = self.x;
		var _bar_y = self.y + (self.height - self.bar_height) div 2;
		var _bar_w = self.width;
		var _bar_h = self.bar_height;
		
		// Base
		if !is_undefined(self.style.sprite_progress_bar) {
			draw_sprite_stretched_ext(self.style.sprite_progress_bar, 0, _bar_x, _bar_y, _bar_w, _bar_h, _blend_back, 1);
		}
		
		// Bar value
		if !is_undefined(self.style.sprite_progress_bar_value) {
			draw_sprite_stretched_ext(self.style.sprite_progress_bar_value, 0, _bar_x, _bar_y, _bar_w * self.bar_value, _bar_h, _blend_accent, 1);
		}
		
		// Border
		if !is_undefined(self.style.sprite_progress_bar_border) {
			draw_sprite_stretched_ext(self.style.sprite_progress_bar_border, 0, _bar_x, _bar_y, _bar_w, _bar_h, _blend_border, 1);
		}
		
		// Text value
		if self.display_value {
			if !is_undefined(self.style.font_default) draw_set_font(self.style.font_default);
			draw_set_color(_blend_text);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_text(self.x + self.width div 2, self.y + self.height div 2, _calculateValue(self.value));
		}
	}
	
	self.addEvent(LUI_EV_CREATE, function(_element) {
		_element.value = _calculateValue(_element.value);
	});
	
	self.addEvent(LUI_EV_VALUE_UPDATE, function(_element) {
		var _target_bar_value = Range(_element.value, _element.min_value, _element.max_value, 0, 1);
		_element.main_ui.animate(_element, "bar_value", _target_bar_value, 0.1);
	});
}