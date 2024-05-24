///@arg {Any} x
///@arg {Any} y
///@arg {Any} width
///@arg {Any} height
///@arg {Array} elements
///@arg {String} hint
///@arg {Function} callback
function LuiDropDown(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, elements = [], hint = "drop list", callback = undefined) : LuiBase() constructor {
	
	if !is_undefined(self.style.font_buttons) draw_set_font(self.style.font_buttons); //Need to be called for right calculations
	
	self.name = "LuiDropDown";
	self.value = "";
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height ?? self.min_height;
	init_element();
	set_callback(callback);
	
	self.min_width = self.auto_width == true ? string_width(hint) + self.style.padding : width;
	self.is_pressed = false;
	self.hint = hint;
	self.drop_elements = elements;
	self.dropped = false;
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		//Base
		if !is_undefined(self.style.sprite_panel)
		draw_sprite_stretched_ext(self.style.sprite_panel, 0, draw_x, draw_y, width, height, self.style.color_main, 1);
		
		//Text
		if !is_undefined(self.style.font_default) draw_set_font(self.style.font_default);
		draw_set_alpha(1);
		if self.deactivated draw_set_color(c_dkgray) else draw_set_color(self.style.color_font);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		var _txt_x = draw_x + self.width / 2;
		var _txt_y = draw_y + self.height / 2;
		draw_text(_txt_x, _txt_y, string(self.value));
		if value == "" {
			draw_set_alpha(0.5);
			draw_text(_txt_x, _txt_y, self.hint);
		}
		
		//Border
		if !is_undefined(self.style.sprite_panel_border)
		draw_sprite_stretched_ext(self.style.sprite_panel_border, 0, draw_x, draw_y, width, height, self.style.color_border, 1);
		
		//Drop list
		if dropped {
			for (var i = 0; i < array_length(drop_elements); ++i) {
			    //Base
				if self.style.sprite_panel != undefined draw_sprite_stretched_ext(self.style.sprite_panel, 0, draw_x, draw_y + height + i*height, width, height, self.style.color_main, 1);
				//Text
				draw_set_alpha(1);
				var _txt_x = draw_x + width / 2;
				var _txt_y = draw_y + height / 2 + height + i*height;
				draw_text(_txt_x, _txt_y, string(drop_elements[i]));
				//Border
				if self.style.sprite_panel_border != undefined draw_sprite_stretched_ext(self.style.sprite_panel_border, 0, draw_x, draw_y + height + i*height, width, height, self.style.color_border, 1);
			}
		}
		
		draw_set_alpha(1);
	}
	
	self.step = function() {
		if self.deactivated {
			
		} else {
			if mouse_hover() { 
				
				if mouse_check_button_pressed(mb_left) {
					dropped = !dropped;
				}
				if mouse_check_button(mb_left) {
					
				}
				if mouse_check_button_released(mb_left) && self.is_pressed {
					//self.callback();
					if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
				}
			} else {
				
				//self.is_pressed = false;
			}
			if dropped {
				for (var i = 0; i < array_length(drop_elements); ++i) {
				    var _element = drop_elements[i];
					var _mouse_x = device_mouse_x_to_gui(0);
					var _mouse_y = device_mouse_y_to_gui(0);
					var _on_this = point_in_rectangle(_mouse_x, _mouse_y, 
						self.get_absolute_x(), self.get_absolute_y() + height + i*height, 
						self.get_absolute_x() + self.width - 1, self.get_absolute_y() + height + i*height + self.height - 1);
					if _on_this && mouse_check_button_pressed(mb_left) {
						value = _element;
						dropped = false;
						callback();
					}
				}
			}
		}
	}
	
	self.add_element = function(element) {
		array_push(drop_elements, element);
	}
	
	self.delete_element = function(element) {
		var _index = array_get_index(drop_elements, element);
		array_delete(drop_elements, _index, 1);
	}
	
	return self;
}

