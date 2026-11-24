///@desc Panel with tabs
/// Available parameters:
/// tab_height
/// tab_indent
///@arg {Struct} [_params] Struct with parameters
function LuiTabs(_params = {}) : LuiPanel(_params) constructor {
	// STATE

	self.tab_height = _params[$ "tab_height"] ?? LUI_AUTO;
	self.tab_indent = _params[$ "tab_indent"] ?? 0;

	self.tabs = [];
	self.tabs_header = undefined;
	self.active_tab = undefined;
	self._viewport_resize_handler = undefined;

	// PUBLIC API

	///@desc Set tabs height
	///@arg {real} _tab_height
	static setTabHeight = function(_tab_height) {
		self.tab_height = _tab_height;
		if !is_undefined(self.tabs_header) {
			self.tabs_header.setMinHeight(self.tab_height).setHeight(self.tab_height);
		}
		return self;
	}

	///@desc Set tabs indent
	///@arg {real} _tab_indent
	static setTabIndent = function(_tab_indent) {
		self.tab_indent = _tab_indent;
		self.setGap(self.tab_indent);
		if !is_undefined(self.tabs_header) {
			self.tabs_header.setGap(self.tab_indent);
		}
		return self;
	}

	///@desc Appends a tab to this group.
	///@arg {Struct} _tab LuiTab instance
	///@return {Struct} This tab group
	static addTab = function(_tab) {
		if self.is_destroyed || !is_struct(_tab) || !is_instanceof(_tab, LuiTab) return self;
		if _tab.is_destroyed || !is_undefined(_tab.tabs_parent) || !is_undefined(_tab.main_ui) return self;

		_tab.tabs_parent = self;
		array_push(self.tabs, _tab);
		if !is_undefined(self.tabs_header) && !is_undefined(self.tabs_header.main_ui) {
			self._attachTab(_tab);
		}
		return self;
	}

	///@desc Appends one or more tabs.
	///@arg {Struct|Array} _tabs Tab or array of tabs
	///@return {Struct} This tab group
	static addTabs = function(_tabs) {
		if !is_array(_tabs) return self.addTab(_tabs);
		for (var i = 0, n = array_length(_tabs); i < n; i++) {
			self.addTab(_tabs[i]);
		}
		return self;
	}

	///@desc Finds a tab by its element name.
	///@arg {String} _name Tab name
	///@return {Struct|Undefined} Matching tab, or undefined if absent
	static getTab = function(_name) {
		if self.is_destroyed || _name == LUI_AUTO_NAME return undefined;
		for (var i = 0, n = array_length(self.tabs); i < n; i++) {
			var _tab = self.tabs[i];
			if !_tab.is_destroyed && _tab.name == _name return _tab;
		}
		return undefined;
	}

	///@desc Switches to a tab belonging to this group.
	///@arg {String|Struct} _new_tab Tab name or LuiTab instance
	static switchTab = function(_new_tab) {
		if is_string(_new_tab) {
			_new_tab = self.getTab(_new_tab);
		}
		if self.is_destroyed || !is_struct(_new_tab) || _new_tab.is_destroyed
			|| !array_contains(self.tabs, _new_tab) || self.active_tab == _new_tab return;

		if !is_undefined(self.active_tab) {
			if self.auto_height && is_undefined(self._requested_height) && self.height > self._content_min_height {
				self._setTabHeightFloor(self.height);
			}
			self.active_tab.tabDeactivate();
		}
		self.active_tab = _new_tab;
		_new_tab.tabActivate();
	}

	///@desc Deactivates every tab in this group.
	static tabDeactivateAll = function() {
		for (var i = 0, n = array_length(self.tabs); i < n; i++) {
			self.tabs[i].tabDeactivate();
		}
		self.active_tab = undefined;
	}

	///@desc Removes and destroys a tab and its contents.
	///@arg {Real|String|Struct} index Zero-based index, name, or tab instance
	///@return {Struct} This tab group
	static removeTab = function(index) {
		if self.is_destroyed return self;
		var _tab = index;
		if is_string(index) {
			_tab = self.getTab(index);
		} else if is_real(index) {
			if index < 0 || index != floor(index) || index >= array_length(self.tabs) return self;
			_tab = self.tabs[index];
		}
		if is_struct(_tab) && array_contains(self.tabs, _tab) {
			_tab.destroy();
		}
		return self;
	}

	// INTERNALS

	///@ignore
	static _attachTab = function(_tab) {
		if _tab.is_destroyed || !is_undefined(_tab.main_ui) return;
		_tab._initContainer();
		self.addContentOriginal(_tab.tab_container);
		self.tabs_header.addContent(_tab);
		if is_undefined(self.active_tab) {
			self.switchTab(_tab);
		}
	}

	///@ignore
	static _dropTab = function(_tab) {
		if self.is_destroyed return;
		var _index = array_get_index(self.tabs, _tab);
		if _index < 0 return;
		array_delete(self.tabs, _index, 1);
		var _count = array_length(self.tabs);
		if self.active_tab == _tab {
			self.active_tab = undefined;
			if _count > 0 {
				self.switchTab(self.tabs[min(_index, _count - 1)]);
			}
		}
		if _count == 0 && self._content_min_height > 0 {
			self._setTabHeightFloor(0);
		}
	}

	///@ignore
	static _setTabHeightFloor = function(_height) {
		self._content_min_height = _height;
		if !is_undefined(self.main_ui) {
			self._applyStyleMinSize(self.getStyle());
			self.updateMainUiFlex();
		}
	}

	// DRAW

	self.draw = function() {
		var _style = self.getStyle();
		//Base
		if !is_undefined(_style.sprite_tabs) {
			var _blend_color = _style.color_primary;//self.nesting_level == 0 ? _style.color_primary : merge_color(_style.color_primary, _style.color_secondary, 0.25);
			if self.deactivated {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(_style.sprite_tabs, 0, self.x, self.y + self.tab_height + self.tab_indent, self.width, self.height - self.tab_height - self.tab_indent, _blend_color, 1);
		}
		//Border
		if !is_undefined(_style.sprite_tabs_border) {
			draw_sprite_stretched_ext(_style.sprite_tabs_border, 0, self.x, self.y + self.tab_height + self.tab_indent, self.width, self.height - self.tab_height - self.tab_indent, _style.color_border, 1);
		}
	}

	// EVENT HANDLERS

	self.addEvent(LUI_EV_CREATE, function(_e) {
		// Setting up padding for tabs
		_e.setPadding(0).setGap(_e.tab_indent);
		_e.tabs_header = new LuiRow({height: _e.tab_height}).setGap(_e.tab_indent).setMinHeight(_e.tab_height);
		_e.addContentOriginal(_e.tabs_header);
		var _tabs = _e.tabs;
		for (var i = 0, n = array_length(_tabs); i < n; i++) {
			_e._attachTab(_tabs[i]);
		}
		// Correct tab height
		var _style = _e.tabs_header.getStyle();
		if _e.tab_height == LUI_AUTO || _e.tab_height < _style.min_height {
			_e.setTabHeight(_style.min_height);
		}
		_e._viewport_resize_handler = method(_e, function(_ui) {
			if !self.is_destroyed && self._content_min_height > 0 {
				self._setTabHeightFloor(0);
			}
		});
		_e.main_ui.addEvent(LUI_EV_SIZE_UPDATE, _e._viewport_resize_handler);
	});

	self.addEvent(LUI_EV_SHOW, function(_e) {
		//Turn of visible of deactivated tab_container's
		var _tab_count = array_length(_e.tabs);
		for (var i = 0; i < _tab_count; ++i) {
			var _tab = _e.tabs[i];
			if !_tab.is_active {
				_tab.tab_container.setVisible(false);
			}
		}
	});

	self.addEvent(LUI_EV_DESTROY, function(_e) {
		if !is_undefined(_e._viewport_resize_handler) {
			_e.main_ui.removeEvent(LUI_EV_SIZE_UPDATE, _e._viewport_resize_handler);
			_e._viewport_resize_handler = undefined;
		}
		for (var i = 0, n = array_length(_e.tabs); i < n; i++) {
			_e.tabs[i].destroy();
		}
		_e.tabs = [];
		_e.active_tab = undefined;
	});
}

///@desc Tab, used for LuiTabs.
/// Available parameters:
/// text
/// color
///@arg {Struct} [_params] Struct with parameters
function LuiTab(_params = {}) : LuiButton(_params) constructor {
	// STATE

	self.is_active = false;
	self.tabs_parent = undefined;
	self.tab_container = undefined;

	// PUBLIC API

	///@desc Change getContainer function for compatibility with setFlex... functions
	self.getContainer = function() {
		self._initContainer();
		return self.container;
	}

	///@desc Works like usual addContent, but redirect add content to tab_container of this tab
	self.addContent = function(elements) {
		self._initContainer();
		self.tab_container.addContent(elements);
		return self;
	}

	///@desc Set active state of tab
	///@arg {bool} _is_active
	static setActiveState = function(_is_active) {
		self._initContainer();
		self.is_active = _is_active;
		if _is_active {
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

	// INTERNALS

	///@ignore
	static _initContainer = function() {
		if is_undefined(self.tab_container) {
			self.tab_container = new LuiContainer({x: 0, y: 0}).setVisible(false).setFlexDisplay(flexpanel_display.none).setFlexGrow(1);
			self.setContainer(self.tab_container);
		}
	}

	// DRAW

	self.draw = function() {
		var _style = self.getStyle();
		// Calculate colors
		var _blend_color = self.button_color ?? _style.color_primary;
		var _blend_text = _style.color_text;
		if self.deactivated {
			_blend_color = merge_color(_blend_color, c_black, 0.5);
			_blend_text = merge_color(_blend_text, c_black, 0.5);
		} else if !self.is_active {
			_blend_color = merge_color(_blend_color, c_black, 0.25);
			if self.isMouseHovered() {
				_blend_color = merge_color(_blend_color, _style.color_hover, 0.5);
				if self.is_pressed {
					_blend_color = merge_color(_blend_color, c_black, 0.5);
				}
			}
		}

		// Calculate positions
		var _center_x = self.x + self.width / 2;
		var _center_y = self.y + self.height / 2;

		// Base
		if !is_undefined(_style.sprite_tab) {
			draw_sprite_stretched_ext(_style.sprite_tab, 0, self.x, self.y, self.width, self.height, _blend_color, 1);
		}

		// Icon and text
		self._drawIconAndText(_center_x, _center_y, self.width, _blend_text);

		// Border
		if !is_undefined(_style.sprite_tab_border) {
			draw_sprite_stretched_ext(_style.sprite_tab_border, 0, self.x, self.y, self.width, self.height, _style.color_border, 1);
		}
	}

	// EVENT HANDLERS

	self.addEvent(LUI_EV_CREATE, function(_e) {
		_e._initContainer();
	});

	self.addEvent(LUI_EV_CLICK, function(_e) {
		if !_e.is_active && !is_undefined(_e.tabs_parent) {
			_e.tabs_parent.switchTab(_e);
		}
	});

	self.addEvent(LUI_EV_DESTROY, function(_e) {
		if !is_undefined(_e.tab_container) {
			_e.tab_container.destroy();
		}
		if !is_undefined(_e.tabs_parent) {
			_e.tabs_parent._dropTab(_e);
			_e.tabs_parent = undefined;
		}
	});
}
