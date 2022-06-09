function LuiMessage(width = 256, height = 128, text = "sample text") : LuiPanel() constructor {
	self.name = "LuiMessage";
	self.text = text;
	self.pos_x = LUI_OVERLAY.width div 2 - width div 2;
	self.pos_y = LUI_OVERLAY.height div 2 - height div 2;
	self.width = width;
	self.height = height;
	
	LUI_OVERLAY.add_content(self);
	
	self.add_content([
		new LuiText( , , LUI_STRETCH, , self.text),
		new LuiButton( , self.height - 32 - LUI_PADDING, LUI_STRETCH, , "OK", function(){
			//self.root.destroy();
			LUI_OVERLAY.contents = [];
		})
	]);
	
	//self.draw = function() {
	//	draw_set_alpha(1);
	//	draw_set_color(LUI_FONT_COLOR);
	//	draw_set_halign(fa_center);
	//	draw_set_valign(fa_middle);
	//	draw_set_font(LUI_FONT_BUTTONS);
	//	var _txt_x = self.x + self.width / 2;
	//	var _txt_y = self.y + self.height / 2;
	//	draw_text(_txt_x, _txt_y, self.text);
	//}
}