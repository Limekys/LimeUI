///@arg {Real} width
///@arg {Real} height
///@arg {String} text
///@ignore
function LuiMessage(width = 320, height = 160, text = "sample text") : LuiPanel(, , width, height) constructor {
	
	self.name = "LuiMessage";
	self.text = text;
	self.width = width;
	self.height = height;
	initElement();
	
	self.setHalign(fa_center);
	self.setValign(fa_middle);
	
	//???//Temporary saving of the main ui to the LUI_OVERLAY variable
	LUI_OVERLAY.main_ui = global.lui_main_ui;
	global.lui_main_ui = LUI_OVERLAY;
	
	LUI_OVERLAY.addContent(self);
	
	self.addContent([
		new LuiText(, , , , self.text).setTextHalign(fa_center),
		new LuiButton(, , , , "Close", function() {
			//???//Back main ui from LUI_OVERLAY variable
			global.lui_main_ui = LUI_OVERLAY.main_ui;
			LUI_OVERLAY.close();
		}).setValign(fa_bottom).setHalign(fa_center)
	]);
	
	return self;
}

///@arg {Struct} ui
///@arg {Real} width
///@arg {Real} height
///@arg {String} text
function LuiShowMessage(ui, width = LUI_AUTO, height = LUI_AUTO, text = "Popup message") {
	var _block_area = new LuiBlockArea(0, 0, display_get_gui_width(), display_get_gui_height(), "block_area");
	var _panel = new LuiPanel(, , width, height, "Message").setValign(fa_middle).setHalign(fa_center);
	var _txt = new LuiText(, , , , text).setTextHalign(fa_center);
	var _btn = new LuiButton(, , , , "Close", function() {
		self.parent.parent.destroy();
	}).setValign(fa_bottom).setHalign(fa_center);
	ui.addContent([
		_block_area.addContent([
			_panel.addContent([
				_txt, 
				_btn
			])
		])
	]);
	_block_area.setDepth(1000);
}