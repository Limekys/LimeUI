///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} text
function LuiText(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, text = "sample text") : LuiBase() constructor {
	
	if !is_undefined(self.style.font_default) draw_set_font(self.style.font_default);
	
	self.name = "LuiText";
	self.value = text;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	init_element();
	
	self.min_width = self.auto_width == true ? string_width(self.value) : width;
	self.height = self.auto_height == true ? max(self.min_height, string_height(self.value)) : height;
	self.text_halign = fa_left;
	self.text_valign = fa_middle;
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		//Set font properties
		if !is_undefined(self.style.font_default) {
			draw_set_font(self.style.font_default);
		}
		draw_set_color(self.style.color_font);
		draw_set_alpha(1);
		draw_set_halign(self.text_halign);
		draw_set_valign(self.text_valign);
		//Calculate right text align
		var _txt_x = draw_x + self.width / 2;
		var _txt_y = draw_y + self.height / 2;
		switch(self.text_halign) {
			case fa_left: 
				_txt_x = draw_x;
			break;
			case fa_center:
				_txt_x = draw_x + self.width / 2;
			break;
			case fa_right: 
				_txt_x = draw_x + self.width - string_width(self.value);
			break;
		}
		switch(self.text_valign) {
			case fa_top: 
				_txt_y = draw_y;
			break;
			case fa_middle:
				_txt_y = draw_y + self.height / 2;
			break;
			case fa_bottom: 
				_txt_y = draw_y + self.height - string_height(self.value);
			break;
		}
		//Draw text
		if self.value != "" {
			self.draw_text_cutoff(_txt_x, _txt_y, self.value, self.width);
		}
	}
	
	self.set_text_halign = function(halign) {
		self.text_halign = halign;
		return self;
	}
	
	self.set_text_valign = function(valign) {
		self.text_valign = valign;
		return self;
	}
	
	return self;
}