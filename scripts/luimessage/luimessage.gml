///@arg {Any} width
///@arg {Any} height
///@arg {String} text
function LuiMessage(width = 256, height = 128, text = "sample text") : LuiPanel(0, 0) constructor {
	self.name = "LuiMessage";
	self.text = text;
	self.width = width;
	self.height = height;
	
	LUI_OVERLAY.add_content(self);
	
	self.add_content([
		new LuiText(, , , , self.text).set_halign(fa_center),
		new LuiButton(, , , , "Close", function() {
			LUI_OVERLAY.close();
		})
	]);
	
	self.center();
	
	//self.draw = function() {
	//	draw_set_alpha(1);
	//	draw_set_color(LUI_COLOR_FONT);
	//	draw_set_halign(fa_center);
	//	draw_set_valign(fa_middle);
	//	draw_set_font(LUI_FONT_BUTTONS);
	//	var _txt_x = self.x + self.width / 2;
	//	var _txt_y = self.y + self.height / 2;
	//	draw_text(_txt_x, _txt_y, self.text);
	//}
	
	return self;
}