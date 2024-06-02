///@arg {Real} width
///@arg {Real} height
///@arg {String} text
function LuiMessage(width = 320, height = 160, text = "sample text") : LuiPanel(, , width, height) constructor {
	
	self.name = "LuiMessage";
	self.text = text;
	self.width = width;
	self.height = height;
	init_element();
	
	self.set_halign(fa_center);
	self.set_valign(fa_middle);
	
	//???//Temporary saving of the main ui to the LUI_OVERLAY variable
	LUI_OVERLAY.main_ui = global.lui_main_ui;
	global.lui_main_ui = LUI_OVERLAY;
	
	LUI_OVERLAY.add_content(self);
	
	self.add_content([
		new LuiText(, , , , self.text).set_text_halign(fa_center),
		new LuiButton(, , , , "Close", function() {
			//???//Back main ui from LUI_OVERLAY variable
			global.lui_main_ui = LUI_OVERLAY.main_ui;
			LUI_OVERLAY.close();
		}).set_valign(fa_bottom).set_halign(fa_center)
	]);
	
	return self;
}

///@arg {Struct} ui
///@arg {Real} width
///@arg {Real} height
///@arg {String} text
function LuiShowMessage(ui, width = LUI_AUTO, height = LUI_AUTO, text = "Popup message") {
	var _block_area = new LuiBlockArea(0, 0, display_get_gui_width(), display_get_gui_height(), "block_area");
	var _panel = new LuiPanel(, , width, height, "Message").set_valign(fa_middle).set_halign(fa_center);
	var _txt = new LuiText(, , , , text).set_text_halign(fa_center);
	var _btn = new LuiButton(, , , , "Close", function() {
		self.parent.parent.destroy();
	}).set_valign(fa_bottom).set_halign(fa_center);
	ui.add_content([
		_block_area,
	]);
	_block_area.add_content([
		_panel
	]);
	_panel.add_content([
		_txt, 
		_btn
	]);
}