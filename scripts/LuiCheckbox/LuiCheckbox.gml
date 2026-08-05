///@desc A button with a boolean value, either marked or unmarked.
/// Available parameters:
/// value
/// text
/// icon_spacing
///@arg {Struct} [_params] Struct with parameters
function LuiCheckbox(_params = {}) : LuiBase(_params) constructor {
	
	self.value = _params[$ "value"] ?? false;
	self.text = _params[$ "text"] ?? "";
	self.icon_spacing = _params[$ "icon_spacing"] ?? 8;
	
	///@desc Set display text of checkbox (render right of checkbox)
	///@arg {string} _text
	static setText = function(_text) {
		self.text = _text;
		return self;
	}
	
	self.draw = function() {
		var _style = self.getStyle();
		// Base
		if !is_undefined(_style.sprite_checkbox) {
			var _blend_color = _style.color_back;
			if self.deactivated {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			var _draw_width = min(self.width, self.height);
			var _draw_height = min(self.width, self.height);
			draw_sprite_stretched_ext(_style.sprite_checkbox, 0, self.x, self.y, _draw_width, _draw_height, _blend_color, 1);
		}
		// Pin
		if !is_undefined(_style.sprite_checkbox_pin) {
			var _blend_color = self.value ? _style.color_accent : _style.color_primary;
			if !self.deactivated {
				if self.isMouseHovered() {
					_blend_color = merge_color(_blend_color, _style.color_hover, 0.5);
				}
			} else {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			var _draw_width = min(self.width, self.height);
			var _draw_height = min(self.width, self.height);
			draw_sprite_stretched_ext(_style.sprite_checkbox_pin, 0, self.x, self.y, _draw_width, _draw_height, _blend_color, 1);
		}
		// Text
		if self.text != "" {
			if !self.deactivated {
				draw_set_color(_style.color_text);
			} else {
				draw_set_color(merge_color(_style.color_text, c_black, 0.5));
			}
			draw_set_alpha(1);
			draw_set_halign(fa_left);
			draw_set_valign(fa_middle);
			if !is_undefined(_style.font_default) {
				draw_set_font(_style.font_default);
			}
			var _draw_width = min(self.width, self.height);
			var _text_width = min(string_width(self.text), self.width - _draw_width - self.icon_spacing);
			self._drawTruncatedText(self.x + _draw_width + self.icon_spacing, self.y + self.height div 2, self.text, _text_width);
		}
		// Border
		if !is_undefined(_style.sprite_checkbox_border) {
			var _draw_width = min(self.width, self.height);
			var _draw_height = min(self.width, self.height);
			draw_sprite_stretched_ext(_style.sprite_checkbox_border, 0, self.x, self.y, _draw_width, _draw_height, _style.color_border, 1);
		}
	}
	
	self.addEvent(LUI_EV_CLICK, function(_e) {
		_e.set(!_e.get());
		var _style = _e.getStyle();
		if !is_undefined(_style.sound_click) {
			audio_play_sound(_style.sound_click, 1, false);
		}
	});
	
	self.addEvent(LUI_EV_MOUSE_ENTER, function(_e) {
		_e.updateMainUiSurface();
	});
	
	self.addEvent(LUI_EV_MOUSE_LEAVE, function(_e) {
		_e.updateMainUiSurface();
	});
	
	self.addEvent(LUI_EV_MOUSE_LEFT_PRESSED, function(_e) {
		_e.updateMainUiSurface();
	});
	
	self.addEvent(LUI_EV_MOUSE_LEFT_RELEASED, function(_e) {
		_e.updateMainUiSurface();
	});
}