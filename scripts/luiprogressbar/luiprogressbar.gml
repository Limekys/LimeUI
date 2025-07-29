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
	
	///@desc Set min value
	///@arg {real} _min_value
	static setMinValue = function(_min_value) {
		self.min_value = _min_value;
		self.set(self._calcValue(self.get()));
		return self;
	}
	
	///@desc Set max value
	///@arg {real} _max_value
	static setMaxValue = function(_max_value) {
		self.max_value = _max_value;
		self.set(self._calcValue(self.get()));
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
	
	///@ignore
	static _calcValue = function(_value) {
		var _new_value = 0;
		if self.rounding > 0 {
			_new_value = round(_value / (self.rounding)) * (self.rounding);
		} else {
			_new_value = _value;
		}
		return clamp(_new_value, self.min_value, self.max_value);
	}
	
	self.draw = function() {
		//Base
		if !is_undefined(self.style.sprite_progress_bar) {
			var _blend_color = self.style.color_back;
			if self.deactivated {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_progress_bar, 0, self.x, self.y, width, height, _blend_color, 1);
		}
		//Bar value
		if !is_undefined(self.style.sprite_progress_bar_value) {
			var _bar_value = Range(self.value, self.min_value, self.max_value, 0, 1);
			var _blend_color = self.style.color_accent;
			if self.deactivated {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_progress_bar_value, 0, self.x, self.y, width * _bar_value, height, _blend_color, 1);
		}
		//Border
		if !is_undefined(self.style.sprite_progress_bar_border) {
			draw_sprite_stretched_ext(self.style.sprite_progress_bar_border, 0, self.x, self.y, width, height, self.style.color_border, 1);
		}
		
		//Text value
		if self.display_value {
			if !is_undefined(self.style.font_default) draw_set_font(self.style.font_default);
			if !self.deactivated {
				draw_set_color(self.style.color_text);
			} else {
				draw_set_color(merge_color(self.style.color_text, c_black, 0.5));
			}
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_text(self.x + self.width div 2, self.y + self.height div 2, _calcValue(self.value));
		}
	}
	
	self.addEventListener(LUI_EV_CREATE, function(_element) {
		_element.value = _calcValue(_element.value);
	});
}