function LuiProgressBar(x = LUI_AUTO, y = LUI_AUTO, width = 128, height = 16, value_min = 0, value_max = 100, show_value = true, value = 0) : LuiBase() constructor {
	self.name = "LuiProgressBar";
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	
	self.value_min = min(value_min, value_max);
	self.value_max = max(value_min, value_max);
	self.value = value;
	self.show_value = show_value;
	
	self.draw = function() {
		var _bar_value = range(self.value, self.value_min, self.value_max, 0, 1);
		draw_sprite_stretched_ext(LUI_SPRITE_PANEL, 0, x, y, width, height, c_white, 1);
		draw_sprite_stretched_ext(LUI_SPRITE_PANEL, 0, x, y, width * _bar_value, height, c_green, 1);
		draw_sprite_stretched_ext(LUI_SPRITE_PANEL_BORDER, 0, x, y, width, height, c_gray, 1);
		
		if self.show_value {
			
		}
	}
}