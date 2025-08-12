///@desc A visually visible container for placing elements in it.
///@arg {Struct} [_params]
function LuiPanel(_params = {}) : LuiBase(_params) constructor {
	
	self.allow_rescaling = _params[$ "allow_rescaling"] ?? false; //???//
	
	self.draw = function() {
		//Shadow
		//var _left = (sprite_get_width(sUI_Square_21r_shadow) - sprite_get_width(self.style.sprite_panel)) div 2;
		//var _right = (sprite_get_width(sUI_Square_21r_shadow) - sprite_get_width(self.style.sprite_panel)) div 2;
		//var _top = (sprite_get_height(sUI_Square_21r_shadow) - sprite_get_height(self.style.sprite_panel)) div 2 - 2;
		//var _bottom = (sprite_get_height(sUI_Square_21r_shadow) - sprite_get_height(self.style.sprite_panel)) div 2 + 1;
		//draw_sprite_stretched_ext(sUI_Square_21r_shadow, 0, self.x - _left, self.y - _top, self.width + _right*2, self.height + _bottom*2, c_white, 1);
		// Base
		if !is_undefined(self.style.sprite_panel) {
			var _blend_color = self.style.color_primary; //???// self.nesting_level == 1 ? self.style.color_primary : merge_color(self.style.color_primary, self.style.color_secondary, 0.25);
			if self.deactivated {
				_blend_color = merge_color(_blend_color, c_black, 0.5);
			}
			draw_sprite_stretched_ext(self.style.sprite_panel, 0, self.x, self.y, self.width, self.height, _blend_color, 1);
		}
		// Border
		if !is_undefined(self.style.sprite_panel_border) {
			draw_sprite_stretched_ext(self.style.sprite_panel_border, 0, self.x, self.y, self.width, self.height, self.style.color_border, 1);
		}
		// Debug
		if self.allow_rescaling {
			var _offset = 8;
			draw_set_color(c_red);
			draw_set_alpha(0.5);
			draw_rectangle(self.x + self.width - _offset, self.y + self.height - _offset, self.x + self.width, self.y + self.height, false);
		}
	}
}