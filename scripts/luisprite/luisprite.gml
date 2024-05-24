///@arg {Any} x
///@arg {Any} y
///@arg {Any} width
///@arg {Any} height
///@arg {Asset.GMSprite} sprite
///@arg {Real} index
///@arg {Real} scale
///@arg {Real} alpha
///@arg {Bool} maintain_aspect
function LuiSprite(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, sprite, index = 0, scale = 1, alpha = 1, maintain_aspect = true) : LuiBase() constructor {
	self.name = "LuiSpriteButton";
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	init_element();
	
	self.value = sprite;
	self.index = index;
	self.scale = scale;
	self.alpha = alpha;
	self.color_blend = c_white;
	
	self.sprite_real_width = sprite_get_width(self.value);
	self.sprite_real_height = sprite_get_height(self.value);
	self.maintain_aspect = maintain_aspect;
	self.aspect = self.sprite_real_width / self.sprite_real_height;
	
	//self.width = self.auto_width == true ? self.sprite_real_width : width;
	//self.height = self.auto_height == true ? self.sprite_real_height : height;
	//self.min_width = self.auto_width == true ? self.sprite_real_width : width;
	//self.min_height = self.auto_height == true ? self.sprite_real_height : height;
	
	static set = function(value) {
		self.value = value;
		self.sprite_real_width = sprite_get_width(self.value);
		self.sprite_real_height = sprite_get_height(self.value);
		self.aspect = self.sprite_real_width / self.sprite_real_height;
		
		return self
	}
	
	self.draw = function(draw_x = 0, draw_y = 0) {
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
									draw_x + self.width/2 - _width/2, 
									draw_y + self.height/2 - _height/2, 
									_width, _height, 
									self.color_blend, self.alpha);
	}
	
	return self;
}