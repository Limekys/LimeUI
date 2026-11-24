///@desc Drop-down list.
/// Available parameters:
/// placeholder
///@arg {Struct} [_params] Struct with parameters
function LuiComboBox(_params = {}) : LuiButton(_params) constructor {
	// STATE

	self.placeholder = _params[$ "placeholder"] ?? "";

	self.items = undefined;
	self._selected_item = undefined;
	self.is_open = false;
	self._popup_panel = undefined;
	self._popup_row_height = undefined;
	self.text_width = self.width;

	// PUBLIC API

	///@desc Set placeholder text
	///@arg {string} _placeholder
	static setPlaceholder = function(_placeholder) {
		self.placeholder = _placeholder;
		return self;
	}

	///@desc Toggle combobox open/close
	static toggle = function() {
		if self.is_open {
			self._closePopup();
			return self;
		}
		if is_undefined(self.items) || is_undefined(self.main_ui) || !self.main_ui.isInputAllowed(self) return self;

		if is_undefined(self._popup_panel) {
			self._initComboBoxPanel();
			self._initItems();
		}
		if array_length(self.items) == 0 return self;

		self.is_open = true;
		self._placePopup();
		if !self.is_open return self;

		self._popup_panel.setVisibilitySwitching(true).show().bringToFront().setVisibilitySwitching(false);
		self.main_ui._registerPopup(self, self._popup_panel, method(self, self._closePopup), method(self, self._placePopup));
		self._focusPopupItem();
		self.updateMainUiSurface();
		return self;
	}

	///@desc Add items //???//
	///@arg {struct,array} _items Element or array of elements
	static addItems = function(_items) {
		self.items = _items;
		return self;
	}

	///@desc Remove items //???//
	static removeItem = function(index) {
		//if (index >= 0 && index < array_length(self.items)) {
		//    array_delete(self.items, index, 1);
		//}
		return self;
	}

	// INTERNALS

	///@ignore
	static _initComboBoxPanel = function() {
		var _host = self.main_ui._activeModal() ?? self.main_ui;
		self._popup_panel = new LuiScrollPanel({x: 0, y: 0, width: 1, height: 1, min_width: 1, min_height: 1})
			.setPositionAbsolute().setPadding(4).setGap(0).hide().setVisibilitySwitching(false);
		_host.addContentOriginal(self._popup_panel);
	}

	///@ignore
	static _initItems = function() {
		if !is_array(self.items) {
			self.items = [self.items];
		}
		self._popup_row_height = max(self.min_height, self.height);
		for (var i = 0; i < array_length(self.items); i++) {
			var _item = self.items[i];
			_item.combobox_parent = self;
			_item.setHeight(self._popup_row_height).setFlexShrink(0);
		}
		self._popup_panel.addContent(self.items);
	}

	///@ignore
	static _placePopup = function() {
		var _ui = self.main_ui;
		var _panel = self._popup_panel;
		var _width = min(_ui.width, max(1, self.width));
		var _top = clamp(self.y, 0, _ui.height);
		var _bottom = clamp(self.y + self.height, 0, _ui.height);
		var _below = _ui.height - _bottom;
		var _row_height = max(self.min_height, self.height);
		if _row_height != self._popup_row_height {
			for (var i = 0; i < array_length(self.items); i++) {
				self.items[i].setHeight(_row_height);
			}
			self._popup_row_height = _row_height;
		}
		var _content_style = _panel.getContainer().getStyle();
		var _count = array_length(self.items);
		var _desired_height = _count * _row_height + max(0, _count - 1) * _content_style.gap
			+ 2 * (_content_style.padding + _content_style.border);
		var _height = min(_desired_height, _ui.height);
		var _open_above = _height > _below && _top > _below;
		if _width < 1 || _height < 1 {
			self._closePopup();
			return;
		}

		var _style = self.getMainStyle();
		if _panel.getMainStyle() != _style {
			_panel.setStyle(_style);
		}
		var _host = _panel.parent;
		var _x = clamp(self.x, 0, _ui.width - _width);
		// Shift the popup into the viewport when neither side can fit it.
		var _y = clamp(_open_above ? _top - _height : _bottom, 0, _ui.height - _height);
		_panel.setSize(_width, _height).setPosition(_x - _host.x, _y - _host.y);
	}

	///@ignore
	static _focusPopupItem = function() {
		var _ui = self.main_ui;
		var _panel = self._popup_panel;
		var _items = _panel.getContent();
		var _item = self._selected_item;
		if is_undefined(_item) || !array_contains(_items, _item)
			|| !_ui.isInputAllowed(_item) || !_ui._isKeyboardFocusable(_item) {
			_item = undefined;
			_panel.scroll_target_offset_y = 0;
			if _panel.scroll_offset_y != 0 {
				_panel.scroll_offset_y = 0;
				_panel._applyScroll();
			}
			for (var i = 0, n = array_length(_items); i < n; i++) {
				var _candidate = _items[i];
				if !_ui.isInputAllowed(_candidate) || !_ui._isKeyboardFocusable(_candidate) continue;
				_item = _candidate;
				break;
			}
		}
		var _previous = _ui.element_in_focus;
		if is_undefined(_item) return;
		if _previous != _item {
			if !is_undefined(_previous) && !_previous.is_destroyed {
				_previous.removeFocus();
			}
			if !self.is_open || !_ui.isInputAllowed(_item) return;
			_ui.element_in_focus = _item;
			_item.setFocus();
		}
		if self.is_open && _item == self._selected_item && _ui.element_in_focus == _item {
			_panel._queueFocusReveal(_item);
		}
	}

	///@ignore
	static _closePopup = function() {
		if !self.is_open return;
		self.is_open = false;
		var _ui = self.main_ui;
		_ui._unregisterPopup(self._popup_panel);
		var _focused = _ui.element_in_focus;
		if _ui._isInModal(_focused, self._popup_panel) {
			_ui.element_in_focus = undefined;
			if !_focused.is_destroyed {
				_focused.removeFocus();
			}
			if _ui.isInputAllowed(self) && self._intersects_clip_region {
				_ui.element_in_focus = self;
				self.setFocus();
			}
		}
		if !self._popup_panel.is_destroyed {
			self._popup_panel.setVisibilitySwitching(true).hide().setVisibilitySwitching(false);
		}
		self.updateMainUiSurface();
	}

	///@ignore
	static _calculateTextWidth = function() { //???// not used now
		var _style = self.getStyle();
		if !is_undefined(_style) && !is_undefined(_style.sprite_combobox_arrow) {
			self.text_width = self.width - sprite_get_width(_style.sprite_combobox_arrow)*4;
		} else {
			self.text_width = self.width;
		}
	}

	// DRAW

	self.draw = function() {
		var _style = self.getStyle();
		var _alpha = draw_get_alpha();
		//Base
		if !is_undefined(_style.sprite_combobox) {
			var _blend_color = _style.color_secondary;
			if !self.deactivated {
				if self.isMouseHovered() {
					_blend_color = merge_color(_style.color_secondary, _style.color_hover, 0.5);
					if self.is_pressed == true {
						_blend_color = merge_color(_style.color_secondary, c_black, 0.5);
					}
				}
			} else {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(_style.sprite_combobox, 0, self.x, self.y, self.width, self.height, _blend_color, _alpha);
		}

		//Arrow
		if !is_undefined(_style.sprite_combobox_arrow) {
			var _x_offset = sprite_get_width(_style.sprite_combobox_arrow);
			var _blend_color = _style.color_border;
			if self.deactivated {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			draw_sprite_ext(_style.sprite_combobox_arrow, 0, self.x + self.width - _x_offset, self.y + self.height div 2, 1, self.is_open ? -1 : 1, 0, _blend_color, _alpha);
		}

		//Text
		if !is_undefined(_style.font_buttons) {
			draw_set_font(_style.font_buttons);
		}
		if !self.deactivated {
			draw_set_color(_style.color_text);
		} else {
			draw_set_color(merge_color(_style.color_text, c_black, 0.5));
		}
		var _text_draw_width = self.width;
		if !is_undefined(_style.sprite_combobox_arrow) {
			_text_draw_width -= sprite_get_width(_style.sprite_combobox_arrow)*3;
		}
		var _txt_x = self.x + self.width / 2;
		var _txt_y = self.y + self.height / 2;
		draw_set_alpha(_alpha);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		if is_undefined(self.text) || self.text == "" {
			draw_set_alpha(_alpha * 0.5);
			self._drawTruncatedText(_txt_x, _txt_y, self.placeholder, _text_draw_width);
			draw_set_alpha(_alpha);
		} else {
			self._drawTruncatedText(_txt_x, _txt_y, string(self.text), _text_draw_width);
		}

		//Border
		if !is_undefined(_style.sprite_combobox_border) {
			draw_sprite_stretched_ext(_style.sprite_combobox_border, 0, self.x, self.y, self.width, self.height, _style.color_border, _alpha);
		}
	}

	// EVENT HANDLERS

	self.addEvent(LUI_EV_CREATE, function(_e) {
		_e._calculateTextWidth();
	});

	self.addEvent(LUI_EV_CLICK, function(_e) {
		_e.toggle();
	});

	self.addEvent(LUI_EV_VALUE_UPDATE, function(_e) {
		_e._calculateTextWidth();
	});

	self.addEvent(LUI_EV_HIDE, function(_e) {
		_e._closePopup();
	});

	self.addEvent(LUI_EV_DESTROY, function(_e) {
		_e._closePopup();
		if !is_undefined(_e._popup_panel) {
			_e._popup_panel.destroy();
		} else if !is_undefined(_e.items) {
			var _items = is_array(_e.items) ? _e.items : [_e.items];
			for (var i = 0; i < array_length(_items); i++) {
				var _item = _items[i];
				if !_item.is_destroyed && is_undefined(_item.parent) {
					_item.destroy();
				}
			}
		}
		_e.items = -1;
	});
}

///@desc An element for a drop-down list.
/// Available parameters:
/// text
/// color
///@arg {Struct} [_params] Struct with parameters
function LuiComboBoxItem(_params = {}) : LuiButton(_params) constructor {
	// STATE

	self.combobox_parent = undefined;

	// PUBLIC API

	///@desc Set new combobox text and close combobox
	static chooseItem = function() {
		if is_undefined(self.combobox_parent) || self.combobox_parent.is_destroyed return;
		self.combobox_parent._selected_item = self;
		self.combobox_parent.setText(self.text);
		self.combobox_parent._closePopup();
	}

	// DRAW

	self.draw = function() {
		var _style = self.getStyle();
		var _alpha = draw_get_alpha();

		// Calculate positions
		var _center_x = self.x + self.width / 2;
		var _center_y = self.y + self.height / 2;

		//Base
		if !is_undefined(_style.sprite_combobox_item) {
			var _blend_color = _style.color_secondary;
			if !self.deactivated && self.isMouseHovered() {
				_blend_color = merge_color(_style.color_secondary, _style.color_hover, 0.5);
				if self.is_pressed == true {
					_blend_color = merge_color(_style.color_secondary, c_black, 0.5);
				}
			}
			draw_sprite_stretched_ext(_style.sprite_combobox_item, 0, self.x, self.y, self.width, self.height, _blend_color, _alpha);
		}

		// Icon and text
		self._drawIconAndText(_center_x, _center_y, self.width, _style.color_text);

		//Border
		if !is_undefined(_style.sprite_combobox_item_border) {
			draw_sprite_stretched_ext(_style.sprite_combobox_item_border, 0, self.x, self.y, self.width, self.height, _style.color_border, _alpha);
		}
	}

	// EVENT HANDLERS

	self.addEvent(LUI_EV_CLICK, function(_e) {
		_e.chooseItem();
	});
}
