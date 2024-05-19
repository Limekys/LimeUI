///@arg {Real} width
///@arg {Real} height
///@arg {String} text
function LuiMessage(width = 256, height = 128, text = "sample text") : LuiPanel( , , width, height) constructor {
	self.name = "LuiMessage";
	self.text = text;
	self.width = width;
	self.height = height;
	self.set_halign(fa_center);
	self.set_valign(fa_middle);
	
	//???//Temporary saving of the main ui to the LUI_OVERLAY variable
	LUI_OVERLAY.main_ui = global.lui_main_ui;
	global.lui_main_ui = LUI_OVERLAY;
	
	LUI_OVERLAY.add_content(self);
	
	self.add_content([
		new LuiText(, , , , self.text).set_text_halign(fa_center),
		new LuiButton(, , 128, , "Close", function() {
			//???//Back main ui from LUI_OVERLAY variable
			global.lui_main_ui = LUI_OVERLAY.main_ui;
			LUI_OVERLAY.close();
		}).set_valign(fa_bottom).set_halign(fa_center)
	]);
	
	return self;
}