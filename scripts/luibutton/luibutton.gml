///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} text
///@arg {Function} callback
function LuiButton(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, text = "button", callback = undefined) : LuiBase() constructor {
	
	self.name = "LuiButton";
	self.text = text;
	self.value = text;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	init_element();
	set_callback(callback);
	
	self.is_pressed = false;
	self.button_color = undefined;
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		//Base
		if !is_undefined(self.style.sprite_button) {
			var _blend_color = self.style.color_button;
			if !is_undefined(self.button_color) _blend_color = self.button_color;
			if !self.deactivated && self.mouse_hover() {
				_blend_color = merge_colour(_blend_color, self.style.color_hover, 0.5);
				if self.is_pressed == true {
					_blend_color = merge_colour(_blend_color, c_black, 0.5);
				}
			}
			draw_sprite_stretched_ext(self.style.sprite_button, 0, draw_x, draw_y, self.width, self.height, _blend_color, 1);
		}
		
		//Text
		if self.text != "" {
			if !is_undefined(self.style.font_buttons) {
				draw_set_font(self.style.font_buttons);
			}
			draw_set_alpha(1);
			draw_set_color(self.style.color_font);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			var _txt_x = draw_x + self.width / 2;
			var _txt_y = draw_y + self.height / 2;
			_lui_draw_text_cutoff(_txt_x, _txt_y, self.text, self.width);
		}
		
		//Border
		if !is_undefined(self.style.sprite_button_border) {
			draw_sprite_stretched_ext(self.style.sprite_button_border, 0, draw_x, draw_y, self.width, self.height, self.style.color_button_border, 1);
		}
	}
	
	self.step = function() {
		if mouse_hover() { 
			if mouse_check_button_pressed(mb_left) {
				self.is_pressed = true;
			}
			if mouse_check_button_released(mb_left) && self.is_pressed {
				self.is_pressed = false;
				self.callback();
				if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
			}
		} else {
			self.is_pressed = false;
		}
	}
	
	///@func set_color(_button_color)
	///@arg _button_color
	self.set_color = function(_button_color) {
		self.button_color = _button_color;
		return self;
	}
	
	return self;
}