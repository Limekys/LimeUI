///@arg {Any} x
///@arg {Any} y
///@arg {Any} width
///@arg {Any} height
///@arg {Real} value
///@arg {Function} callback
function LuiCheckbox(x, y, width = 32, height = 32, value = false, callback = undefined) : LuiBase() constructor {
	self.name = "LuiButton";
	self.value = value;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	self.max_width = width;
	self.max_height = height;
	
	self.checkbox_color = self.style.color_main;
	self.can_pressed = false;
	
	set_callback(callback);
	
	self.draw = function(x = self.x, y = self.y) {
		var _color = self.value ? self.style.color_checkbox_pin : self.checkbox_color;
		var _pin_margin = 6;
		if self.style.sprite_button != undefined draw_sprite_stretched_ext(self.style.sprite_button, 0, x + _pin_margin, y + _pin_margin, width - _pin_margin*2, height - _pin_margin*2, _color, 1);
		if self.style.sprite_button_border != undefined draw_sprite_stretched_ext(self.style.sprite_button_border, 0, x, y, width, height, self.style.color_border, 1);
	}
	
	self.step = function() {
		if mouse_hover() { 
			self.checkbox_color = merge_colour(self.style.color_main, c_gray, 0.5);
			if mouse_check_button_pressed(mb_left) {
				self.can_pressed = true;
			}
			if mouse_check_button(mb_left) {
				self.checkbox_color = merge_colour(self.style.color_main, c_black, 0.5);
			}
			if mouse_check_button_released(mb_left) && self.can_pressed {
				self.set(!self.get());
				self.callback();
				if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
			}
		} else {
			self.checkbox_color = self.style.color_main;
			self.can_pressed = false;
		}
		
	}
	
	return self;
}