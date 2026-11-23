///@desc This item displays the specified sprite with certain settings.
/// Available parameters:
/// value
/// subimg
/// color
/// alpha
/// maintain_aspect
///@arg {Struct} [_params] Struct with parameters
function LuiImage(_params = {}) : LuiBase(_params) constructor {
	// STATE

	self.value = _params[$ "value"] ?? undefined;
	self.subimg = _params[$ "subimg"] ?? 0;
	self.color_blend = _params[$ "color"] ?? c_white;
	self.alpha = _params[$ "alpha"] ?? 1;
	self.maintain_aspect = _params[$ "maintain_aspect"] ?? true;
	
	self.sprite_real_width = 0;
	self.sprite_real_height = 0;
	self.aspect = 1;
	
	// PUBLIC API

	///@desc Set sprite
	///@arg {asset.GMSprite} _sprite
	static setSprite = function(_sprite) {
		self.set(_sprite);
		return self;
	}
	
	///@desc Set subimg of sprite
	///@arg {real} _subimg
	static setSubimg = function(_subimg) {
		self.subimg = _subimg;
		return self;
	}
	
	///@desc Set blend color for sprite
	///@arg {any} _color_blend
	static setColor = function(color_blend) {
		self.color_blend = color_blend;
		return self;
	}
	
	///@desc Set alpha for sprite
	///@arg {real} _alpha
	static setAlpha = function(_alpha) {
		self.alpha = _alpha;
		return self;
	}
	
	///@desc Set maintain aspect of sprite
	///@arg {bool} _maintain_aspect
	static setMaintainAspect = function(_maintain_aspect) {
		self.maintain_aspect = _maintain_aspect;
		return self;
	}
	
	// INTERNALS

	///@ignore
	static _calcSpriteSize = function() {
		if !is_undefined(self.value) && sprite_exists(self.value) {
			self.sprite_real_width = sprite_get_width(self.value);
			self.sprite_real_height = sprite_get_height(self.value);
			self.aspect = self.sprite_real_width / self.sprite_real_height;
		}
	}
	
	///@ignore
	static _drawImage = function(_blend_color) {
		if is_undefined(self.value) || !sprite_exists(self.value) || self.width <= 0 || self.height <= 0 return;
		var _width = self.width;
		var _height = self.height;
		if self.maintain_aspect {
			_width = min(_width, _height * self.aspect);
			_height = min(_height, _width / self.aspect);
		}
		var _style = self.getStyle();
		var _render = is_callable(_style.sprite_render_function) ? _style.sprite_render_function : draw_sprite_stretched_ext;
		var _x = self.x + (self.width - _width) / 2;
		var _y = self.y + (self.height - _height) / 2;
		_render(self.value, self.subimg, _x, _y, _width, _height, _blend_color, self.alpha * draw_get_alpha());
	}

	// DRAW

	self.draw = function() {
		var _blend_color = self.color_blend;
		if self.deactivated {
			_blend_color = merge_color(_blend_color, c_black, 0.5);
		}
		self._drawImage(_blend_color);
	}
	
	// EVENT HANDLERS

	self.addEvent(LUI_EV_CREATE, function(_e) {
		_e._calcSpriteSize();
	});
	
	self.addEvent(LUI_EV_VALUE_UPDATE, function(_e) {
		_e._calcSpriteSize();
	});
}
