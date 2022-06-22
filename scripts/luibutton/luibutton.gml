function LuiButton(x = LUI_AUTO, y = LUI_AUTO, width = 128, height = 32, text = "button", callback = undefined) : LuiBase() constructor {
	self.name = "LuiButton";
	self.text = text;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	draw_set_font(LUI_FONT_BUTTONS);
	self.min_width = string_width(text);
	self.blend_color = LUI_COLOR_MAIN;
	
	self.button_color = self.blend_color;
	self.is_pressed = false;
	self.deactivated = false;
	
	if callback == undefined {
		self.callback = function() {print(self.text)};
	} else {
		self.callback = method(self, callback);
	}
	
	self.activate = function() {
		self.deactivated = false;
		return self;
	}
	self.deactivate = function() {
		self.deactivated = true;
		return self;
	}
	
	self.draw = function() {
		if LUI_SPRITE_BUTTON != undefined draw_sprite_stretched_ext(LUI_SPRITE_BUTTON, 0, x, y, width, height, self.button_color, 1);
		if LUI_SPRITE_BUTTON_BORDER != undefined draw_sprite_stretched_ext(LUI_SPRITE_BUTTON_BORDER, 0, x, y, width, height, LUI_COLOR_BORDER, 1);
		//Text
		draw_set_alpha(1);
		if self.deactivated draw_set_color(c_dkgray) else draw_set_color(LUI_COLOR_FONT);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_font(LUI_FONT_BUTTONS);
		var _txt_x = self.x + self.width / 2;
		var _txt_y = self.y + self.height / 2;
		draw_text(_txt_x, _txt_y, self.text);
	}
	
	self.step = function() {
		if self.deactivated {
			self.button_color = c_gray;
		} else {
			if mouse_hover() { 
				self.button_color = c_ltgray;
				if mouse_check_button_pressed(mb_left) {
					self.is_pressed = true;
				}
				if mouse_check_button(mb_left) {
					self.button_color = c_gray;
				}
				if mouse_check_button_released(mb_left) && self.is_pressed {
					self.callback();
					if LUI_CLICK_SOUND != undefined audio_play_sound(LUI_CLICK_SOUND, 1, false);
				}
			} else {
				self.button_color = self.blend_color;
				self.is_pressed = false;
			}
		}
	}
}