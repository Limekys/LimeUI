///@desc A switch in the form of a small slider that can be in the on and off position
/// Available parameters:
/// text
/// value
///@arg {Struct} [_params] Struct with parameters
function LuiToggleSwitch(_params = {}) : LuiBase(_params) constructor {
	
	self.value = _params[$ "value"] ?? false;
	self.text = _params[$ "text"] ?? "";
	
	self.knob_size = 32;
	self.knob_xoffset = 0;
	self.slider_color_value = 0;
	self.draw_width = 0;
	self.draw_height = 0;
	
	///@desc Set display text (render right of element)
	///@arg {string} _text
	static setText = function(_text) {
		self.text = _text;
		return self;
	}
	
	///@ignore
	static _updateSlider = function() {
		var _sprite_height = is_undefined(self.style.sprite_toggleswitch) ? self.height : sprite_get_height(self.style.sprite_toggleswitch);
		self.draw_height = floor(min(self.height, self.width / 2, _sprite_height));
		self.draw_width = floor(self.draw_height * 2);
		self.knob_size = self.draw_height;
		if self.value == false {
			self.slider_color_value = 0;
			self.knob_xoffset = 0;
		} else {
			self.slider_color_value = 1;
			self.knob_xoffset = self.draw_width - self.knob_size;
		}
	}
	
	self.draw = function() {
		// Align slider position
		var _slider_x = self.x;
		var _slider_y = floor(self.y + (self.height - self.draw_height) / 2);
		
		// Base
		if !is_undefined(self.style.sprite_toggleswitch) {
			var _blend_color = merge_color(self.style.color_back, self.style.color_accent, self.slider_color_value);
			if self.deactivated {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_toggleswitch, 0, _slider_x, _slider_y, self.draw_width, self.draw_height, _blend_color, 1);
		}
		// Knob
		if !is_undefined(self.style.sprite_toggleswitch_slider) {
			var _blend_color = self.style.color_primary;
			if !self.deactivated {
				if self.isMouseHovered() {
					_blend_color = merge_color(_blend_color, self.style.color_hover, 0.5);
				}
			} else {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_toggleswitch_slider, 0, _slider_x + self.knob_xoffset, _slider_y, self.knob_size, self.knob_size, _blend_color, 1);
		}
		// Knob border
		if !is_undefined(self.style.sprite_toggleswitch_slider_border) {
			draw_sprite_stretched_ext(self.style.sprite_toggleswitch_slider_border, 0, _slider_x + self.knob_xoffset, _slider_y, self.knob_size, self.knob_size, self.style.color_border, 1);
		}
		// Border
		if !is_undefined(self.style.sprite_toggleswitch_border) {
			draw_sprite_stretched_ext(self.style.sprite_toggleswitch_border, 0, _slider_x, _slider_y, self.draw_width, self.draw_height, self.style.color_border, 1);
		}
		// Text
		if self.text != "" {
			if !self.deactivated {
				draw_set_color(self.style.color_text);
			} else {
				draw_set_color(merge_color(self.style.color_text, c_black, 0.5));
			}
			draw_set_alpha(1);
			draw_set_halign(fa_left);
			draw_set_valign(fa_middle);
			if !is_undefined(self.style.font_default) {
				draw_set_font(self.style.font_default);
			}
			var _text_width = min(string_width(self.text), self.width - self.draw_width - self.style.gap);
			var _text_x = _slider_x + self.draw_width + self.style.gap;
			self._drawTruncatedText(_text_x, self.y + self.height / 2, self.text, _text_width);
		}
	}
	
	self.addEvent(LUI_EV_CREATE, function(_e) {
		_e._updateSlider();
	});
	
	self.addEvent(LUI_EV_CLICK, function(_e) {
		_e.set(!_e.get());
		if _e.style.sound_click != undefined audio_play_sound(_e.style.sound_click, 1, false);
	});
	
	self.addEvent(LUI_EV_SIZE_UPDATE, function(_e) {
		_e._updateSlider();
	});
	
	self.addEvent(LUI_EV_VALUE_UPDATE, function(_e) {
		var _anim_time = 0.2;
		// Slider animation
		var _target_knob_xoffset = _e.value == false ? 0 : _e.draw_width - _e.knob_size;
		_e.main_ui.animate(_e, "knob_xoffset", _target_knob_xoffset, _anim_time);
		// Slider back color animation
		var _target_color_value = _e.value == true ? 1 : 0;
		_e.main_ui.animate(_e, "slider_color_value", _target_color_value, _anim_time);
	});
}