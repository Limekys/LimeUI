function LuiButton(x, y, width, height = 32, text = "button", callback = undefined) : LuiBase() constructor {
	
	draw_set_font(LUI_FONT_BUTTONS); //Need to be called for right calculations
	
	self.name = "LuiButton";
	self.text = text;
	self.pos_x = x;
	self.pos_y = y;
	self.width = (width == undefined) ? string_width(text) + LUI_PADDING : width;
	self.height = height;
	self.min_width = string_width(text);
	
	self.button_color = self.blend_color;
	self.is_pressed = false;
	self.deactivated = false;
	
	if callback == undefined {
		self.callback = function() {print(self.text)};
	} else {
		self.callback = method(self, callback);
	}
	
	self.activate = function() {
		self.deactivated = false;
		return self;
	}
	self.deactivate = function() {
		self.deactivated = true;
		return self;
	}
	
	self.draw = function(x = self.x, y = self.y) {
		//Base
		if LUI_SPRITE_BUTTON != undefined draw_sprite_stretched_ext(LUI_SPRITE_BUTTON, 0, x, y, width, height, self.button_color, 1);
		
		//Text
		draw_set_alpha(1);
		if self.deactivated draw_set_color(c_dkgray) else draw_set_color(LUI_COLOR_FONT);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_font(LUI_FONT_BUTTONS);
		var _txt_x = x + self.width / 2;
		var _txt_y = y + self.height / 2;
		draw_text(_txt_x, _txt_y, self.text);
		
		//Border
		if LUI_SPRITE_BUTTON_BORDER != undefined draw_sprite_stretched_ext(LUI_SPRITE_BUTTON_BORDER, 0, x, y, width, height, LUI_COLOR_BORDER, 1);
	}
	
	self.step = function() {
		if self.deactivated {
			self.button_color = c_gray;
		} else {
			if mouse_hover() { 
				self.button_color = merge_colour(self.blend_color, c_gray, 0.5);
				if mouse_check_button_pressed(mb_left) {
					self.is_pressed = true;
				}
				if mouse_check_button(mb_left) {
					self.button_color = merge_colour(self.blend_color, c_black, 0.5);
				}
				if mouse_check_button_released(mb_left) && self.is_pressed {
					self.callback();
					if LUI_CLICK_SOUND != undefined audio_play_sound(LUI_CLICK_SOUND, 1, false);
				}
			} else {
				self.button_color = self.blend_color;
				self.is_pressed = false;
			}
		}
	}
}