//???//
/*
///@arg {Any} x
///@arg {Any} y
///@arg {Any} width
///@arg {Any} height
///@arg {String} text
function LuiDropDown(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, text = "dropdown") : LuiBase() constructor {
    
	self.name = "LuiDropDown";
    self.text = text;
    self.pos_x = x;
    self.pos_y = y;
    self.width = width;
    self.height = height;
	init_element();
	
    self.is_open = false;
    self.items = [];

    self.toggle_dropdown = function() {
        self.is_open = !self.is_open;
        return self;
    }

    self.add_item = function(text, callback = undefined) {
        var item = new LuiDropDownItem(text, callback);
        item.parent = self;
        item.width = self.width;
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
        // Base button
        if (!is_undefined(self.style.sprite_button)) {
            var _blend_color = self.style.color_button;
            if (!self.deactivated && self.mouse_hover()) {
                _blend_color = merge_colour(self.style.color_button, self.style.color_hover, 0.5);
            }
            draw_sprite_stretched_ext(self.style.sprite_button, 0, draw_x, draw_y, self.width, self.height, _blend_color, 1);
        }

        // Text
        if (!is_undefined(self.style.font_buttons)) draw_set_font(self.style.font_buttons);
        draw_set_alpha(1);
        draw_set_color(self.style.color_font);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        var _txt_x = draw_x + self.width / 2;
        var _txt_y = draw_y + self.height / 2;
        draw_text(_txt_x, _txt_y, self.text);

        // Border
        if (!is_undefined(self.style.sprite_button_border)) {
            draw_sprite_stretched_ext(self.style.sprite_button_border, 0, draw_x, draw_y, self.width, self.height, self.style.color_button_border, 1);
        }

        // Draw items if dropdown is open
        if (self.is_open) {
            for (var i = 0; i < array_length(self.items); i++) {
                var item = self.items[i];
                item.draw(draw_x, draw_y + self.height * (i + 1));
            }
        }
    }

    self.step = function() {
        if (mouse_hover() && mouse_check_button_pressed(mb_left)) {
            self.toggle_dropdown();
        }

        if (self.is_open) {
            for (var i = 0; i < array_length(self.items); i++) {
                var item = self.items[i];
                item.step();
            }
        }
    }

    return self;
}

///@arg {String} text
///@arg {Function} callback
function LuiDropDownItem(text = "", callback = undefined) : LuiBase() constructor {
    self.name = "LuiDropDownItem";
    self.text = text;
    self.value = text;
	init_element();
    set_callback(callback);

    self.draw = function(draw_x = 0, draw_y = 0) {
        // Base
        if (!is_undefined(self.style.sprite_button)) {
            var _blend_color = self.style.color_button;
            if (!self.deactivated && self.mouse_hover()) {
                _blend_color = merge_colour(self.style.color_button, self.style.color_hover, 0.5);
            }
            draw_sprite_stretched_ext(self.style.sprite_button, 0, draw_x, draw_y, self.width, self.height, _blend_color, 1);
        }

        // Text
        if (!is_undefined(self.style.font_buttons)) draw_set_font(self.style.font_buttons);
        draw_set_alpha(1);
        draw_set_color(self.style.color_font);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        var _txt_x = draw_x + self.width / 2;
        var _txt_y = draw_y + self.height / 2;
        draw_text(_txt_x, _txt_y, self.text);

        // Border
        if (!is_undefined(self.style.sprite_button_border)) {
            draw_sprite_stretched_ext(self.style.sprite_button_border, 0, draw_x, draw_y, self.width, self.height, self.style.color_button_border, 1);
        }
    }

    self.step = function() {
        if (mouse_hover()) { 
            if (mouse_check_button_pressed(mb_left)) {
                self.callback();
                if (self.style.sound_click != undefined) audio_play_sound(self.style.sound_click, 1, false);
            }
        }
    }

    return self;
}
