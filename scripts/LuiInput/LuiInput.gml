enum LUI_INPUT_TEXT_TYPE {
	text,
	password
}

///@desc A field for entering text.
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
///@arg {String} text
///@arg {String} placeholder
///@arg {Bool} is_password
///@arg {Real} max_length
function LuiInput(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = LUI_AUTO_NAME, text = "", placeholder = "", is_password = false, max_length = 255) : LuiBase() constructor {
	
	self.name = name;
	self.value = string(text);
	self.x = x;
	self.y = y;
	self.width = width;
	self.height = height;
	
	self.placeholder = placeholder;
	self.is_password = is_password;
	self.max_length = max_length;
	self.cursor_pointer = "";
	self.cursor_timer = time_source_create(time_source_game, 0.5, time_source_units_seconds, function(){
		if self.cursor_pointer == "" {
			self.cursor_pointer = self.style.input_cursor;
		} else {
			self.cursor_pointer = "";
		}
		self.updateMainUiSurface();
	}, [], -1);
	
	///@desc Set text
	///@arg {string} _text
	static setText = function(_text) {
		self.set(_text);
		return self;
	}
	
	///@desc Set placeholder text
	///@arg {string} _placeholder
	static setPlaceholder = function(_placeholder) {
		self.placeholder = _placeholder;
		return self;
	}
	
	///@desc Set text type (text, password)
	///@arg {real} _text_type LUI_INPUT_TEXT_TYPE
	static setTextType = function(_text_type) {
		if _text_type == LUI_INPUT_TEXT_TYPE.password {
			self.is_password = true;
		} else {
			self.is_password = false;
		}
		return self;
	}
	
	///@desc Set text max length
	///@arg {real} _max_length
	static setMaxLength = function(_max_length) {
		self.max_length = _max_length;
		return self;
	}
	
	///@ignore
	static _limit_value = function(_string) {
		return string_copy(_string, 1, self.max_length);
	}
	
	self.draw = function() {
		//Base
		if !is_undefined(self.style.sprite_input) {
			var _blend_color = self.style.color_back;
			if !self.deactivated {
				if !self.has_focus && self.isMouseHovered() {
					_blend_color = merge_color(self.style.color_back, self.style.color_hover, 0.5);
				}
			} else {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_input, 0, self.x, self.y, self.width, self.height, _blend_color, 1);
		}
		
		//Set text properties
		if !is_undefined(self.style.font_default) {
			draw_set_font(self.style.font_default);
		}
		if !self.deactivated {
			draw_set_color(self.style.color_text);
		} else {
			draw_set_color(merge_color(self.style.color_text, c_black, 0.5));
		}
		var _prev_alpha = draw_get_alpha();
		draw_set_alpha(1);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		
		//Get text
		var _margin = 6;
		var _txt_x = self.x + _margin;
		var _txt_y = self.y + self.height / 2;
		var _display_text = self.value;
		
		//Password dots
		if self.is_password {
			_display_text = string_repeat(self.style.input_password, string_length(self.value));
		}
		
		//Placeholder
		if self.value == "" && !self.has_focus {
			_display_text = self.placeholder;
			draw_set_alpha(0.5);
			draw_set_color(self.style.color_text_hint);
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
		
		draw_set_alpha(_prev_alpha);
		
		//Border
		if !is_undefined(self.style.sprite_input_border) {
			var _border_color = self.style.color_border;
			if self.has_focus {
				_border_color = self.style.color_accent;
			}
			draw_sprite_stretched_ext(self.style.sprite_input_border, 0, self.x, self.y, self.width, self.height, _border_color, 1);
		}
	}
	
	self.addEvent(LUI_EV_CREATE, function(_element) {
		_element.set(_element._limit_value(_element.get()));
	});
	
	self.addEvent(LUI_EV_FOCUS_SET, function(_element) {
		time_source_start(_element.cursor_timer);
		_element.cursor_pointer = _element.style.input_cursor;
		keyboard_string = get();
		_element.main_ui.waiting_for_keyboard_input = true;
		//Touch compatibility
		if os_type == os_android || os_type == os_ios {
			keyboard_virtual_show(kbv_type_default, kbv_returnkey_default, kbv_autocapitalize_none, false);
		}
	});
	
	self.addEvent(LUI_EV_FOCUS_REMOVE, function(_element) {
		time_source_stop(_element.cursor_timer);
		_element.cursor_pointer = "";
		_element.main_ui.waiting_for_keyboard_input = false;
		//Touch compatibility
		if os_type == os_android || os_type == os_ios {
			keyboard_virtual_hide();
		}
	});
	
	self.addEvent(LUI_EV_KEYBOARD_INPUT, function(_element) {
		_element.set(_element._limit_value(keyboard_string));
		keyboard_string = _element.get();
		if keyboard_check(vk_lcontrol) && keyboard_check_pressed(ord("V")) && clipboard_has_text() {
			_element.set(_element._limit_value(_element.get() + clipboard_get_text()));
			keyboard_string = _element.get();
		}
	});
	
	self.addEvent(LUI_EV_DESTROY, function(_element) {
		if time_source_exists(_element.cursor_timer) {
			time_source_destroy(_element.cursor_timer);
		}
	});
}