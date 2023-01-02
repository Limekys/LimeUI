function LuiText(x, y, width, height, text = "sample text") : LuiBase() constructor {
	self.name = "LuiText";
	self.pos_x = x;
	self.pos_y = y;
	self.width = (width == undefined) ? string_width(text) : width;
	self.height = (height == undefined) ? max(self.min_height, string_height(text)) : height;
	
	self.value = text;
	self.text_halign = fa_left;
	self.text_valign = fa_middle;
	
	self.draw = function(x = self.x, y = self.y) {
		draw_set_font(LUI_FONT_BUTTONS);
		draw_set_color(LUI_COLOR_FONT);
		draw_set_alpha(1);
		draw_set_halign(self.text_halign);
		draw_set_valign(self.text_valign);
		var _txt_x = x + self.width / 2;
		var _txt_y = y + self.height / 2;
		switch(self.text_halign) {
			case fa_left: 
				_txt_x = x;
			break;
			case fa_center:
				_txt_x = x + self.width / 2;
			break;
			case fa_right: 
				_txt_x = x + self.width - string_width(self.value);
			break;
		}
		switch(self.text_valign) {
			case fa_top: 
				_txt_y = y;
			break;
			case fa_middle:
				_txt_y = y + self.height / 2;
			break;
			case fa_bottom: 
				_txt_y = y + self.height - string_height(self.value);
			break;
		}
		draw_text(_txt_x, _txt_y, self.value);
	}
	
	self.set_halign = function(halign) {
		self.text_halign = halign;
		return self;
	}
	self.set_valign = function(valign) {
		self.text_valign = valign;
		return self;
	}
}