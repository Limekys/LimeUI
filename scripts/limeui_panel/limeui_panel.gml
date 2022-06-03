function LUI_Panel(x = LUI_AUTO, y = LUI_AUTO, width = 128, height = 64, name = "panel") : LUI_Base() constructor {
	self.name = name;
	self.x = x;
	self.y = y;
	self.width = width;
	self.height = height;
	
	self.draw = function() {
		draw_sprite_stretched_ext(LUI_SPRITE_PANEL, 0, x, y, width, height, c_white, 1);
		draw_sprite_stretched_ext(LUI_SPRITE_PANEL_BORDER, 0, x, y, width, height, c_gray, 1);
	}
}