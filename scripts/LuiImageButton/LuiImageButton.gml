///@desc This item displays the specified sprite with certain settings but works like a button.
/// Available parameters:
/// value
/// subimg
/// color
/// alpha
/// maintain_aspect
///@arg {Struct} [_params] Struct with parameters
function LuiImageButton(_params = {}) : LuiImage(_params) constructor {
	
	// DRAW

	self.draw = function() {
		var _style = self.getStyle();
		var _blend_color = self.color_blend;
		if self.deactivated {
			_blend_color = merge_color(_blend_color, c_black, 0.5);
		} else if self.isMouseHovered() {
			_blend_color = merge_color(_blend_color, _style.color_hover, 0.5);
			if self.is_pressed {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
		}
		self._drawImage(_blend_color);
	}
	
	// EVENT HANDLERS

	self.addEvent(LUI_EV_CLICK, function(_e) {
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
