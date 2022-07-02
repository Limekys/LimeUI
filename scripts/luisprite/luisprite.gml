function LuiSprite(x, y, width, height, sprite, index = 0, scale = 1, blend_color = c_white, alpha = 1, maintain_aspect = true) : LuiBase() constructor {
	self.name = "LuiSpriteButton";
	self.pos_x = x;
	self.pos_y = y;
	
	self.sprite = sprite;
	self.sprite_real_width = sprite_get_width(sprite);
	self.sprite_real_height = sprite_get_height(sprite);
	self.index = index;
	self.scale = scale;
	self.blend_color = blend_color;
	self.alpha = alpha;
	self.maintain_aspect = maintain_aspect;
	self.aspect = self.sprite_real_width / self.sprite_real_height;
	
	self.width = width == undefined ? self.sprite_real_width : width;
	self.height = height == undefined ? self.sprite_real_height : height;
	
	self.draw = function(x = self.x, y = self.y) {
		var _width = self.width;
		var _height = self.height;
		if self.maintain_aspect {
			if _width <= self.sprite_real_width {
				_height = _width / self.aspect;
			} else {
				_width = _height * self.aspect;
			}
		}
		draw_sprite_stretched_ext(self.sprite, self.index, 
									x + self.width/2 - _width/2, y + self.height/2 - _height/2, _width, _height, 
									self.blend_color, self.alpha);
	}
}