///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {Asset.GMSprite} sprite
///@arg {Real} subimg
///@arg {Real} color
///@arg {Real} alpha
///@arg {Bool} maintain_aspect
///@arg {Function} callback
function LuiSpriteButton(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, sprite, subimg = 0, color = c_white, alpha = 1, maintain_aspect = true, callback = undefined) : LuiBase() constructor {
	self.name = "LuiSpriteButton";
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	init_element();
	set_callback(callback);
	
	self.value = sprite;
	self.sprite = sprite;
	self.subimg = subimg;
	self.alpha = alpha;
	self.color_blend = color;
	
	self.sprite_real_width = sprite_get_width(self.sprite);
	self.sprite_real_height = sprite_get_height(self.sprite);
	self.maintain_aspect = maintain_aspect;
	self.aspect = self.sprite_real_width / self.sprite_real_height;
	
	self.button_color = self.color_blend;
	self.is_pressed = false;
	
	self.set_color_blend = function(color_blend) {
		self.color_blend = color_blend;
	}
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		var _width = self.width;
		var _height = self.height;
		if self.maintain_aspect {
			if _width / self.aspect <= self.height  {
				_height = _width / self.aspect;
			} else {
				_width = _height * self.aspect;
			}
		}
		draw_sprite_stretched_ext(self.sprite, self.subimg, 
									draw_x + self.width/2 - _width/2, 
									draw_y + self.height/2 - _height/2, 
									_width-1, _height-1, 
									self.button_color, self.alpha);
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