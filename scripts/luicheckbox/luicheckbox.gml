///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {Bool} value
///@arg {Function} callback
function LuiCheckbox(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, value = false, callback = undefined) : LuiBase() constructor {
	
	self.name = "LuiCheckbox";
	self.value = value;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	init_element();
	set_callback(callback);
	
	self.is_pressed = false;
	
	self.create = function() {
		self.pin_margin = self.style.checkbox_pin_margin;
	}
	
	//Make the maximum size of the checkbox minimal so that it does not stretch at auto size
	if self.auto_width == true || self.auto_height == true {
		self.max_width = self.min_width;
		self.max_height = self.min_height;
	}
	
	static set_pin_margin = function(_value) {
		self.pin_margin = _value;
		return self;
	}
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		//Base
		if !is_undefined(self.style.sprite_checkbox) {
			draw_sprite_stretched_ext(self.style.sprite_checkbox, 0, draw_x, draw_y, self.width, self.height, self.style.color_checkbox, 1);
		}
		//Pin
		if !is_undefined(self.style.sprite_checkbox_pin) {
			var _color = self.value ? self.style.color_checkbox_pin : self.style.color_checkbox;
			if !self.deactivated && self.mouse_hover() {
				_color = merge_colour(_color, self.style.color_hover, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_checkbox_pin, 0, draw_x + self.pin_margin, draw_y + self.pin_margin, self.width - self.pin_margin*2, self.height - self.pin_margin*2, _color, 1);
		}
		//Border
		if !is_undefined(self.style.sprite_checkbox_border) {
			draw_sprite_stretched_ext(self.style.sprite_checkbox_border, 0, draw_x, draw_y, self.width, self.height, self.style.color_checkbox_border, 1);
		}
	}
	
	self.on_mouse_left_pressed = function() {
		self.is_pressed = true;
	}
	
	self.on_mouse_left_released = function() {
		if self.is_pressed {
			self.is_pressed = false;
			self.set(!self.get());
			self.callback();
			if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
		}
	}
	
	self.step = function() {
		if !mouse_hover() { 
			self.is_pressed = false;
		}
	}
	
	return self;
}