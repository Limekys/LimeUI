///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
///@arg {String} start_text
///@arg {String} hint
///@arg {Bool} is_password
///@arg {Real} max_length
///@arg {Function} callback
function LuiTextbox(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = "LuiTextbox", start_text = "", hint = "", is_password = false, max_length = 32, callback = undefined) : LuiBase() constructor {
	
	self.name = name;
	self.value = string(start_text);
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	initElement();
	setCallback(callback);
	
	self.hint = hint;
	self.is_password = is_password;
	self.max_length = max_length;
	self.is_pressed = false;
	self.cursor_pointer = "";
	self.cursor_timer = time_source_create(time_source_game, 0.5, time_source_units_seconds, function(){
		if self.cursor_pointer == "" {
			self.cursor_pointer = self.style.textbox_cursor;
		} else {
			self.cursor_pointer = "";
		}
		self.updateMainUiSurface();
	}, [], -1);
	
	///@ignore
	static _limit_value = function() {
		if string_length(self.value) > self.max_length {
			self.value = string_copy(self.value, 1, self.max_length);
		}
	}
	
	self.create = function() {
		if !is_undefined(self.style.font_default) {
			draw_set_font(self.style.font_default);
		}
		self.min_width = string_width(self.value);
		self.height = self.auto_height == true ? max(self.min_height, string_height(self.value)) : self.height;
	}
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		//Base
		if !is_undefined(self.style.sprite_textbox) {
			var _blend_color = self.style.color_textbox;
			if !self.deactivated {
				if !self.has_focus && self.mouseHover() {
					_blend_color = merge_colour(self.style.color_textbox, self.style.color_hover, 0.5);
				}
			} else {
				_blend_color = merge_colour(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_textbox, 0, draw_x, draw_y, self.width, self.height, _blend_color, 1);
		}
		
		//Set text properties
		if !is_undefined(self.style.font_default) {
			draw_set_font(self.style.font_default);
		}
		if !self.deactivated {
			draw_set_color(self.style.color_font);
		} else {
			draw_set_color(merge_colour(self.style.color_font, c_black, 0.5));
		}
		draw_set_alpha(1);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		
		//Get text
		var _margin = 6;
		var _txt_x = draw_x + _margin;
		var _txt_y = draw_y + self.height / 2;
		var _display_text = self.value;
		
		//Password dots
		if self.is_password {
			_display_text = string_repeat(self.style.textbox_password, string_length(self.value));
		}
		
		//Hint
		if self.value == "" && !self.has_focus {
			_display_text = self.hint;
			draw_set_alpha(0.5);
			draw_set_color(self.style.color_font_hint);
		}
		
		//Cut
		if _display_text != "" {
			while(string_width(_display_text) > (self.width - (2 * _margin)))
			_display_text = string_delete(_display_text, 1, 1);
		}
		
		//Draw final text
		if _display_text != "" || self.has_focus {
			draw_text(_txt_x, _txt_y, _display_text + self.cursor_pointer);
		}
		
		//Border
		if !is_undefined(self.style.sprite_textbox_border) {
			var _border_color = self.style.color_textbox_border;
			if self.has_focus {
				_border_color = self.style.color_hover;
			}
			draw_sprite_stretched_ext(self.style.sprite_textbox_border, 0, draw_x, draw_y, self.width, self.height, _border_color, 1);
		}
	}
	
	self.onFocusSet = function() {
		time_source_start(self.cursor_timer);
		self.cursor_pointer = self.style.textbox_cursor;
		keyboard_string = get();
		self.main_ui.waiting_for_keyboard_input = true;
	}
	
	self.onFocusRemove = function() {
		time_source_stop(self.cursor_timer);
		self.cursor_pointer = "";
		self.is_pressed = false;
		self.main_ui.waiting_for_keyboard_input = false;
	}
	
	self.onMouseLeftPressed = function() {
		self.is_pressed = true;
	}
	
	self.onKeyboardInput = function() {
		self.value = keyboard_string;
		self._limit_value();
		keyboard_string = self.value;
		if keyboard_check(vk_lcontrol) && keyboard_check_pressed(ord("V")) && clipboard_has_text() {
			self.value = self.value + clipboard_get_text();
			self._limit_value();
			keyboard_string = self.value;
		}
	}
	
	self.onKeyboardRelease = function() {
		self.callback();
	}
	
	self.cleanUp = function() {
		if time_source_exists(self.cursor_timer) {
			time_source_destroy(self.cursor_timer);
		}
	}
}