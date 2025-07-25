///@desc This item displays the specified sprite with certain settings but works like a button.
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
///@arg {Asset.GMSprite} sprite
///@arg {Real} subimg
///@arg {Real} color
///@arg {Real} alpha
///@arg {Bool} maintain_aspect
///@arg {Function} callback
function LuiImageButton(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = LUI_AUTO_NAME, sprite = undefined, subimg = 0, color = c_white, alpha = 1, maintain_aspect = true, callback = undefined) : LuiBase() constructor {
	
	self.name = name;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	_initElement();
	setCallback(callback);
	
	self.value = sprite;
	self.sprite = sprite;
	self.subimg = subimg;
	self.color_blend = color;
	self.alpha = alpha;
	self.maintain_aspect = maintain_aspect;
	self.sprite_real_width = 0;
	self.sprite_real_height = 0;
	self.aspect = 1;
	
	self.is_pressed = false;
	
	self.onCreate = function() {
		self._calcSpriteSize();
	}
	
	///@desc Set blend color for sprite
	static setColor = function(color_blend) {
		self.color_blend = color_blend;
	}
	
	///@desc Set sprite
	static setSprite = function(_sprite) {
		self.sprite = _sprite;
		self._calcSpriteSize();
		return self
	}
	
	///@ignore
	static _calcSpriteSize = function() {
		if !is_undefined(self.sprite) && sprite_exists(self.sprite) {
			self.sprite_real_width = sprite_get_width(self.sprite);
			self.sprite_real_height = sprite_get_height(self.sprite);
			self.aspect = self.sprite_real_width / self.sprite_real_height;
		}
	}
	
	self.draw = function() {
		//Calculate fit size
		var _width = self.width;
		var _height = self.height;
		if self.maintain_aspect {
			if _width / self.aspect <= self.height  {
				_height = _width / self.aspect;
			} else {
				_width = _height * self.aspect;
			}
		}
		//Get blend color
		var _blend_color = self.color_blend;
		if !self.deactivated {
			if self.isMouseHovered() {
				_blend_color = merge_color(_blend_color, self.style.color_hover, 0.5);
				if self.is_pressed {
					_blend_color = merge_color(_blend_color, c_black, 0.5);
				}
			}
		} else {
			_blend_color = merge_color(_blend_color, c_black, 0.5);
		}
		//Draw sprite button
		var _sprite_render_function = self.style.sprite_render_function ?? draw_sprite_stretched_ext;
		if !is_undefined(self.sprite) && sprite_exists(self.sprite) {
			_sprite_render_function(self.sprite, self.subimg, 
										floor(self.x + self.width/2 - _width/2), 
										floor(self.y + self.height/2 - _height/2), 
										_width, _height, 
										_blend_color, self.alpha);
		}
	}
	
	self.onMouseLeftPressed = function() {
		self.is_pressed = true;
	}
	
	self.onMouseLeftReleased = function() {
		if self.is_pressed {
			self.is_pressed = false;
			self.callback();
			if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
		}
	}
	
	self.onMouseLeave = function() {
		self.is_pressed = false;
	}
}