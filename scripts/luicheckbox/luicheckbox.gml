///@desc A button with a boolean value, either marked or unmarked.
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
///@arg {Bool} value
///@arg {Function} callback
function LuiCheckbox(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = "LuiCheckbox", value = false, callback = undefined) : LuiBase() constructor {
	
	self.name = name;
	self.value = value;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	initElement();
	setCallback(callback);
	
	self.is_pressed = false;
	self.pin_margin = 0;
	
	self.create = function() {
		self.pin_margin = self.style.checkbox_pin_margin;
	}
	
	//Make the maximum size of the checkbox minimal so that it does not stretch at auto size
	if self.auto_width == true || self.auto_height == true {
		self.max_width = self.min_width;
		self.max_height = self.min_height;
	}
	
	static setPinMargin = function(_value) {
		self.pin_margin = _value;
		return self;
	}
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		//Base
		if !is_undefined(self.style.sprite_checkbox) {
			var _blend_color = self.style.color_checkbox;
			if self.deactivated {
				_blend_color = merge_colour(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_checkbox, 0, draw_x, draw_y, self.width, self.height, _blend_color, 1);
		}
		//Pin
		if !is_undefined(self.style.sprite_checkbox_pin) {
			var _blend_color = self.value ? self.style.color_checkbox_pin : self.style.color_checkbox;
			if !self.deactivated {
				if self.mouseHover() {
					_blend_color = merge_colour(_blend_color, self.style.color_hover, 0.5);
				}
			} else {
				_blend_color = merge_colour(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_checkbox_pin, 0, draw_x + self.pin_margin, draw_y + self.pin_margin, self.width - self.pin_margin*2, self.height - self.pin_margin*2, _blend_color, 1);
		}
		//Border
		if !is_undefined(self.style.sprite_checkbox_border) {
			draw_sprite_stretched_ext(self.style.sprite_checkbox_border, 0, draw_x, draw_y, self.width, self.height, self.style.color_checkbox_border, 1);
		}
	}
	
	self.onMouseLeftPressed = function() {
		self.is_pressed = true;
	}
	
	self.onMouseLeftReleased = function() {
		if self.is_pressed {
			self.is_pressed = false;
			self.value = !self.value;
			self.callback();
			if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
		}
	}
	
	self.onMouseLeave = function() {
		self.is_pressed = false;
	}
}