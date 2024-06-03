///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {Asset.GMSprite} sprite
///@arg {Real} subimg
///@arg {Real} color
///@arg {Real} alpha
///@arg {Bool} maintain_aspect
function LuiSprite(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, sprite, subimg = 0, color = c_white, alpha = 1, maintain_aspect = true) : LuiBase() constructor {
	self.name = "LuiSprite";
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	init_element();
	
	self.value = sprite;
	self.sprite = sprite;
	self.subimg = subimg;
	self.color_blend = color;
	self.alpha = alpha;
	
	self.sprite_real_width = sprite_get_width(self.sprite);
	self.sprite_real_height = sprite_get_height(self.sprite);
	self.maintain_aspect = maintain_aspect;
	self.aspect = self.sprite_real_width / self.sprite_real_height;
	
	static set_sprite = function(_sprite) {
		self.sprite = _sprite;
		self.sprite_real_width = sprite_get_width(self.sprite);
		self.sprite_real_height = sprite_get_height(self.sprite);
		self.aspect = self.sprite_real_width / self.sprite_real_height;
		
		return self
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
		var _sprite_render_function = self.style.sprite_render_function ?? draw_sprite_stretched_ext;
		_sprite_render_function(self.sprite, self.subimg, 
									draw_x + self.width/2 - _width/2, 
									draw_y + self.height/2 - _height/2, 
									_width-1, _height-1, 
									self.color_blend, self.alpha);
	}
	
	return self;
}