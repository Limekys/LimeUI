function LuiSpriteButton(x = LUI_AUTO, y = LUI_AUTO, sprite, index = 0, scale = 1, color_blend = c_white, callback = undefined) : LuiBase() constructor {
	self.name = "LuiSpriteButton";
	self.pos_x = x;
	self.pos_y = y;
	
	self.sprite = sprite;
	self.index = index;
	self.scale = scale;
	self.color_blend = color_blend;
	
	self.width = sprite_get_width(sprite) * self.scale;
	self.height = sprite_get_height(sprite) * self.scale;
	
	self.button_color = self.color_blend;
	self.is_pressed = false;
	
	if callback == undefined {
		self.callback = function() {print(self.name)};
	} else {
		self.callback = method(self, callback);
	}
	
	self.draw = function() {
		draw_sprite_ext(self.sprite, self.index, self.x, self.y, self.scale, self.scale, 0, self.button_color, 1);
	}
	
	self.step = function() {
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
			}
		} else {
			self.button_color = self.color_blend;
			self.is_pressed = false;
		}
		
	}
}