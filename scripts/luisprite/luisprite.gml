///@arg {Any} x
///@arg {Any} y
///@arg {Any} width
///@arg {Any} height
///@arg {Asset.GMSprite} sprite
///@arg {Real} index
///@arg {Real} scale
///@arg {Real} alpha
///@arg {Bool} maintain_aspect
function LuiSprite(x, y, width = 32, height = 32, sprite, index = 0, scale = 1, alpha = 1, maintain_aspect = true) : LuiBase() constructor {
	self.name = "LuiSpriteButton";
	self.pos_x = x;
	self.pos_y = y;
	
	self.value = sprite;
	self.sprite_real_width = sprite_get_width(self.value);
	self.sprite_real_height = sprite_get_height(self.value);
	self.index = index;
	self.scale = scale;
	self.alpha = alpha;
	self.maintain_aspect = maintain_aspect;
	self.aspect = self.sprite_real_width / self.sprite_real_height;
	
	self.width = width == undefined ? self.sprite_real_width : width;
	self.height = height == undefined ? self.sprite_real_height : height;
	self.max_width = self.width;
	self.max_height = self.height;
	
	static set = function(value) {
		self.value = value;
		self.sprite_real_width = sprite_get_width(self.value);
		self.sprite_real_height = sprite_get_height(self.value);
		self.aspect = self.sprite_real_width / self.sprite_real_height;
		
		return self
	}
	
	self.draw = function(x = self.x, y = self.y) {
		var _width = self.width;
		var _height = self.height;
		if self.maintain_aspect {
			if _width / self.aspect <= self.height {
				_height = _width / self.aspect;
			} else {
				_width = _height * self.aspect;
			}
		}
		draw_sprite_stretched_ext(self.value, self.index, 
									x + self.width/2 - _width/2, y + self.height/2 - _height/2, _width, _height, 
									self.style.color_main, self.alpha);
	}
	
	return self;
}