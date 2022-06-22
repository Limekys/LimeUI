function LuiTextbox(x = LUI_AUTO, y = LUI_AUTO, width = 128, height = 32, start_text = "", hint = "", is_password = false, max_length = 32) : LuiBase() constructor {
	self.name = "LuiTextbox";
	self.value = start_text;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	draw_set_font(LUI_FONT_DEFAULT);
	self.min_width = string_width(value);
	
	self.hint = hint;
	self.is_password = is_password;
	self.max_length = max_length;
	self.is_pressed = false;
	self.cursor_pointer = "";
	self.cursor_timer = time_source_create(time_source_game, 0.5, time_source_units_seconds, function(){
		if self.cursor_pointer == ""
		self.cursor_pointer = LUI_TEXTBOX_CURSOR;
		else
		self.cursor_pointer = "";
	}, [], -1);
	
	self.draw = function() {
		//Textbox field
		var _border_color = has_focus ? LUI_COLOR_BORDER : LUI_COLOR_TEXTBOXBORDER;
		if LUI_SPRITE_PANEL != undefined draw_sprite_stretched_ext(LUI_SPRITE_PANEL, 0, self.x, self.y, self.width, self.height, LUI_COLOR_MAIN, 1);
		if LUI_SPRITE_BUTTON_BORDER != undefined draw_sprite_stretched_ext(LUI_SPRITE_BUTTON_BORDER, 0, self.x, self.y, self.width, self.height, _border_color, 1);
		//Set text
		draw_set_alpha(1);
		draw_set_color(LUI_COLOR_FONT);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		draw_set_font(LUI_FONT_DEFAULT);
		var _margin = 6;
		var _txt_x = self.x + _margin;
		var _txt_y = self.y + self.height / 2;
		var _display_text = self.value;
		
		//Password dots
		if self.is_password {
			_display_text = string_length(self.value)*LUI_TEXTBOX_PASSWORD;
		}
		
		//Cut
		while(string_width(_display_text) > (self.width - (2 * _margin)))
		_display_text = string_delete(_display_text, 1, 1);
		
		//Final text
		draw_text(_txt_x, _txt_y, _display_text + self.cursor_pointer);
		
		//Show hint
		if self.value == "" {
			draw_set_alpha(0.5);
			draw_set_color(LUI_COLOR_FONT_HINT);
			draw_text(_txt_x, _txt_y, self.hint);
		}
		
		//When mouse hover
		if !has_focus && mouse_hover() {
			if LUI_SPRITE_PANEL != undefined draw_sprite_stretched_ext(LUI_SPRITE_BUTTON, 0, self.x, self.y, self.width, self.height, c_white, 0.3);
		}
	}
	
	static set_focus = function() {
		self.has_focus = true;
		time_source_start(self.cursor_timer);
		self.cursor_pointer = LUI_TEXTBOX_CURSOR;
		keyboard_string = get();
	}
	
	static remove_focus = function() {
		self.has_focus = false;
		time_source_stop(self.cursor_timer);
		self.cursor_pointer = "";
	}
	
	self.step = function() {
		if mouse_hover() { 
			self.button_color = c_ltgray;
			if mouse_check_button_pressed(mb_left) {
				self.is_pressed = true;
			}
			if mouse_check_button(mb_left) {
				self.button_color = c_gray;
			}
			if mouse_check_button_released(mb_left) && self.is_pressed {
				set_focus();
			}
		} else {
			if mouse_check_button_pressed(mb_left) {
				remove_focus();
			}
			self.button_color = LUI_COLOR_MAIN;
			self.is_pressed = false;
		}
		
		if has_focus {
			self.set(keyboard_string);
			if (keyboard_check_pressed(vk_enter)) {
				remove_focus();
			}
			if keyboard_check(vk_lcontrol) && keyboard_check_pressed(ord("V")) && clipboard_has_text() {
				set(get() + clipboard_get_text());
				keyboard_string = get();
			}
		}
	}
	
	self.destroy_main = method(self, self.destroy);
	self.destroy = function() {
		time_source_destroy(self.cursor_timer);
		self.destroy_main();
	}
}