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
	initElement();
	setCallback(callback);
	
	self.is_pressed = false;
	self.hint = hint;
	self.items = undefined;
	self.is_open = false;
	self.dropdown_panel = undefined;
	
	///@ignore
	static _initItems = function() {
		var _item_count = array_length(self.items);
		//Create dropdown panel
		var _width = self.width;
		var _height = self.height * _item_count;
		self.dropdown_panel = new LuiPanel(0, 0, _width, _height, "LuiDropDownPanel").setVisibilitySwitching(false);
		self.main_ui.addContent([self.dropdown_panel]);
		//Add items to this panel
		var _prev_padding = self.dropdown_panel.style.padding;
		self.dropdown_panel.style.padding = 0;
		if !is_array(self.items) self.items = [self.items];
		for (var i = 0; i < _item_count; ++i) {
			var _item = self.items[i];
			_item.dropdown_parent = self;
			self.dropdown_panel.addContent([_item]);
			_item.setDepth(_item.z + array_last(self.parent.content).z + i);
		}
		self.dropdown_panel.style.padding = _prev_padding;
	}
	
	static toggleDropdown = function() {
        if is_undefined(self.dropdown_panel) {
			self._initItems();
		}
		//Set position of dropdown panel
		var _x = self.x;
		var _y = self.y + self.height;
		self.dropdown_panel.pos_x = _x;
		self.dropdown_panel.pos_y = _y;
		//Open and change visibility
		self.is_open = !self.is_open;
		self.dropdown_panel.setVisibilitySwitching(true);
		self.dropdown_panel.setVisible(self.is_open);
		self.dropdown_panel.setVisibilitySwitching(false);
		return self;
    }
	
	static addItems = function(_items) {
        self.items = _items;
        return self;
    }
	
	//???//
    static removeItem = function(index) {
        //if (index >= 0 && index < array_length(self.items)) {
        //    array_delete(self.items, index, 1);
        //}
        return self;
    }
	
	self.create = function() {
		
	}
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		//Base
		if !is_undefined(self.style.sprite_dropdown) {
			var _blend_color = self.style.color_dropdown;
			if !self.deactivated && self.mouseHover() {
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
			_luiDrawTextCutoff(_txt_x, _txt_y, self.hint, self.width);
		} else {
			_luiDrawTextCutoff(_txt_x, _txt_y, string(self.value), self.width);
		}
		
		//Border
		if !is_undefined(self.style.sprite_dropdown_border) {
			draw_sprite_stretched_ext(self.style.sprite_dropdown_border, 0, draw_x, draw_y, self.width, self.height, self.style.color_dropdown_border, 1);
		}
	}
	
	self.onMouseLeftPressed = function() {
		self.is_pressed = true;
	}
	
	self.onMouseLeftReleased = function() {
		if self.is_pressed {
			self.is_pressed = false;
			self.callback();
			self.toggleDropdown();
			if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
		}
	}
	
	self.onMouseLeave = function() {
		self.is_pressed = false;
	}
	
	return self;
}

///@arg {String} text
///@arg {Function} callback
function LuiDropDownItem(text = "dropdown_item", callback = undefined) : LuiBase() constructor {
	
	self.name = "LuiDropDownItem";
	self.text = text;
	self.value = text;
	self.pos_x = LUI_AUTO;
	self.pos_y = LUI_AUTO;
	self.width = LUI_AUTO;
	self.height = LUI_AUTO;
	initElement();
	setCallback(callback);
	
	self.is_pressed = false;
	self.dropdown_parent = undefined;
	
	self.dropdownCallback = function() {
		self.dropdown_parent.value = self.text;
		self.dropdown_parent.toggleDropdown();
	}
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		//Base
		if !is_undefined(self.style.sprite_dropdown) {
			var _blend_color = self.style.color_dropdown;
			if !self.deactivated && self.mouseHover() {
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
			_luiDrawTextCutoff(_txt_x, _txt_y, self.text, self.width);
		}
		
		//Border
		if !is_undefined(self.style.sprite_dropdown_border) {
			draw_sprite_stretched_ext(self.style.sprite_dropdown_border, 0, draw_x, draw_y, self.width, self.height, self.style.color_dropdown_border, 1);
		}
	}
	
	self.onMouseLeftPressed = function() {
		self.is_pressed = true;
	}
	
	self.onMouseLeftReleased = function() {
		if self.is_pressed {
			self.is_pressed = false;
			self.callback();
			self.dropdownCallback();
			if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
		}
	}
	
	self.onMouseLeave = function() {
		self.is_pressed = false;
	}

    return self;
}