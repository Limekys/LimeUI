/// @enum LuiTextOverflow
enum LUI_TEXT_OVERFLOW {
    Clip,       // Clip and add "..." at the end
    Wrap,       // Wrap by words
    Scale,      // Scale text size to fit all width of element
	WrapScale   // Wrap by words, and scale down if it still exceeds element height
}

///@desc Just a text.
/// Available parameters:
/// value
/// text_halign
/// text_valign
/// overflow (LuiTextOverflow enum)
/// scale_to_fit (deprecated)
///@arg {Struct} [_params] Struct with parameters
function LuiText(_params = {}) : LuiBase(_params) constructor {
	
	self.value = string(_params[$ "value"] ?? "");
	self.text_halign = _params[$ "text_halign"] ?? fa_left;
	self.text_valign = _params[$ "text_valign"] ?? fa_middle;
	self.overflow = _params[$ "overflow"] ?? LUI_TEXT_OVERFLOW.Clip;
	
	self.scale_to_fit = _params[$ "scale_to_fit"] ?? false; // deprecated variable
	
	// Layout cache for Scale / WrapScale
	self._lc_value = "";
	self._lc_w = -1;
	self._lc_h = -1;
	self._lc_font = -1;
	self._lc_overflow = -1;
	self._lc_scale = 1;
	
	///@desc Set text
	///@arg {string} _text
	static setText = function(_text) {
		self.set(_text);
		return self;
	}
	
	///@desc Set horizontal aligment of text.
	///@arg {constant.HAlign} _halign
	static setTextHalign = function(_halign) {
		self.text_halign = _halign;
		return self;
	}
	
	///@desc Set vertical aligment of text.
	///@arg {constant.VAlign} _valign
	static setTextValign = function(_valign) {
		self.text_valign = _valign;
		return self;
	}
	
	///@desc Set scale to fit text
	///@arg {bool} _scale_to_fit True is scale text to fit element size
	///@deprecated
	static setScaleToFit = function(_scale_to_fit) {
		self.setOverflow(LUI_TEXT_OVERFLOW.Scale);
		return self;
	}
	
	///@desc Set text overflow mode
	///@arg {enum.LUI_TEXT_OVERFLOW} _mode
	static setOverflow = function(_mode) {
		self.overflow = _mode;
		return self;
	}
	
	///@desc Recalculates text scale only if text, size, font or overflow mode changed
	///@ignore
	static _updateScaleCache = function() {
		var _font = draw_get_font();
		if (self._lc_value == self.value && self._lc_w == self.width && self._lc_h == self.height
			&& self._lc_font == _font && self._lc_overflow == self.overflow) {
			return;
		}
		self._lc_value = self.value;
		self._lc_w = self.width;
		self._lc_h = self.height;
		self._lc_font = _font;
		self._lc_overflow = self.overflow;
		
		var _text = self.value;
		var _scale = 1.0;
		if (_text != "") {
			if (self.overflow == LUI_TEXT_OVERFLOW.Scale) {
				_scale = min(1.0, self.width / string_width(_text), self.height / string_height(_text));
			} else if (self.overflow == LUI_TEXT_OVERFLOW.WrapScale) {
				var _target_w = self.width;
				var _target_h = self.height;
				if (string_height_ext(_text, -1, _target_w) > _target_h) {
					var _low = 0.1;
					var _high = 1.0;
					for (var i = 0; i < 10; i++) {
						var _mid = (_low + _high) / 2;
						var _scaled_h = string_height_ext(_text, -1, _target_w / _mid) * _mid;
						if (_scaled_h <= _target_h) {
							_scale = _mid;
							_low = _mid;
						} else {
							_high = _mid;
						}
					}
				}
			}
		}
		self._lc_scale = _scale;
	}
	
	self.draw = function() {
		var _style = self.getStyle();
		var _alpha = draw_get_alpha();
		//Set font properties
		if !is_undefined(_style.font_default) {
			draw_set_font(_style.font_default);
		}
		if !self.deactivated {
			draw_set_color(_style.color_text);
		} else {
			draw_set_color(merge_color(_style.color_text, c_black, 0.5));
		}
		draw_set_alpha(_alpha);
		draw_set_halign(self.text_halign);
		draw_set_valign(self.text_valign);
		//Calculate right text align
		var _txt_x = 0;
		var _txt_y = 0;
		switch(self.text_halign) {
			case fa_left: 
				_txt_x = self.x;
			break;
			case fa_center:
				_txt_x = self.x + self.width / 2;
			break;
			case fa_right: 
				_txt_x = self.x + self.width;
			break;
		}
		switch(self.text_valign) {
			case fa_top: 
				_txt_y = self.y;
			break;
			case fa_middle:
				_txt_y = self.y + self.height / 2;
			break;
			case fa_bottom: 
				_txt_y = self.y + self.height;
			break;
		}
		//Draw text
		if self.value != "" {
			switch(self.overflow) {
				case LUI_TEXT_OVERFLOW.Clip:
					self._drawTruncatedText(_txt_x, _txt_y, self.value, self.width);
					break;
					
				case LUI_TEXT_OVERFLOW.Wrap:
					draw_text_ext(_txt_x, _txt_y, self.value, -1, self.width);
					break;
					
				case LUI_TEXT_OVERFLOW.Scale:
					self._updateScaleCache();
					draw_text_transformed(_txt_x, _txt_y, self.value, self._lc_scale, self._lc_scale, 0);
					break; 
				
				case LUI_TEXT_OVERFLOW.WrapScale:
					self._updateScaleCache();
					// width in draw_text_ext_transformed is in "unscaled" coordinates
					draw_text_ext_transformed(_txt_x, _txt_y, self.value, -1, self.width / self._lc_scale, self._lc_scale, self._lc_scale, 0);
					break;
			}
		}
	}
}