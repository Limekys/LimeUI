///@desc Just for developer, ignore it!

if !my_ui.isInteractingKeyboard() {
	var _panel = my_ui.getElement("LuiPanel_3");
	_panel.setVisible(!_panel.visible);
	tab_group.setVisible(!tab_group.visible);
	//_panel.deactivate();
}