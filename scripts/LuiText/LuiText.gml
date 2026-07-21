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
	
	self.draw = function() {
		//Set font properties
		if !is_undefined(self.style.font_default) {
			draw_set_font(self.style.font_default);
		}
		if !self.deactivated {
			draw_set_color(self.style.color_text);
		} else {
			draw_set_color(merge_color(self.style.color_text, c_black, 0.5));
		}
		draw_set_alpha(1);
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
					var _text = self.value;
					var _xscale = self.width / string_width(_text);
					var _yscale = self.height / string_height(_text);
					var _scale = min(_xscale, _yscale);
					
					// Limit scaling to zoom out only (optional, but recommended for UI)
					_scale = min(_scale, 1.0); 
					
					draw_text_transformed(_txt_x, _txt_y, _text, _scale, _scale, 0);
					break; 
				
				case LUI_TEXT_OVERFLOW.WrapScale:
					var _text = self.value;
					var _target_w = self.width;
					var _target_h = self.height;
					
					// 1. Check if text fits at scale 1.0
					var _h_at_1 = string_height_ext(_text, -1, _target_w);
					var _scale = 1.0;
					
					if (_h_at_1 > _target_h) {
						// 2. Binary search for the optimal scale
						var _low = 0.1;  // Minimum scale (10%, to prevent text from disappearing completely)
						var _high = 1.0; // Maximum scale (100%)
						
						// 10 iterations give ~0.1% precision, which is more than enough for UI
						for (var i = 0; i < 10; i++) {
							var _mid = (_low + _high) / 2;
							
							// Effective width in "unscaled" pixels
							var _eff_w = _target_w / _mid;
							
							// Text height at this effective width (without scale applied)
							var _unscaled_h = string_height_ext(_text, -1, _eff_w);
							
							// Actual height after applying scale
							var _scaled_h = _unscaled_h * _mid;
							
							if (_scaled_h <= _target_h) {
								_scale = _mid; // Fits within height, try to increase scale
								_low = _mid;
							} else {
								_high = _mid; // Too tall, decrease scale
							}
						}
					}
					
					// 3. Draw text with wrapping and scaling
					// IMPORTANT: the width parameter (w) in draw_text_ext_transformed is specified 
					// in "unscaled" coordinates, so we divide the target width by the scale
					var _draw_w = _target_w / _scale;
					draw_text_ext_transformed(_txt_x, _txt_y, _text, -1, _draw_w, _scale, _scale, 0);
					break;
			}
		}
	}
}