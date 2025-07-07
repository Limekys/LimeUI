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
	
	var _element = my_ui.getElement("firstScrollPanel");
	if _element != -1 {
		print("x: ", _element.x, " y: ", _element.y, " view_region: ", _element.view_region.toString());
		print("cx: ", _element.content[0].x, " cy: ", _element.content[0].y);
	}
}