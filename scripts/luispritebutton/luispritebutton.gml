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
	self.color_blend = c_white;
	
	self.width = sprite_get_width(sprite) * self.scale;
	self.height = sprite_get_height(sprite) * self.scale;
	self.min_width = sprite_get_width(sprite) * self.scale;
	self.min_height = sprite_get_height(sprite) * self.scale;
	
	self.button_color = self.color_blend;
	self.is_pressed = false;
	
	set_callback(callback);
	
	self.set_color_blend = function(color_blend) {
		self.color_blend = color_blend;
	}
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		draw_sprite_ext(self.sprite, self.index, draw_x, draw_y, self.scale, self.scale, 0, self.button_color, 1);
	}
	
	self.step = function() {
		if mouse_hover() { 
			self.button_color = merge_colour(self.color_blend, self.style.color_hover, 0.5);
			if mouse_check_button_pressed(mb_left) {
				self.is_pressed = true;
			}
			if mouse_check_button(mb_left) {
				self.button_color = merge_colour(self.color_blend, c_black, 0.5);
			}
			if mouse_check_button_released(mb_left) && self.is_pressed {
				self.callback();
				if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
			}
		} else {
			self.button_color = self.color_blend;
			self.is_pressed = false;
		}
		
	}
	
	return self;
}