function LuiCheckbox(x, y, width = 24, height = 24, value = false, callback = undefined) : LuiBase() constructor {
	self.name = "LuiButton";
	self.value = value;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	
	self.checkbox_color = LUI_COLOR_MAIN;
	self.can_pressed = false;
	
	if callback == undefined {
		self.callback = function() {print(self.value)};
	} else {
		self.callback = method(self, callback);
	}
	
	self.draw = function() {
		var _color = self.value ? c_green : self.checkbox_color;
		var _pin_margin = 6;
		if LUI_SPRITE_BUTTON != undefined draw_sprite_stretched_ext(LUI_SPRITE_BUTTON, 0, x + _pin_margin, y + _pin_margin, width - _pin_margin*2, height - _pin_margin*2, _color, 1);
		if LUI_SPRITE_BUTTON_BORDER != undefined draw_sprite_stretched_ext(LUI_SPRITE_BUTTON_BORDER, 0, x, y, width, height, LUI_COLOR_BORDER, 1);
	}
	
	self.step = function() {
		if mouse_hover() { 
			self.checkbox_color = c_ltgray;
			if mouse_check_button_pressed(mb_left) {
				self.can_pressed = true;
			}
			if mouse_check_button(mb_left) {
				self.checkbox_color = c_gray;
			}
			if mouse_check_button_released(mb_left) && self.can_pressed {
				self.set(!self.get());
				self.callback();
				if LUI_CLICK_SOUND != undefined audio_play_sound(LUI_CLICK_SOUND, 1, false);
			}
		} else {
			self.checkbox_color = LUI_COLOR_MAIN;
			self.can_pressed = false;
		}
		
	}
}