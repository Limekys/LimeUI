///@arg {Any} x
///@arg {Any} y
///@arg {Asset.GMSprite} sprite
///@arg {Real} index
///@arg {Real} scale
///@arg {Function} callback
function LuiSpriteButton(x, y, sprite, index = 0, scale = 1, callback = undefined) : LuiBase() constructor {
	self.name = "LuiSpriteButton";
	self.pos_x = x;
	self.pos_y = y;
	
	self.sprite = sprite;
	self.index = index;
	self.scale = scale;
	
	self.width = sprite_get_width(sprite) * self.scale;
	self.height = sprite_get_height(sprite) * self.scale;
	self.min_width = self.width;
	self.min_height = self.height;
	self.max_width = self.width;
	self.max_height = self.height;
	
	self.button_color = self.style.color_main;
	self.is_pressed = false;
	
	if callback == undefined {
		self.callback = function() {print(self.name)};
	} else {
		self.callback = method(self, callback);
	}
	
	self.draw = function(x = self.x, y = self.y) {
		draw_sprite_ext(self.sprite, self.index, x, y, self.scale, self.scale, 0, self.button_color, 1);
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
				if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
			}
		} else {
			self.button_color = self.style.color_main;
			self.is_pressed = false;
		}
		
	}
	
	return self;
}