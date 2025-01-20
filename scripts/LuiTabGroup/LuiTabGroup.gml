///@desc Panel with tabs
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
	
	static _initHeader = function() {
		if is_undefined(self.tabgroup_header) {
			// Create header element
			self.tabgroup_header = new LuiFlexRow(, , , self.tab_height, "_tabgroup_header_" + string(self.element_id));
			// Setting up padding for tabgroup
			self.setFlexPadding(0).setFlexGap(0);
			// Add header to tabgroup
			self.addContent(self.tabgroup_header, 0);
		}
	}
	
	///@ignore
	static _initTabs = function() {
		//Add tabs
		if !is_array(self.tabs) self.tabs = [self.tabs];
		var _tab_count = array_length(self.tabs);
		for (var i = 0; i < _tab_count; ++i) {
		    // Get tab
			var _tab = self.tabs[i];
			// Set tab sizes
			_tab.height = self.tab_height;
			// Init tab container
			_tab._initContainer();
			// Set tabgroup parent for tab
			_tab.tabgroup = self;
			// Add tab container to tabgroup
			self.addContent(_tab.tab_container);
			// Adjust position and size of container
			//flexpanel_node_style_set_position(_tab.tab_container.flex_node, flexpanel_edge.left, 0, flexpanel_unit.point);
			//flexpanel_node_style_set_position(_tab.tab_container.flex_node, flexpanel_edge.top, self.tab_height, flexpanel_unit.point);
			//flexpanel_node_style_set_width(_tab.tab_container.flex_node, self.width, flexpanel_unit.point);
			flexpanel_node_style_set_height(_tab.tab_container.flex_node, self.height - self.tab_height, flexpanel_unit.point);
		}
		//Add tab to header of tabgroup
		self.tabgroup_header.addContent(self.tabs);
		//Deactivate all and activate first
		self.tabDeactivateAll();
		self.tabs[0].tabActivate();
	}
	
	///@desc Add LuiTab's
	self.addTabs = function(_tabs) {
        self.tabs = _tabs;
		if !is_undefined(self.style) self._initTabs();
        return self;
    }
	
	///@desc Deactivate all tabs
	self.tabDeactivateAll = function() {
		var _tab_count = array_length(self.tabs);
		for (var i = 0; i < _tab_count; ++i) {
		    //Get tab
			var _tab = self.tabs[i];
			//Deactivate it
			_tab.tabDeactivate();
		}
	}
	
	///@desc Removes tab (WIP)
    self.removeTab = function(index) {
        if (index >= 0 && index < array_length(self.tabs)) {
            array_delete(self.tabs, index, 1);
        }
        return self;
    }
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		//Base
		if !is_undefined(self.style.sprite_tabgroup) {
			var _blend_color = self.style.color_main;
			if self.deactivated {
				_blend_color = merge_colour(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_tabgroup, 0, draw_x, draw_y + self.tab_height, self.width, self.height - self.tab_height, _blend_color, 1);
		}
		//Border
		if !is_undefined(self.style.sprite_tabgroup_border) {
			draw_sprite_stretched_ext(self.style.sprite_tabgroup_border, 0, draw_x, draw_y + self.tab_height, self.width, self.height - self.tab_height, self.style.color_border, 1);
		}
	}
	
	self.create = function() {
		if !is_undefined(self.style) {
			self._initHeader();
			if !is_undefined(self.tabs) {
				self._initTabs();
			}
		}
	}
	
	self.onShow = function() {
		//Turn of visible of deactivated tab_container's
		var _tab_count = array_length(self.tabs);
		for (var i = 0; i < _tab_count; ++i) {
			var _tab = self.tabs[i];
			if !_tab.is_active {
				_tab.tab_container.setVisible(false);
			}
		}
	}
}

///@desc Tab, used for LuiTabGroup.
///@arg {String} name
///@arg {String} text
function LuiTab(name = "LuiTab", text = "Tab") : LuiButton(LUI_AUTO, LUI_AUTO, LUI_AUTO, LUI_AUTO, name, text) constructor {
	
	self.is_active = false;
	self.tabgroup = undefined;
	self.tab_container = undefined;
	
	static _initContainer = function() {
		if is_undefined(self.tab_container) {
			self.tab_container = new LuiContainer(, , , , $"_tab_container_{self.element_id}").setVisible(false);
		}
	}
	
	///@desc Activate current tab
	self.tabActivate = function() {
		self.is_active = true;
		self.tab_container.setVisible(true);
		flexpanel_node_style_set_display(self.tab_container.flex_node, flexpanel_display.flex);
		self.flexCalculateLayout();
		self.flexUpdateAll(self.main_ui.flex_node); //???//check if this updates really need here
	}
	
	///@desc Deactivate current tab
	self.tabDeactivate = function() {
		self.is_active = false;
		self.tab_container.setVisible(false);
		flexpanel_node_style_set_display(self.tab_container.flex_node, flexpanel_display.none);
	}
	
	///@desc Works like usual addContent, but redirect add content to tab_container of this tab
	self.addContent = function(elements) {
		self._initContainer();
		self.tab_container.addContent(elements);
		return self;
	}
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		// Base
		if !is_undefined(self.style.sprite_tab) {
			var _blend_color = self.style.color_main;
			if !self.is_active {
				_blend_color = merge_colour(_blend_color, c_black, 0.25);
				if self.mouseHover() {
					_blend_color = merge_colour(_blend_color, self.style.color_hover, 0.5);
					if self.is_pressed == true {
						_blend_color = merge_colour(_blend_color, c_black, 0.5);
					}
				}
			}
			if self.deactivated {
				_blend_color = merge_colour(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_tab, 0, draw_x, draw_y, self.width, self.height, _blend_color, 1);
		}
		
		// Icon
		self._drawIcon();
		
		// Text
		if self.text != "" {
			if !is_undefined(self.style.font_buttons) {
				draw_set_font(self.style.font_buttons);
			}
			if !self.deactivated {
				draw_set_color(self.style.color_font);
			} else {
				draw_set_color(merge_colour(self.style.color_font, c_black, 0.5));
			}
			draw_set_alpha(1);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			var _txt_x = draw_x + self.width / 2;
			var _txt_y = draw_y + self.height / 2;
			_luiDrawTextCutoff(_txt_x, _txt_y, self.text, self.width);
		}
		
		// Border
		if !is_undefined(self.style.sprite_tab_border) {
			draw_sprite_stretched_ext(self.style.sprite_tab_border, 0, draw_x, draw_y, self.width, self.height, self.style.color_button_border, 1);
		}
	}
	
	self.create = function() {
		self._initContainer();
		if sprite_exists(self.icon.sprite) self._calcIconSize();
	}
	
	self.onMouseLeftReleased = function() {
		if self.is_pressed && !self.is_active {
			self.is_pressed = false;
			self.tabgroup.tabDeactivateAll();
			self.tabActivate();
			if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
		}
	}
}