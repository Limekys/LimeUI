///@arg {Any} x
///@arg {Any} y
///@arg {Any} width
///@arg {Any} height
///@arg {Bool} value
///@arg {Function} callback
function LuiCheckbox(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, value = false, callback = undefined) : LuiBase() constructor {
	
	self.name = "LuiButton";
	self.value = value;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	init_element();
	set_callback(callback);
	
	//Make the maximum size of the checkbox minimal so that it does not stretch at auto size
	if self.auto_width == true || self.auto_height == true {
		self.max_width = self.min_width;
		self.max_height = self.min_height;
	}
	
	self.is_pressed = false;
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		var _color = self.value ? self.style.color_checkbox_pin : self.style.color_main;
		if self.mouse_hover() _color = merge_colour(_color, self.style.color_hover, 0.5);
		var _pin_margin = 6;
		if !is_undefined(self.style.sprite_button) draw_sprite_stretched_ext(self.style.sprite_button, 0, draw_x + _pin_margin, draw_y + _pin_margin, width - _pin_margin*2, height - _pin_margin*2, _color, 1);
		if !is_undefined(self.style.sprite_button_border) draw_sprite_stretched_ext(self.style.sprite_button_border, 0, draw_x, draw_y, width, height, self.style.color_border, 1);
	}
	
	self.step = function() {
		if mouse_hover() { 
			if mouse_check_button_pressed(mb_left) {
				self.is_pressed = true;
			}
			if mouse_check_button_released(mb_left) && self.is_pressed {
				self.is_pressed = false;
				self.set(!self.get());
				self.callback();
				if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
			}
		} else {
			self.is_pressed = false;
		}
		
	}
	
	return self;
}