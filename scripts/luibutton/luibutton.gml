///@desc It's just a button.
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
///@arg {String} text
///@arg {Function} callback
function LuiButton(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = "LuiButton", text = "", callback = undefined) : LuiBase() constructor {
	
	self.name = name;
	self.text = text;
	self.value = text;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	initElement();
	setCallback(callback);
	
	self.is_pressed = false;
	self.button_color = undefined;
	self.sprite_icon = -1;
	self.sprite_icon_scale = 0.5;
	self.sprite_icon_width = -1;
	self.sprite_icon_height = -1;
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		// Base
		if !is_undefined(self.style.sprite_button) {
			var _blend_color = self.style.color_button;
			if !is_undefined(self.button_color) _blend_color = self.button_color;
			if !self.deactivated {
				if self.mouseHover() {
					_blend_color = merge_colour(_blend_color, self.style.color_hover, 0.5);
					if self.is_pressed == true {
						_blend_color = merge_colour(_blend_color, c_black, 0.5);
					}
				}
			} else {
				_blend_color = merge_colour(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_button, 0, draw_x, draw_y, self.width, self.height, _blend_color, 1);
		}
		
		// Icon
		self._drawIcon();
		
		// Text
		if self.text != "" {
			if !is_undefined(self.style.font_buttons) {
				draw_set_font(self.style.font_buttons);
			}
			if !self.deactivated {
				draw_set_color(self.style.color_font);
			} else {
				draw_set_color(merge_colour(self.style.color_font, c_black, 0.5));
			}
			draw_set_alpha(1);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			var _txt_x = draw_x + self.width / 2;
			var _txt_y = draw_y + self.height / 2;
			_luiDrawTextCutoff(_txt_x, _txt_y, self.text, self.width);
		}
		
		// Border
		if !is_undefined(self.style.sprite_button_border) {
			draw_sprite_stretched_ext(self.style.sprite_button_border, 0, draw_x, draw_y, self.width, self.height, self.style.color_button_border, 1);
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
	
	self.create = function() {
		if sprite_exists(self.sprite_icon) self._calcIconSize();
	}
	
	///@func setColor(_button_color)
	///@arg _button_color
	self.setColor = function(_button_color) {
		self.button_color = _button_color;
		return self;
	}
	
	///@arg {Asset.GMSprite} _sprite
	self.setIcon = function(_sprite, _scale = 0.5) {
		self.sprite_icon = _sprite;
		self.sprite_icon_scale = _scale;
		self._calcIconSize();
		return self;
	}
	
	///@ignore
	static _calcIconSize = function() {
		var _size = floor(min(self.width, self.height, sprite_get_width(self.sprite_icon), sprite_get_height(self.sprite_icon)) * self.sprite_icon_scale);
		self.sprite_icon_width = _size;
		self.sprite_icon_height = _size;
	}
	
	///@ignore
	static _drawIcon = function() {
		if sprite_exists(self.sprite_icon) {
			// Draw icon
			var _offset = 8;
			var _x = self.x + _offset;
			var _y = self.y + self.height / 2 - self.sprite_icon_height / 2;
			draw_sprite_stretched(self.sprite_icon, 0, _x, _y, self.sprite_icon_width, self.sprite_icon_height);
		}
	}
}