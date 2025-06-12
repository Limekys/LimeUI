///@desc Just for developer, ignore it!

if !my_ui.isInteractingKeyboard() {
	var _panel = my_panel;
	//_panel.setVisible(!_panel.visible);
	//tab_group.setVisible(!tab_group.visible);
	//_panel.deactivate();
	if _panel != -1 {
		//_panel.destroy();
		//my_panel = -1;
	}
	
	//tab_group.setVisible(!tab_group.visible);
	//_panel.setVisible(!_panel.visible);
	tab_group.setDepth(-1);
}