///@arg {Any} x
///@arg {Any} y
///@arg {Any} width
///@arg {Any} height
///@arg {String} start_text
///@arg {String} hint
///@arg {Bool} is_password
///@arg {Real} max_length
///@arg {Function} callback
function LuiTextbox(x, y, width, height, start_text = "", hint = "", is_password = false, max_length = 32, callback = undefined) : LuiBase() constructor {
	
	if !is_undefined(self.style.font_default) draw_set_font(self.style.font_default);
	
	self.name = "LuiTextbox";
	self.value = start_text;
	self.pos_x = x;
	self.pos_y = y;
	self.min_width = string_width(self.value);
	self.width = width;
	self.height = height ?? max(self.min_height, string_height(self.value));
	
	self.hint = hint;
	self.is_password = is_password;
	self.max_length = max_length;
	self.is_pressed = false;
	self.cursor_pointer = "";
	self.cursor_timer = time_source_create(time_source_game, 0.5, time_source_units_seconds, function(){
		if self.cursor_pointer == ""
		self.cursor_pointer = self.style.textbox_cursor;
		else
		self.cursor_pointer = "";
	}, [], -1);
	
	set_callback(callback);
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		//Textbox field
		var _border_color = has_focus ? self.style.color_border : self.style.color_textbox_border;
		if !is_undefined(self.style.sprite_panel) {
			var _blend_color = self.style.color_main;
			if !has_focus && self.mouse_hover() _blend_color = merge_colour(self.style.color_main, self.style.color_hover, 0.5);
			draw_sprite_stretched_ext(self.style.sprite_panel, 0, draw_x, draw_y, self.width, self.height, _blend_color, 1);
		}
		
		//Set text
		if !is_undefined(self.style.font_default) draw_set_font(self.style.font_default);
		draw_set_alpha(1);
		draw_set_color(self.style.color_font);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		var _margin = 6;
		var _txt_x = draw_x + _margin;
		var _txt_y = draw_y + self.height / 2;
		var _display_text = self.value;
		
		//Password dots
		if self.is_password {
			_display_text = string_repeat(self.style.textbox_password, string_length(self.value));
		}
		
		//Cut
		while(string_width(_display_text) > (self.width - (2 * _margin)))
		_display_text = string_delete(_display_text, 1, 1);
		
		//Final text
		draw_text(_txt_x, _txt_y, _display_text + self.cursor_pointer);
		
		//Show hint
		if self.value == "" {
			draw_set_alpha(0.5);
			draw_set_color(self.style.color_font_hint);
			draw_text(_txt_x, _txt_y, self.hint);
		}
		
		//Border
		if !is_undefined(self.style.sprite_panel_border)
		draw_sprite_stretched_ext(self.style.sprite_button_border, 0, draw_x, draw_y, self.width, self.height, _border_color, 1);
	}
	
	static set_focus = function() {
		self.has_focus = true;
		time_source_start(self.cursor_timer);
		self.cursor_pointer = self.style.textbox_cursor;
		keyboard_string = get();
	}
	
	static remove_focus = function() {
		self.has_focus = false;
		time_source_stop(self.cursor_timer);
		self.cursor_pointer = "";
	}
	
	self.step = function() {
		if mouse_hover() { 
			if mouse_check_button_pressed(mb_left) {
				self.is_pressed = true;
			}
			if mouse_check_button_released(mb_left) && self.is_pressed {
				set_focus();
			}
		} else {
			if mouse_check_button_pressed(mb_left) {
				remove_focus();
			}
			self.is_pressed = false;
		}
		
		if has_focus {
			if keyboard_check(vk_anykey) {
				self.set(keyboard_string);
			}
			if keyboard_check_released(vk_anykey) {
				self.callback();
			}
			if (keyboard_check_pressed(vk_enter)) {
				self.callback();
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
		if time_source_exists(self.cursor_timer) time_source_destroy(self.cursor_timer);
		self.destroy_main();
	}
	
	return self;
}