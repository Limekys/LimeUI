///@desc A switch in the form of a small slider that can be in the on and off position
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
///@arg {Bool} value
///@arg {String} text
///@arg {Function} callback
function LuiToggleSwitch(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = LUI_AUTO_NAME, value = false, text = "", callback = undefined) : LuiBase() constructor {
	
	self.name = name;
	self.value = value;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	_initElement();
	setCallback(callback);
	
	self.is_pressed = false;
	self.text = text;
	self.slider_size = min(self.width, self.height);
	self.slider_xoffset = 0;
	self.slider_color_value = 0;
	
	//@desc Set display text (render right of element)
	static setText = function(_text) {
		self.text = _text;
		return self;
	}
	
	static _updateSlider = function() {
		self.slider_size = min(self.width, self.height);
		if self.value == false {
			self.slider_color_value = 0;
			self.slider_xoffset = 0;
		} else {
			self.slider_color_value = 1;
			var _draw_width = min(self.width, self.height) * 2;
			self.slider_xoffset = _draw_width - self.slider_size;
		}
	}
	
	self.draw = function() {
		self.slider_size = min(self.width, self.height);
		var _draw_width = min(self.width, self.height) * 2;
		var _draw_height = min(self.width, self.height);
		// Base
		if !is_undefined(self.style.sprite_toggleswitch) {
			var _blend_color = merge_color(self.style.color_back, self.style.color_accent, self.slider_color_value);
			if self.deactivated {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_toggleswitch, 0, self.x, self.y, _draw_width, _draw_height, _blend_color, 1);
		}
		// Slider
		if !is_undefined(self.style.sprite_toggleswitch_slider) {
			var _blend_color = self.style.color_primary;
			if !self.deactivated {
				if self.isMouseHovered() {
					_blend_color = merge_color(_blend_color, self.style.color_hover, 0.5);
				}
			} else {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_toggleswitch_slider, 0, self.x + self.slider_xoffset, self.y, self.slider_size, self.slider_size, _blend_color, 1);
		}
		// Slider border
		if !is_undefined(self.style.sprite_toggleswitch_slider_border) {
			draw_sprite_stretched_ext(self.style.sprite_toggleswitch_slider_border, 0, self.x + self.slider_xoffset, self.y, self.slider_size, self.slider_size, self.style.color_border, 1);
		}
		// Border
		if !is_undefined(self.style.sprite_toggleswitch_border) {
			draw_sprite_stretched_ext(self.style.sprite_toggleswitch_border, 0, self.x, self.y, _draw_width, _draw_height, self.style.color_border, 1);
		}
		// Text
		if self.text != "" {
			if !self.deactivated {
				draw_set_color(self.style.color_text);
				//if self.isMouseHovered() {
					//draw_set_color(merge_color(self.style.color_text, self.style.color_hover, 0.5));
				//}
			} else {
				draw_set_color(merge_color(self.style.color_text, c_black, 0.5));
			}
			draw_set_alpha(1);
			draw_set_halign(fa_left);
			draw_set_valign(fa_middle);
			if !is_undefined(self.style.font_default) {
				draw_set_font(self.style.font_default);
			}
			var _text_width = min(string_width(self.text), self.width - _draw_width - self.style.padding);
			self._drawTruncatedText(self.x + _draw_width + self.style.padding, self.y + self.height div 2, self.text, _text_width);
		}
	}
	
	self.onMouseLeftPressed = function() {
		self.is_pressed = true;
	}
	
	self.onMouseLeftReleased = function() {
		if self.is_pressed {
			self.is_pressed = false;
			self.set(!self.value);
			self.callback();
			if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
		}
	}
	
	self.onMouseLeave = function() {
		self.is_pressed = false;
	}
	
	self.onPositionUpdate = function() {
		self._updateSlider();
	}
	
	self.onValueUpdate = function() {
		var _anim_time = 0.2;
		// Slider animation
		var _draw_width = min(self.width, self.height) * 2;
		var _target_slider_xoffset = self.value == false ? 0 : _draw_width - self.slider_size;
		self.main_ui.animate(self, "slider_xoffset", _target_slider_xoffset, _anim_time);
		// Slider back color animation
		var _target_color_value = self.value == true ? 1 : 0;
		self.main_ui.animate(self, "slider_color_value", _target_color_value, _anim_time);
	}
}