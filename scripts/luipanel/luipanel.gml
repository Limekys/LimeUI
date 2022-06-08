function LuiPanel(x = LUI_AUTO, y = LUI_AUTO, width = 256, height = 256, name = "LuiPanel") : LuiBase() constructor {
	self.name = name;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	
	self.draw = function() {
		draw_sprite_stretched_ext(LUI_SPRITE_PANEL, 0, x, y, width, height, c_white, 1);
		draw_sprite_stretched_ext(LUI_SPRITE_PANEL_BORDER, 0, x, y, width, height, c_gray, 1);
	}
}