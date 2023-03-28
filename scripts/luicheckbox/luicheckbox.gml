///@arg {Any} x
///@arg {Any} y
///@arg {Any} width
///@arg {Any} height
///@arg {Bool} value
///@arg {Function} callback
function LuiCheckbox(x, y, width, height, value = false, callback = undefined) : LuiBase() constructor {
	self.name = "LuiButton";
	self.value = value;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width ?? self.min_width;
	self.height = height ?? self.min_height;
	self.max_width = width;
	self.max_height = height;
	
	self.checkbox_color = self.style.color_main;
	self.can_pressed = false;
	
	set_callback(callback);
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		var _color = self.value ? self.style.color_checkbox_pin : self.checkbox_color;
		var _pin_margin = 6;
		if !is_undefined(self.style.sprite_button) draw_sprite_stretched_ext(self.style.sprite_button, 0, draw_x + _pin_margin, draw_y + _pin_margin, width - _pin_margin*2, height - _pin_margin*2, _color, 1);
		if !is_undefined(self.style.sprite_button_border) draw_sprite_stretched_ext(self.style.sprite_button_border, 0, draw_x, draw_y, width, height, self.style.color_border, 1);
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