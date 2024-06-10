///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} hint
///@arg {Function} callback
function LuiDropDown(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, hint = "drop list", callback = undefined) : LuiBase() constructor {
	
	self.name = "LuiDropDown";
	self.value = "";
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	init_element();
	set_callback(callback);
	
	self.is_pressed = false;
	self.hint = hint;
	self.items = [];
	self.is_open = false;
	self.dropdown_panel = undefined;
	
	self.toggle_dropdown = function() {
        self.is_open = !self.is_open;
		if self.is_open {
			var _items_length = array_length(items);
			var _width = self.width;
			var _height = self.height * _items_length;
			var _x = self.pos_x;
			var _y = self.pos_y + self.height;
			self.dropdown_panel = new LuiPanel(_x, _y, _width, _height, "LuiDropDownPanel");
			self.parent.add_content([self.dropdown_panel]);
			var _prev_padding = self.dropdown_panel.style.padding;
			self.dropdown_panel.style.padding = 0;
			for (var i = 0; i < _items_length; ++i) {
			    var _item = new LuiDropDownItem(, , , , items[i].text, items[i].callback);
				_item.dropdown_parent = self;
				self.dropdown_panel.add_content([_item]);
				_item.set_depth(_item.z + array_last(self.parent.contents).z + i);
			}
			self.dropdown_panel.style.padding = _prev_padding;
		} else {
			self.dropdown_panel.destroy();
		}
        return self;
    }
	
	self.add_item = function(text, callback = undefined) {
        var item = {
			text : text,
			callback : callback
		}
        array_push(self.items, item);
        return self;
    }
	
    self.remove_item = function(index) {
        if (index >= 0 && index < array_length(self.items)) {
            array_delete(self.items, index, 1);
        }
        return self;
    }
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		//Base
		if !is_undefined(self.style.sprite_dropdown) {
			var _blend_color = self.style.color_dropdown;
			if !self.deactivated && self.mouse_hover() {
				_blend_color = merge_colour(self.style.color_dropdown, self.style.color_hover, 0.5);
				if self.is_pressed == true {
					_blend_color = merge_colour(self.style.color_dropdown, c_black, 0.5);
				}
			}
			draw_sprite_stretched_ext(self.style.sprite_dropdown, 0, draw_x, draw_y, self.width, self.height, _blend_color, 1);
		}
		
		//Text
		if !is_undefined(self.style.font_default) {
			draw_set_font(self.style.font_default);
		}
		draw_set_alpha(1);
		draw_set_color(self.style.color_font);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		var _txt_x = draw_x + self.width / 2;
		var _txt_y = draw_y + self.height / 2;
		if self.value == "" {
			draw_set_alpha(0.5);
			_lui_draw_text_cutoff(_txt_x, _txt_y, self.hint, self.width);
		} else {
			_lui_draw_text_cutoff(_txt_x, _txt_y, string(self.value), self.width);
		}
		
		//Border
		if !is_undefined(self.style.sprite_dropdown_border) {
			draw_sprite_stretched_ext(self.style.sprite_dropdown_border, 0, draw_x, draw_y, self.width, self.height, self.style.color_dropdown_border, 1);
		}
	}
	
	self.on_mouse_left_pressed = function() {
		self.is_pressed = true;
	}
	
	self.on_mouse_left_released = function() {
		if self.is_pressed {
			self.is_pressed = false;
			self.callback();
			self.toggle_dropdown();
			if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
		}
	}
	
	self.step = function() {
		if !mouse_hover() { 
			self.is_pressed = false;
		}
	}
	
	return self;
}

///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} text
///@arg {Function} callback
function LuiDropDownItem(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, text = "dropdown_item", callback = undefined) : LuiBase() constructor {
	
	self.name = "LuiDropDownItem";
	self.text = text;
	self.value = text;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	init_element();
	set_callback(callback);
	
	self.is_pressed = false;
	self.dropdown_parent = undefined;
	
	self.dropdown_callback = function() {
		self.dropdown_parent.value = self.text;
		self.dropdown_parent.toggle_dropdown();
	}
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		//Base
		if !is_undefined(self.style.sprite_dropdown) {
			var _blend_color = self.style.color_dropdown;
			if !self.deactivated && self.mouse_hover() {
				_blend_color = merge_colour(self.style.color_dropdown, self.style.color_hover, 0.5);
				if self.is_pressed == true {
					_blend_color = merge_colour(self.style.color_dropdown, c_black, 0.5);
				}
			}
			draw_sprite_stretched_ext(self.style.sprite_dropdown, 0, draw_x, draw_y, self.width, self.height, _blend_color, 1);
		}
		
		//Text
		if self.text != "" {
			if !is_undefined(self.style.font_buttons) {
				draw_set_font(self.style.font_buttons);
			}
			draw_set_alpha(1);
			draw_set_color(self.style.color_font);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			var _txt_x = draw_x + self.width / 2;
			var _txt_y = draw_y + self.height / 2;
			_lui_draw_text_cutoff(_txt_x, _txt_y, self.text, self.width);
		}
		
		//Border
		if !is_undefined(self.style.sprite_dropdown_border) {
			draw_sprite_stretched_ext(self.style.sprite_dropdown_border, 0, draw_x, draw_y, self.width, self.height, self.style.color_dropdown_border, 1);
		}
	}
	
	self.on_mouse_left_pressed = function() {
		self.is_pressed = true;
	}
	
	self.on_mouse_left_released = function() {
		if self.is_pressed {
			self.is_pressed = false;
			self.callback();
			self.dropdown_callback();
			if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
		}
	}
	
	self.step = function() {
		if !mouse_hover() { 
			self.is_pressed = false;
		}
	}

    return self;
}