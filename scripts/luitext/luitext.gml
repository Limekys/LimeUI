function LuiText(x, y, width = undefined, height = 16, text = "sample text") : LuiBase() constructor {
	self.name = "LuiText";
	self.pos_x = x;
	self.pos_y = y;
	self.width = (width == undefined) ? string_width(text) : width;
	self.height = height;
	
	self.value = text;
	self.text_halign = fa_center;
	
	self.draw = function(x = self.x, y = self.y) {
		draw_set_alpha(1);
		draw_set_color(LUI_COLOR_FONT);
		draw_set_halign(self.text_halign);
		draw_set_valign(fa_middle);
		draw_set_font(LUI_FONT_BUTTONS);
		var _txt_x = x + self.width / 2;
		var _txt_y = y + self.height / 2;
		draw_text(_txt_x, _txt_y, self.value);
	}
	
	self.set_halign = function(align) {
		self.text_halign = align;
		return self;
	}
}