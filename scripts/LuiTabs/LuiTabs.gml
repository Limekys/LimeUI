///@desc Panel with tabs
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String,real} name
///@arg {Real} tab_height
function LuiTabs(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = LUI_AUTO, tab_height = 32) : LuiBase() constructor {
	
	self.name = name;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	_initElement();
	
	self.is_pressed = false;
	self.tabs = undefined;
	self.tab_height = tab_height;
	self.tabs_header = undefined;
	self.active_tab = undefined;
	
	self.onCreate = function() {
		// Setting up padding for tabs
		self.setPadding(0).setGap(0);
		// Init header container for tabs
		self._initHeader();
		// Add header
		self.addContent(self.tabs_header);
		self.tabs_header.setGap(0).setMinHeight(self.tab_height);
		// Init tab's
		self._initTabs();
	}
	
	///@desc Create header container for tabs
	///@ignore
	static _initHeader = function() {
		if is_undefined(self.tabs_header) {
			self.tabs_header = new LuiRow(, , , self.tab_height, "_tabs_header_" + string(self.element_id));
		}
	}
	
	///@desc Create tabs
	///@ignore
	static _initTabs = function() {
		if !is_undefined(self.tabs) {
			if !is_array(self.tabs) self.tabs = [self.tabs];
			var _tab_count = array_length(self.tabs);
			for (var i = 0; i < _tab_count; ++i) {
			    // Get tab
				var _tab = self.tabs[i];
				// Init tab container
				_tab._initContainer();
				// Set tabs parent for tab
				_tab.tabs_parent = self;
				// Add tab container to tabs_parent
				self.addContent(_tab.tab_container);
			}
			//Add tab to header of tabs_parent
			self.tabs_header.addContent(self.tabs);
			//Deactivate all and activate first
			self.tabDeactivateAll();
			self.tabs[0].tabActivate();
			self.active_tab = self.tabs[0];
		}
	}
	
	///@desc Add LuiTab's
	static addTabs = function(_tabs) {
        self.tabs = _tabs;
		if !is_undefined(self.main_ui) self._initTabs();
        return self;
    }
	
	///@desc Switch tab to another
	static switchTab = function(_new_tab) {
	    if (self.active_tab == _new_tab) return;
		
	    if (!is_undefined(self.active_tab)) {
	        self.active_tab.tabDeactivate();
	    }
		
	    _new_tab.tabActivate();
	    self.active_tab = _new_tab;
	}
	
	///@desc Deactivate all tabs
	static tabDeactivateAll = function() {
		var _tab_count = array_length(self.tabs);
		for (var i = 0; i < _tab_count; ++i) {
		    //Get tab
			var _tab = self.tabs[i];
			//Deactivate it
			_tab.tabDeactivate();
		}
	}
	
	///@desc Removes tab (WIP)
    static removeTab = function(index) {
        if (index >= 0 && index < array_length(self.tabs)) {
            array_delete(self.tabs, index, 1);
        }
        return self;
    }
	
	self.draw = function() {
		//Base
		if !is_undefined(self.style.sprite_tabs) {
			var _blend_color = self.style.color_primary;//self.nesting_level == 0 ? self.style.color_primary : merge_color(self.style.color_primary, self.style.color_secondary, 0.25);
			if self.deactivated {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_tabs, 0, self.x, self.y + self.tab_height, self.width, self.height - self.tab_height, _blend_color, 1);
		}
		//Border
		if !is_undefined(self.style.sprite_tabs_border) {
			draw_sprite_stretched_ext(self.style.sprite_tabs_border, 0, self.x, self.y + self.tab_height, self.width, self.height - self.tab_height, self.style.color_border, 1);
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
	
	self.onDestroy = function() {
		if !is_undefined(self.tabs_header) {
			self.tabs_header.destroy();
		}
		self.tabs = -1;
	}
}

///@desc Tab, used for LuiTabs.
///@arg {String,real} name
///@arg {String} text
function LuiTab(name = LUI_AUTO, text = "Tab") : LuiButton(LUI_AUTO, LUI_AUTO, LUI_AUTO, LUI_AUTO, name, text) constructor {
	
	self.is_active = false;
	self.tabs_parent = undefined;
	self.tab_container = undefined;
	
	self.onCreate = function() {
		self._initContainer();
		if sprite_exists(self.icon.sprite) self._calcIconSize();
	}
	
	///@desc Change getContainer function for compatibility with setFlex... functions
	self.getContainer = function() {
		self._initContainer();
		return self.container;
	}
	
	///@ignore
	static _initContainer = function() {
		if is_undefined(self.tab_container) {
			self.tab_container = new LuiContainer(0, 0, , , $"_tab_container_{self.element_id}").setVisible(false).setFlexDisplay(flexpanel_display.none).setFlexGrow(1);
			self.setContainer(self.tab_container);
		}
	}
	
	///@desc Set active state of tab
	static setActiveState = function(_is_active) {
	    self.is_active = _is_active;
	    if (_is_active) {
	        self.tab_container.setVisible(true).setFlexDisplay(flexpanel_display.flex);
	    } else {
	        self.tab_container.setVisible(false).setFlexDisplay(flexpanel_display.none);
	    }
	}
	
	///@desc Activate current tab
	static tabActivate = function() {
		self.setActiveState(true);
	}
	
	///@desc Deactivate current tab
	static tabDeactivate = function() {
		self.setActiveState(false);
	}
	
	///@desc Works like usual addContent, but redirect add content to tab_container of this tab
	self.addContent = function(elements) {
		self._initContainer();
		self.tab_container.addContent(elements);
		return self;
	}
	
	self.draw = function() {
		// Base
		if !is_undefined(self.style.sprite_tab) {
			var _blend_color = self.style.color_primary;
			if !self.is_active {
				_blend_color = merge_color(_blend_color, c_black, 0.25);
				if self.isMouseHovered() {
					_blend_color = merge_color(_blend_color, self.style.color_hover, 0.5);
					if self.is_pressed == true {
						_blend_color = merge_color(_blend_color, c_black, 0.5);
					}
				}
			}
			if self.deactivated {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_tab, 0, self.x, self.y, self.width, self.height, _blend_color, 1);
		}
		
		// Icon
		self._drawIcon();
		
		// Text
		if self.text != "" {
			if !is_undefined(self.style.font_buttons) {
				draw_set_font(self.style.font_buttons);
			}
			if !self.deactivated {
				draw_set_color(self.style.color_text);
			} else {
				draw_set_color(merge_color(self.style.color_text, c_black, 0.5));
			}
			draw_set_alpha(1);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			var _txt_x = self.x + self.width / 2;
			var _txt_y = self.y + self.height / 2;
			_luiDrawTextCutoff(_txt_x, _txt_y, self.text, self.width);
		}
		
		// Border
		if !is_undefined(self.style.sprite_tab_border) {
			draw_sprite_stretched_ext(self.style.sprite_tab_border, 0, self.x, self.y, self.width, self.height, self.style.color_border, 1);
		}
	}
	
	self.onMouseLeftReleased = function() {
		if self.is_pressed && !self.is_active {
			self.is_pressed = false;
			self.tabs_parent.switchTab(self);
			if self.style.sound_click != undefined audio_play_sound(self.style.sound_click, 1, false);
		}
	}
	
	self.onDestroy = function() {
		if !is_undefined(self.tab_container) {
			self.tab_container.destroy();
		}
	}
}