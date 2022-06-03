function LUI_Button(x = LUI_AUTO, y = LUI_AUTO, width = 128, height = 32, text = "button", callback = undefined) : LUI_Base() constructor {
	self.text = text;
	self.x = x;
	self.y = y;
	self.width = width;
	self.height = height;
	
	self.button_color = c_white;
	
	if callback == undefined {
		self.callback = function() {print("callback")};
	} else {
		self.callback = method(self, callback);
	}
	
	self.draw = function() {
		draw_sprite_stretched_ext(LUI_SPRITE_BUTTON, 0, x, y, width, height, self.button_color, 1);
		draw_sprite_stretched_ext(LUI_SPRITE_BUTTON_BORDER, 0, x, y, width, height, c_gray, 1);
		//Text
		draw_set_alpha(1);
		draw_set_color(LUI_FONT_COLOR);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_font(LUI_FONT_BUTTONS);
		var _txt_x = self.x + self.width / 2;
		var _txt_y = self.y + self.height / 2;
		draw_text(_txt_x, _txt_y, self.text);
	}
	
	self.step = function() {
		if mouse_hover() { 
			self.button_color = c_ltgray;
			if mouse_check_button(mb_left) {
				self.button_color = c_gray;
			}
			if mouse_check_button_released(mb_left) {
				self.callback();
			}
		} else {
			self.button_color = c_white;
		}
		
	}
}