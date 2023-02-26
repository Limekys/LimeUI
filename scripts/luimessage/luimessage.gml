///@arg {Any} width
///@arg {Any} height
///@arg {String} text
function LuiMessage(width = 256, height = 128, text = "sample text") : LuiPanel(0, 0) constructor {
	self.name = "LuiMessage";
	self.text = text;
	self.width = width;
	self.height = height;
	self.set_halign(fa_center);
	self.set_valign(fa_middle);
	
	LUI_OVERLAY.add_content(self);
	
	self.add_content([
		new LuiText(, , , , self.text).set_text_halign(fa_center),
		new LuiButton(, , 128, , "Close", function() {
			LUI_OVERLAY.close();
		}).set_valign(fa_bottom).set_halign(fa_center)
	]);
	
	return self;
}