///@desc Show message with custom message text and button text
///@arg {Struct.LuiMain} ui
///@arg {Real} width
///@arg {Real} height
///@arg {String} text
function showLuiMessage(ui, width = LUI_AUTO, height = LUI_AUTO, text = "", button_text = "Close") {
	// Black block area
	var _block_area = new LuiBlockArea(0, 0, display_get_gui_width(), display_get_gui_height(), "__lui_block_area_" + md5_string_utf8(text));
	// Pop up message panel
	var _calc_width = width;
	if _calc_width == LUI_AUTO {
		draw_set_font(ui.style.font_default);
		_calc_width = max(string_width(text), string_width(button_text)) + ui.style.padding * 2;
	}
	var _panel = new LuiPanel(, , _calc_width, height, "popupPanel").setValign(fa_middle).setHalign(fa_center);
	// Text
	var _txt = new LuiText(, , , , "popupText", text).setTextHalign(fa_center);
	// Button
	var _btn = new LuiButton(, , , , "popupButton", button_text, function() {
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
	//_block_area.setDepth(1000);
}