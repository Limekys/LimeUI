///@desc This element displays the specified surface with certain settings.
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
///@arg {id.Surface} surface
///@arg {any} color
///@arg {Real} alpha
///@arg {Bool} maintain_aspect
function LuiSurface(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = LUI_AUTO_NAME, surface = undefined, color = c_white, alpha = 1, maintain_aspect = true) : LuiBase() constructor {
	
	self.name = name;
	self.x = x;
	self.y = y;
	self.width = width;
	self.height = height;
	
	self.value = surface;
	self.color_blend = color;
	self.alpha = alpha;
	self.maintain_aspect = maintain_aspect;
	self.surface_real_width = 0;
	self.surface_real_height = 0;
	self.aspect = 1;
	
	///@desc Set surface id
	///@arg {id.Surface} _surface
	static setSurface = function(_surface) {
		self.set(_surface);
		return self;
	}
	
	///@desc Set blend color
	///@arg {any} _color_blend
	static setColor = function(_color_blend) {
		self.color_blend = _color_blend;
		return self;
	}
	
	///@desc Set alpha
	///@arg {real} _alpha
	static setAlpha = function(_alpha) {
		self.alpha = _alpha;
		return self
	}
	
	///@desc Set maintain aspect of surface
	///@arg {bool} _maintain_aspect
	static setMaintainAspect = function(_maintain_aspect) {
		self.maintain_aspect = _maintain_aspect;
		return self;
	}
	
	///@desc Update surface if visible (should be called from main object where you draw surface)
	static updateSurface = function() {
		if self.is_visible_in_region && self.visible && !self.deactivated {
			self.updateMainUiSurface();
		}
	}
	
	///@ignore
	static _calcSurfaceSize = function() {
		if surface_exists(self.value) {
			self.surface_real_width = surface_get_width(self.value);
			self.surface_real_height = surface_get_height(self.value);
			self.aspect = self.surface_real_width / self.surface_real_height;
		}
	}
	
	self.draw = function() {
		if !surface_exists(self.value) return;
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
		if self.deactivated {
			_blend_color = merge_color(_blend_color, c_black, 0.5);
		}
		//Draw surface
		var _sprite_render_function = draw_surface_stretched_ext;
		_sprite_render_function(self.value, 
									floor(self.x + self.width/2 - _width/2), 
									floor(self.y + self.height/2 - _height/2), 
									_width, _height, 
									_blend_color, self.alpha);
	}
	
	self.addEvent(LUI_EV_VALUE_UPDATE, function(_element) {
		_element._calcSurfaceSize();
	});
}