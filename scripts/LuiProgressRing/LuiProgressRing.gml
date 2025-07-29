///@desc A progress ring for display loading/filling anything
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
///@arg {Real} min_value
///@arg {Real} max_value
///@arg {Bool} display_value
///@arg {Real} value
///@arg {Real} rounding
function LuiProgressRing(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = LUI_AUTO_NAME, min_value = 0, max_value = 100, display_value = true, value = 0, rounding = 0)
 : LuiProgressBar(x, y, width, height, name, min_value, max_value, display_value, value, rounding) constructor {
	
	self.sprite_pos = {
		x : 0,
		y : 0,
		scale : 1
	};
	
	///@desc Calculate scale to fit size and position
	///@ignore
	static _calcSpritePos = function(_sprite) {
		var _width = self.width;
		var _height = self.height;
		var _spr_width = sprite_get_width(_sprite);
		var _spr_height = sprite_get_height(_sprite);
		var _y_scale = _height / _spr_height;
		var _x_scale = _width / _spr_width;
		var _scale = min(_x_scale, _y_scale);
		var _x = self.x + floor(_width / 2) - _spr_width * _scale / 2;
		var _y = self.y + floor(_height / 2) - _spr_height * _scale / 2;
		self.sprite_pos.x = _x;
		self.sprite_pos.y = _y;
		self.sprite_pos.scale = _scale;
	}
	
	self.draw = function() {
		var _pos = self.sprite_pos;
		// Base
		if !is_undefined(self.style.sprite_progress_ring) {
			var _blend_color = self.style.color_back;
			if self.deactivated {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			// Draw
			draw_sprite_ext(self.style.sprite_progress_ring, 0, _pos.x, _pos.y, _pos.scale, _pos.scale, 0, _blend_color, 1);
		}
		// Bar value
		if !is_undefined(self.style.sprite_progress_ring_value) {
			// Get blend color
			var _bar_value = Range(self.value, self.min_value, self.max_value, 0, 1);
			var _blend_color = self.style.color_accent;
			if self.deactivated {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			// Draw
			drawSpriteRadial(self.style.sprite_progress_ring_value, 0, _bar_value, _pos.x, _pos.y, _pos.scale, _pos.scale, _blend_color, 1);
		}
		// Border
		if !is_undefined(self.style.sprite_progress_ring_border) {
			// Draw
			draw_sprite_ext(self.style.sprite_progress_ring_border, 0, _pos.x, _pos.y, _pos.scale, _pos.scale, 0, self.style.color_border, 1);
		}
		// Text value
		if self.display_value {
			if !is_undefined(self.style.font_default) draw_set_font(self.style.font_default);
			if !self.deactivated {
				draw_set_color(self.style.color_text);
			} else {
				draw_set_color(merge_color(self.style.color_text, c_black, 0.5));
			}
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_text(self.x + self.width / 2, self.y + self.height / 2, _calcValue(self.value));
		}
	}
	
	self.addEventListener(LUI_EV_CREATE, function(_element) {
		_element._calcSpritePos(_element.style.sprite_progress_ring);
	});
	
	self.addEventListener(LUI_EV_POSITION_UPDATE, function(_element) {
		_element._calcSpritePos(_element.style.sprite_progress_ring);
	});
	
	self.addEventListener(LUI_EV_SIZE_UPDATE, function(_element) {
		_element._calcSpritePos(_element.style.sprite_progress_ring);
	});
	
	self.addEventListener(LUI_EV_DESTROY, function(_element) {
		delete _element.sprite_pos;
	});
}