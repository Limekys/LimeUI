///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
///@arg {Real} tab_height
function LuiTabGroup(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = "LuiTabGroup", tab_height = 32) : LuiBase() constructor {
	
	self.name = name;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	initElement();
	
	self.is_pressed = false;
	self.tabs = undefined;
	self.tab_height = tab_height;
	
	self.tabgroup_header = undefined;
	
	self.create = function() {
		if !is_undefined(self.style) && !is_undefined(self.tabs) self._initTabs();
	}
	
	///@ignore
	static _initTabs = function() {
		var _prev_padding = self.style.padding;
		self.style.padding = 0;
		//First creating header for tabs
		if is_undefined(self.tabgroup_header) {
			self.tabgroup_header = new LuiContainer(0, 0, self.width, self.tab_height, "_tabgroup_header_" + string(self.element_id));
			self.addContent([self.tabgroup_header]);
		}
		//Add tabs
		if !is_array(self.tabs) self.tabs = [self.tabs];
		var _tab_count = array_length(self.tabs);
		for (var i = 0; i < _tab_count; ++i) {
		    //Get tab
			var _tab = self.tabs[i];
			//Set tab sizes
			_tab.height = self.tab_height;
			//Create tab container
			var _tab_container = new LuiContainer(0, self.tab_height + 1, self.width, self.height - self.tab_height - 1, $"_tab_container_{self.element_id}_{i}");
			_tab.tab_container = _tab_container;
			//Set tabgroup parent to tab
			_tab.tabgroup = self;
			//Add tab container to tabgroup
			self.addContent(_tab_container);
		}
		//Add tab to header of tabgroup
		self.tabgroup_header.addContent([self.tabs]);
		self.style.padding = _prev_padding;
		//Deactivate all and activate first
		self.tabDeactivateAll();
		self.tabs[0].tabActivate();
	}
	
	self.addTabs = function(_tabs) {
        self.tabs = _tabs;
		if !is_undefined(self.style) self._initTabs();
        return self;
    }
	
	self.tabDeactivateAll = function() {
		var _tab_count = array_length(self.tabs);
		for (var i = 0; i < _tab_count; ++i) {
		    //Get tab
			var _tab = self.tabs[i];
			//Deactivate it
			_tab.tabDeactivate();
		}
	}
	
    self.removeTab = function(index) {
        if (index >= 0 && index < array_length(self.tabs)) {
            array_delete(self.tabs, index, 1);
        }
        return self;
    }
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		//Base
		if !is_undefined(self.style.sprite_tabgroup) {
			draw_sprite_stretched_ext(self.style.sprite_tabgroup, 0, draw_x, draw_y + self.tab_height, self.width, self.height - self.tab_height, self.style.color_main, 1);
		}
		//Border
		if !is_undefined(self.style.sprite_tabgroup_border) {
			draw_sprite_stretched_ext(self.style.sprite_tabgroup_border, 0, draw_x, draw_y + self.tab_height, self.width, self.height - self.tab_height, self.style.color_border, 1);
		}
	}
	
	return self;
}

///@arg {String} name
///@arg {String} text
function LuiTab(name = "LuiTab", text = "Tab") : LuiBase() constructor {
	
	self.name = name;
	self.text = text;
	self.width = LUI_AUTO;
	self.pos_x = LUI_AUTO;
	self.pos_y = LUI_AUTO;
	initElement();
	
	self.is_pressed = false;
	self.is_active = false;
	self.tabgroup = undefined;
	self.tab_container = undefined;
	
	self.tabActivate = function() {
		self.is_active = true;
		self.tab_container.setVisible(true);
	}
	
	self.tabDeactivate = function() {
		self.is_active = false;
		self.tab_container.setVisible(false);
	}
	
	self.addContent = function(elements) {
		self.tab_container.addContent(elements);
	}
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		//Base
		if !is_undefined(self.style.sprite_tab) {
			var _blend_color = self.style.color_main;
			if !self.is_active {
				_blend_color = merge_colour(_blend_color, c_black, 0.25);
				if !self.deactivated && self.mouseHover() {
					_blend_color = merge_colour(_blend_color, self.style.color_hover, 0.5);
					if self.is_pressed == true {
						_blend_color = merge_colour(_blend_color, c_black, 0.5);
					}
				}
			}
			draw_sprite_stretched_ext(self.style.sprite_tab, 0, draw_x, draw_y, self.width, self.height, _blend_color, 1);
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
		if !is_undefined(self.style.sprite_tab_border) {
			draw_sprite_stretched_ext(self.style.sprite_tab_border, 0, draw_x, draw_y, self.width, self.height, self.style.color_button_border, 1);
		}
	}
	
	self.onMouseLeftPressed = function() {
		self.is_pressed = true;
	}
	
	self.onMouseLeftReleased = function() {
		if self.is_pressed && !self.is_active {
			self.is_pressed = false;
			self.tabgroup.tabDeactivateAll();
			self.tabActivate();
			if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
		}
	}
	
	self.onMouseLeave = function() {
		self.is_pressed = false;
	}

    return self;
}