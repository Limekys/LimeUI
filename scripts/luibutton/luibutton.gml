///@arg {Any} x
///@arg {Any} y
///@arg {Any} width
///@arg {Any} height
///@arg {String} text
///@arg {Function} callback
function LuiButton(x, y, width, height, text = "button", callback = undefined) : LuiBase() constructor {
	
	if !is_undefined(self.style.font_buttons) draw_set_font(self.style.font_buttons); //Need to be called for right calculations
	
	self.name = "LuiButton";
	self.text = text;
	self.value = text;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height ?? self.min_height;
	self.min_width = (width == undefined) ? string_width(text) + self.style.padding : width;
	
	self.button_color = self.style.color_button;
	self.is_pressed = false;
	
	set_callback(callback);
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		//Base
		if !is_undefined(self.style.sprite_button)
		draw_sprite_stretched_ext(self.style.sprite_button, 0, draw_x, draw_y, width, height, self.button_color, 1);
		
		//Text
		if !is_undefined(self.style.font_buttons) draw_set_font(self.style.font_buttons);
		draw_set_alpha(1);
		if self.deactivated draw_set_color(merge_color(self.style.color_font, c_gray, 0.5)) else draw_set_color(self.style.color_font);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		var _txt_x = draw_x + self.width / 2;
		var _txt_y = draw_y + self.height / 2;
		draw_text(_txt_x, _txt_y, self.text);
		
		//Border
		if !is_undefined(self.style.sprite_button_border)
		draw_sprite_stretched_ext(self.style.sprite_button_border, 0, draw_x, draw_y, width, height, self.style.color_button_border, 1);
	}
	
	self.step = function() {
		if self.deactivated {
			self.button_color = merge_color(self.style.color_button, c_black, 0.5);
		} else {
			if mouse_hover() { 
				self.button_color = merge_colour(self.style.color_button, self.style.color_hover, 0.5);
				if mouse_check_button_pressed(mb_left) {
					self.is_pressed = true;
				}
				if mouse_check_button(mb_left) {
					self.button_color = merge_colour(self.style.color_button, c_black, 0.5);
				}
				if mouse_check_button_released(mb_left) && self.is_pressed {
					self.callback();
					if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
				}
			} else {
				self.button_color = self.style.color_button;
				self.is_pressed = false;
			}
		}
	}
	
	///@func set_color(main, border)
	self.set_color = function(main = undefined, border = undefined) {
		if !is_undefined(main) self.style.color_button = main;
		if !is_undefined(border) self.style.color_button_border = border;
		return self;
	}
	
	return self;
}