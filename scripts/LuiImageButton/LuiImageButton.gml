///@desc This item displays the specified sprite with certain settings but works like a button.
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
///@arg {Asset.GMSprite} sprite
///@arg {Real} subimg
///@arg {any} color
///@arg {Real} alpha
///@arg {Bool} maintain_aspect
///@arg {Function} callback
function LuiImageButton(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = LUI_AUTO_NAME, sprite = undefined, subimg = 0, color = c_white, alpha = 1, maintain_aspect = true, callback = undefined)
 : LuiImage(x, y, width, height, name, sprite, subimg, color, alpha, maintain_aspect) constructor {
	
	setCallback(callback);
	
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
		if !is_undefined(self.value) && sprite_exists(self.value) {
			_sprite_render_function(self.value, self.subimg, 
										floor(self.x + self.width/2 - _width/2), 
										floor(self.y + self.height/2 - _height/2), 
										_width, _height, 
										_blend_color, self.alpha);
		}
	}
	
	self.addEventListener(LUI_EV_CLICK, function(_element) {
		_element.callback(); //???// обратная совместимость
		if !is_undefined(_element.style.sound_click) {
			audio_play_sound(_element.style.sound_click, 1, false);
		}
	});
}