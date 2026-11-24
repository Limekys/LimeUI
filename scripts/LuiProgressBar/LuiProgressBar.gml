///@desc A progress bar for display loading/filling anything
/// Available parameters:
/// value
/// min_value
/// max_value
/// rounding
/// display_value
/// bar_height
/// color - custom bar accent color
///@arg {Struct} [_params] Struct with parameters
function LuiProgressBar(_params = {}) : LuiBase(_params) constructor {
	// STATE

	self.value = _params[$ "value"] ?? 0;
	self.min_value = min(_params[$ "min_value"] ?? 0, _params[$ "max_value"] ?? 100);
	self.max_value = max(_params[$ "min_value"] ?? 0, _params[$ "max_value"] ?? 100);
	self.rounding = _params[$ "rounding"] ?? 0;
	self.display_value = _params[$ "display_value"] ?? true;
	self.bar_height = _params[$ "bar_height"] ?? LUI_AUTO;
	self.bar_color = _params[$ "color"] ?? undefined;
	
	self.bar_value = 0;
	self._bar_target = self.bar_value;
	
	// PUBLIC API

	///@desc Set min value
	///@arg {real} _min_value
	static setMinValue = function(_min_value) {
		self.min_value = _min_value;
		self.set(self._calculateValue(self.get()));
		self._updateBarTarget();
		self.invalidateCache();
		return self;
	}
	
	///@desc Set max value
	///@arg {real} _max_value
	static setMaxValue = function(_max_value) {
		self.max_value = _max_value;
		self.set(self._calculateValue(self.get()));
		self._updateBarTarget();
		self.invalidateCache();
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
		self._updateBarTarget();
		self.invalidateCache();
		return self;
	}
	
	///@desc Sets bar height
	///@arg {real} _height
	static setBarHeight = function(_height) {
		self.bar_height = _height;
		return self;
	}
	
	///@desc Set custom bar color
	///@arg {any} _color
	static setColor = function(_color) {
		self.bar_color = _color;
		return self;
	}
	
	// INTERNALS

	///@desc Calculate final value with rounding and clamping
	///@ignore
	static _calculateValue = function(_value) {
		var _new_value = self.rounding > 0 ? round(_value / self.rounding) * self.rounding : _value;
		return clamp(_new_value, self.min_value, self.max_value);
	}

	///@ignore
	static _valueAffectsRender = function(_previous, _next) {
		return self._calculateValue(_previous) != self._calculateValue(_next);
	}

	///@ignore
	static _updateBarTarget = function(_immediate = false) {
		var _target = 0;
		if self.max_value > self.min_value {
			_target = Range(self._calculateValue(self.value), self.min_value, self.max_value, 0, 1);
		}
		if _immediate || is_undefined(self.main_ui) {
			self.bar_value = _target;
		} else if _target != self._bar_target {
			self.main_ui.animate(self, "bar_value", _target, 0.1);
		}
		self._bar_target = _target;
	}
	
	// DRAW

	self.draw = function() {
		var _style = self.getStyle();
		var _alpha = draw_get_alpha();
		// Calculate colors
		var _blend_back = _style.color_back;
		var _blend_accent = !is_undefined(self.bar_color) ? self.bar_color : _style.color_accent;
		var _blend_text = _style.color_text;
		var _blend_border = _style.color_border;
		if self.deactivated {
			_blend_back = merge_color(_blend_back, c_black, 0.5);
			_blend_accent = merge_color(_blend_accent, c_black, 0.5);
			_blend_text = merge_color(_blend_text, c_black, 0.5);
		}
		
		// Calculate bar position and size
		var _bar_height = self.bar_height == LUI_AUTO ? self.height : self.bar_height;
		var _bar_x = self.x;
		var _bar_y = self.y + (self.height - _bar_height) div 2;
		var _bar_w = self.width;
		var _bar_h = _bar_height;
		
		// Base
		if !is_undefined(_style.sprite_progress_bar) {
			draw_sprite_stretched_ext(_style.sprite_progress_bar, 0, _bar_x, _bar_y, _bar_w, _bar_h, _blend_back, _alpha);
		}
		
		// Bar value
		if !is_undefined(_style.sprite_progress_bar_value) {
			draw_sprite_stretched_ext(_style.sprite_progress_bar_value, 0, _bar_x, _bar_y, _bar_w * self.bar_value, _bar_h, _blend_accent, _alpha);
		}
		
		// Border
		if !is_undefined(_style.sprite_progress_bar_border) {
			draw_sprite_stretched_ext(_style.sprite_progress_bar_border, 0, _bar_x, _bar_y, _bar_w, _bar_h, _blend_border, _alpha);
		}
		
		// Text value
		if self.display_value {
			if !is_undefined(_style.font_default) {
				draw_set_font(_style.font_default);
			}
			draw_set_color(_blend_text);
			draw_set_alpha(_alpha);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_text(self.x + self.width div 2, self.y + self.height div 2, self._calculateValue(self.value));
		}
	}
	
	// EVENT HANDLERS

	self.addEvent(LUI_EV_CREATE, function(_e) {
		_e.value = _e._calculateValue(_e.value);
		_e._updateBarTarget(true);
	});
	
	self.addEvent(LUI_EV_VALUE_UPDATE, function(_e) {
		_e._updateBarTarget();
	});
}
