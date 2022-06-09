function LuiCheckbox(x = LUI_AUTO, y = LUI_AUTO, width = 16, height = 16, value = false, callback = undefined) : LuiBase() constructor {
	self.name = "LuiButton";
	self.value = value;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	
	self.checkbox_color = c_white;
	self.can_pressed = false;
	
	if callback == undefined {
		self.callback = function() {print(self.value)};
	} else {
		self.callback = method(self, callback);
	}
	
	self.draw = function() {
		var _color = self.value ? c_green : self.checkbox_color;
		draw_sprite_stretched_ext(LUI_SPRITE_BUTTON, 0, x, y, width, height, _color, 1);
		draw_sprite_stretched_ext(LUI_SPRITE_BUTTON_BORDER, 0, x, y, width, height, c_gray, 1);
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
			}
		} else {
			self.checkbox_color = c_white;
			self.can_pressed = false;
		}
		
	}
}