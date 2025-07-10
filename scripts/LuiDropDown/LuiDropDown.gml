///@desc Drop-down list.
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
///@arg {String} hint
///@arg {Function} callback
function LuiDropDown(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = "LuiDropDown", hint = "", callback = undefined) : LuiButton(x, y, width, height, name, hint, callback) constructor {
	
	self.hint = hint;
	self.items = undefined;
	self.is_open = false;
	self.dropdown_panel = undefined;
	self.text_width = self.width;
	
	self.onCreate = function() {
		self._calculateTextWidth();
		if is_undefined(self.dropdown_panel) {
			self._initDropdownPanel();
			self._initItems();
		}
	}
	
	///@ignore
	static _calculateTextWidth = function() { //???// not used now
		if !is_undefined(self.style) && !is_undefined(self.style.sprite_dropdown_arrow) {
			self.text_width = self.width - sprite_get_width(self.style.sprite_dropdown_arrow)*4;
		} else {
			self.text_width = self.width;
		}
	}
	
	///@ignore
	static _initDropdownPanel = function() {
		var _item_count = array_length(self.items);
		//Calculate dropdown panel sizes
		var _width = self.width;
		var _height = (self.height + self.style.padding) * _item_count + self.style.padding;
		//Create dropdown panel
		self.dropdown_panel = new LuiPanel(0, 0, _width, , "LuiDropDownPanel").setVisible(false).setPositionType(flexpanel_position_type.absolute);
		self.main_ui.addContent([self.dropdown_panel]);
	}
	
	///@ignore
	static _initItems = function() {
		var _item_count = array_length(self.items);
		//Add items to this panel
		if !is_array(self.items) self.items = [self.items];
		for (var i = 0; i < _item_count; ++i) {
			var _item = self.items[i];
			_item.dropdown_parent = self;
			_item.height = self.height;
			_item.auto_height = false;
		}
		self.dropdown_panel.addContent(self.items);
	}
	
	///@desc Toggle dropdown menu open/close
	static toggleDropdown = function() {
		if is_undefined(self.dropdown_panel) {
			self._initDropdownPanel();
			self._initItems();
		}
		// Change dropdown state
		self.is_open = !self.is_open;
		if self.is_open {
			// Set position and size of dropdown panel
			var _x = self.x;
			var _y = self.y + self.height;
			self.dropdown_panel.setPosition(_x, _y).setWidth(self.width);
			// Show and bring to front
			self.dropdown_panel.show().bringToFront();
		} else {
			// Hide
			self.dropdown_panel.hide();
		}
		return self;
    }
	
	///@desc Add items to dropwdown menu //???//
	static addItems = function(_items) {
        self.items = _items;
        return self;
    }
	
	///@desc Remove items from dropdown menu //???//
    static removeItem = function(index) {
        //if (index >= 0 && index < array_length(self.items)) {
        //    array_delete(self.items, index, 1);
        //}
        return self;
    }
	
	self.draw = function() {
		//Base
		if !is_undefined(self.style.sprite_dropdown) {
			var _blend_color = self.style.color_secondary;
			if !self.deactivated {
				if self.isMouseHovered() {
					_blend_color = merge_colour(self.style.color_secondary, self.style.color_hover, 0.5);
					if self.is_pressed == true {
						_blend_color = merge_colour(self.style.color_secondary, c_black, 0.5);
					}
				}
			} else {
				_blend_color = merge_colour(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_dropdown, 0, self.x, self.y, self.width, self.height, _blend_color, 1);
		}
		
		//Arrow
		if !is_undefined(self.style.sprite_dropdown_arrow) {
			var _x_offset = sprite_get_width(self.style.sprite_dropdown_arrow);
			var _blend_color = self.style.color_border;
			if self.deactivated {
				_blend_color = merge_colour(_blend_color, c_black, 0.5);
			}
			draw_sprite_ext(self.style.sprite_dropdown_arrow, 0, self.x + self.width - _x_offset, self.y + self.height div 2, 1, is_open ? -1 : 1, 0, _blend_color, 1);
		}
		
		//Text
		if !is_undefined(self.style.font_buttons) {
			draw_set_font(self.style.font_buttons);
		}
		if !self.deactivated {
			draw_set_color(self.style.color_text);
		} else {
			draw_set_color(merge_colour(self.style.color_text, c_black, 0.5));
		}
		var _text_draw_width = self.width;
		if !is_undefined(self.style.sprite_dropdown_arrow) {
			_text_draw_width -= sprite_get_width(self.style.sprite_dropdown_arrow)*3;
		}
		var _txt_x = self.x + self.width / 2;
		var _txt_y = self.y + self.height / 2;
		draw_set_alpha(1);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		if self.value == "" {
			draw_set_alpha(0.5);
			_luiDrawTextCutoff(_txt_x, _txt_y, self.hint, _text_draw_width);
		} else {
			_luiDrawTextCutoff(_txt_x, _txt_y, string(self.value), _text_draw_width);
		}
		
		//Border
		if !is_undefined(self.style.sprite_dropdown_border) {
			draw_sprite_stretched_ext(self.style.sprite_dropdown_border, 0, self.x, self.y, self.width, self.height, self.style.color_border, 1);
		}
	}
	
	self.onValueUpdate = function() {
		self._calculateTextWidth();
	}
	
	self.onMouseLeftReleased = function() {
		if self.is_pressed {
			self.is_pressed = false;
			self.callback();
			self.toggleDropdown();
			if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
		}
	}
	
	self.onHide = function() {
		if self.is_open {
			self.toggleDropdown();
		}
	}
	
	self.onFocusRemove = function() {
		if self.is_open && !self.dropdown_panel.isMouseHoveredExc() {
			self.toggleDropdown();
		}
	}
	
	self.onDestroy = function() {
		if !is_undefined(self.dropdown_panel) {
			self.dropdown_panel.destroy();
		}
		self.items = -1;
	}
}

///@desc An element for a drop-down list.
///@arg {String} name
///@arg {String} text
///@arg {Function} callback
function LuiDropDownItem(name = "LuiDropDownItem", text = "dropdown_item", callback = undefined) : LuiButton(LUI_AUTO, LUI_AUTO, LUI_AUTO, LUI_AUTO, name, text, callback) constructor {
	
	self.dropdown_parent = undefined;
	
	static dropdownCallback = function() {
		self.dropdown_parent.set(self.text);
		self.dropdown_parent.toggleDropdown();
	}
	
	self.draw = function() {
		//Base
		if !is_undefined(self.style.sprite_dropdown_item) {
			var _blend_color = self.style.color_secondary;
			if !self.deactivated && self.isMouseHovered() {
				_blend_color = merge_colour(self.style.color_secondary, self.style.color_hover, 0.5);
				if self.is_pressed == true {
					_blend_color = merge_colour(self.style.color_secondary, c_black, 0.5);
				}
			}
			draw_sprite_stretched_ext(self.style.sprite_dropdown_item, 0, self.x, self.y, self.width, self.height, _blend_color, 1);
		}
		
		// Icon
		self._drawIcon();
		
		//Text
		if self.text != "" {
			if !is_undefined(self.style.font_buttons) {
				draw_set_font(self.style.font_buttons);
			}
			draw_set_alpha(1);
			draw_set_color(self.style.color_text);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			var _txt_x = self.x + self.width / 2;
			var _txt_y = self.y + self.height / 2;
			_luiDrawTextCutoff(_txt_x, _txt_y, self.text, self.width);
		}
		
		//Border
		if !is_undefined(self.style.sprite_dropdown_item_border) {
			draw_sprite_stretched_ext(self.style.sprite_dropdown_item_border, 0, self.x, self.y, self.width, self.height, self.style.color_border, 1);
		}
	}
	
	self.onMouseLeftReleased = function() {
		if self.is_pressed {
			self.is_pressed = false;
			self.callback();
			self.dropdownCallback();
			if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
		}
	}
}