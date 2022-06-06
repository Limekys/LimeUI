function LuiText(x = LUI_AUTO, y = LUI_AUTO, width = 128, height = 16, text = "sample text") : LuiBase() constructor {
	self.text = text;
	self.x = x;
	self.y = y;
	self.width = width;
	self.height = height;
	
	self.draw = function() {
		draw_set_alpha(1);
		draw_set_color(LUI_FONT_COLOR);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_font(LUI_FONT_BUTTONS);
		var _txt_x = self.x + self.width / 2;
		var _txt_y = self.y + self.height / 2;
		draw_text(_txt_x, _txt_y, self.text);
	}
}