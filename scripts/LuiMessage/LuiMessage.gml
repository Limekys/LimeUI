///@desc Modal message dialog widget.
/// Available parameters:
/// text - message text (default: "")
/// button_text - button label (default: "OK")
/// width - dialog panel width (default: LUI_AUTO)
/// height - dialog panel height (default: LUI_AUTO)
///@arg {Struct} [_params] Struct with parameters
function LuiMessage(_params = {}) : LuiBox(_params) constructor {
	
	self.message_text = _params[$ "text"] ?? "";
	self.button_text = _params[$ "button_text"] ?? "OK";
	self.dialog_width = _params[$ "width"] ?? LUI_AUTO;
	self.dialog_height = _params[$ "height"] ?? LUI_AUTO;
	
	///@desc Close the message dialog
	static close = function() {
		self.destroy();
	}
	
	self.addEvent(LUI_EV_CREATE, function(_e) {
		
		// Overlay setup: full-screen, absolute position in 0,0, centered, on top
		_e.setPositionAbsolute()
			.setPosition(0,0)
			.setFullSize()
			.centerContent()
			.bringToFront();
		
		// Calculate panel width based on content and style
		var _panel_width = _e.dialog_width;
		if _panel_width == LUI_AUTO {
			var _panel_min_width = 256;
			var _style = _e.getStyle();
			if (!is_undefined(_style) && !is_undefined(_style.font_default)) {
				draw_set_font(_style.font_default);
			}
			var _padding = is_undefined(_style) ? 0 : (_style.padding ?? 0);
			_panel_width = max(
				_panel_min_width,
				max(string_width(_e.message_text), string_width(_e.button_text)) + _padding * 2
			);
		}
		
		// Build internal structure
		var _container = new LuiColumn();
		var _panel = new LuiPanel({width: _panel_width, height: _e.dialog_height});
		
		// Panel pop-in animation
		_panel.visual_alpha = 0;
		_panel.visual_scale_x = 0;
		_panel.visual_scale_y = 0;
		self.main_ui.animate(_panel, "visual_alpha", 1, 0.25);
		self.main_ui.animate(_panel, "visual_scale_x", 1, 0.45, global.Ease.OutBack);
		self.main_ui.animate(_panel, "visual_scale_y", 1, 0.45, global.Ease.OutBack);
		
		// Text
		var _txt_message = new LuiText({
			value: _e.message_text,
			overflow: LUI_TEXT_OVERFLOW.WrapScale
		}).setTextHalign(fa_center);
		
		if _e.dialog_height != LUI_AUTO {
			_txt_message.setFullSize();
		}
		
		// Button
		var _btn_close = new LuiButton({text: _e.button_text}).setData("message", _e);
		_btn_close.addEvent(LUI_EV_CLICK, function(_btn) {
			var _message = _btn.getData("message");
			_message.close();
		});
		
		// Assemble
		_panel.addContent([
			_container.addContent([
				_txt_message
			]),
			new LuiColumn()
				.setFlexGrow(1)
				.setFlexJustifyContent(flexpanel_justify.flex_end)
				.addContent([
					_btn_close
				])
		]);
		
		_e.addContent(_panel);
	});
}