///@desc A framed panel with optional horizontal and vertical scrolling.
/// Available parameters:
/// scroll_x
/// scroll_y
///@arg {Struct} [_params] Panel parameters
function LuiPanel(_params = {}) : LuiScrollArea(_params) constructor {
	self.ignore_mouse = false;

	// DRAW

	self.draw = function() {
		var _style = self.getStyle();
		var _alpha = draw_get_alpha();
		if !is_undefined(_style.sprite_panel) {
			var _color = _style.color_primary;
			if self.deactivated {
				_color = merge_color(_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(_style.sprite_panel, 0, self.x, self.y, self.width, self.height, _color, _alpha);
		}
		if !is_undefined(_style.sprite_panel_border) {
			draw_sprite_stretched_ext(_style.sprite_panel_border, 0, self.x, self.y, self.width, self.height, _style.color_border, _alpha);
		}
	}
}
