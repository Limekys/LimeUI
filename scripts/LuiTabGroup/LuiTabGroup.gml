///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {Real} tab_height
///@arg {String} name
function LuiTabGroup(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, tab_height = 32, name = "LuiTabGroup") : LuiBase() constructor {
	
	self.name = name;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	init_element();
	
	self.is_pressed = false;
	self.tabs = [];
	self.tab_height = tab_height;
	
	self.tabgroup_header = undefined;
	
	self.add_tabs = function(_tabs) {
        //First creating header for tabs
		if is_undefined(self.tabgroup_header) {
			var _prev_padding = self.style.padding;
			self.style.padding = 0;
			self.tabgroup_header = new LuiContainer(0, 0, self.width, self.tab_height, "tabgroup_header");
			self.add_content([self.tabgroup_header]);
			self.tabgroup_header.style.padding = 0;
			self.style.padding = _prev_padding;
		}
		//Add tabs
		if !is_array(_tabs) _tabs = [_tabs];
		var _tab_count = array_length(_tabs);
		for (var i = 0; i < _tab_count; ++i) {
		    //Get tab
			var _tab = _tabs[i];
			//Set tab sizes
			_tab.width = floor(self.width / _tab_count);
			_tab.height = self.tab_height;
			//Create tab container
			var _tab_container = new LuiContainer(0, self.tab_height + 1, self.width, self.height - self.tab_height - 1, "tab_container");
			_tab.tab_container = _tab_container;
			//Set tabgroup parent to tab
			_tab.tabgroup = self;
			//Add tab container to tabgroup
			self.add_content(_tab_container);
		}
		//Add tab to header of tabgroup
		self.tabgroup_header.add_content([_tabs]);
		//Add tab to tabgroup array
		self.tabs = _tabs;
		//Deactivate all and activate first
		self.tab_deactivate_all();
		self.tabs[0].tab_activate();
		
        return self;
    }
	
	self.tab_deactivate_all = function() {
		var _tab_count = array_length(self.tabs);
		for (var i = 0; i < _tab_count; ++i) {
		    //Get tab
			var _tab = self.tabs[i];
			//Deactivate it
			_tab.tab_deactivate();
		}
	}
	
    self.remove_tab = function(index) {
        if (index >= 0 && index < array_length(self.tabs)) {
            array_delete(self.tabs, index, 1);
        }
        return self;
    }
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		//Base
		if !is_undefined(self.style.sprite_tabgroup)
		draw_sprite_stretched_ext(self.style.sprite_tabgroup, 0, draw_x, draw_y + self.tab_height, self.width, self.height - self.tab_height, self.style.color_main, 1);
		//Border
		if !is_undefined(self.style.sprite_tabgroup_border)
		draw_sprite_stretched_ext(self.style.sprite_tabgroup_border, 0, draw_x, draw_y + self.tab_height, self.width, self.height - self.tab_height, self.style.color_border, 1);
	}
	
	self.step = function() {
		if mouse_hover() { 
			if mouse_check_button_pressed(mb_left) {
				self.is_pressed = true;
			}
			if mouse_check_button_released(mb_left) && self.is_pressed {
				self.is_pressed = false;
				self.callback();
				self.toggle_dropdown();
				if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
			}
		} else {
			self.is_pressed = false;
		}
	}
	
	return self;
}

///@arg {String} text
function LuiTab(text = "Tab") : LuiBase() constructor {
	
	self.name = "LuiTab";
	self.text = text;
	self.pos_x = LUI_AUTO;
	self.pos_y = LUI_AUTO;
	init_element();
	
	self.is_pressed = false;
	self.is_active = false;
	self.tabgroup = undefined;
	self.tab_container = undefined;
	
	self.tab_activate = function() {
		self.is_active = true;
		self.tab_container.set_visible(true);
	}
	
	self.tab_deactivate = function() {
		self.is_active = false;
		self.tab_container.set_visible(false);
	}
	
	self.add_content = function(elements) {
		self.tab_container.add_content(elements);
	}
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		//Base
		if !is_undefined(self.style.sprite_tab) {
			var _blend_color = self.style.color_button;
			if !self.is_active {
				_blend_color = merge_colour(self.style.color_button, c_black, 0.25);
				if !self.deactivated && self.mouse_hover() {
					_blend_color = merge_colour(self.style.color_button, self.style.color_hover, 0.5);
					if self.is_pressed == true {
						_blend_color = merge_colour(self.style.color_button, c_black, 0.5);
					}
				}
			}
			draw_sprite_stretched_ext(self.style.sprite_tab, 0, draw_x, draw_y, self.width, self.height, _blend_color, 1);
		}
		
		//Text
		if !is_undefined(self.style.font_buttons) draw_set_font(self.style.font_buttons);
		draw_set_alpha(1);
		draw_set_color(self.style.color_font);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		var _txt_x = draw_x + self.width / 2;
		var _txt_y = draw_y + self.height / 2;
		draw_text_cutoff(_txt_x, _txt_y, self.text, self.width);
		
		//Border
		if !is_undefined(self.style.sprite_tab_border) {
			draw_sprite_stretched_ext(self.style.sprite_tab_border, 0, draw_x, draw_y, self.width, self.height, self.style.color_button_border, 1);
		}
	}
	
	self.step = function() {
		if mouse_hover() { 
			if mouse_check_button_pressed(mb_left) {
				self.is_pressed = true;
			}
			if mouse_check_button_released(mb_left) && self.is_pressed {
				self.is_pressed = false;
				self.tabgroup.tab_deactivate_all();
				self.tab_activate();
				if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
			}
		} else {
			self.is_pressed = false;
		}
	}

    return self;
}