///@desc Just for developer, ignore it!

if !my_ui.isInteractingKeyboard() {
	var _panel = my_panel_3;
	_panel.setVisible(!_panel.visible);
	//tabs.setVisible(!tabs.visible);
	//_panel.deactivate();
	if _panel != -1 {
		//_panel.destroy();
		//my_panel = -1;
	}
	
	//tabs.setVisible(!tabs.visible);
	//_panel.setVisible(!_panel.visible);
	
	//var _element = my_ui.getElement("firstScrollPanel");
	//if _element != -1 {
		//print("x: ", _element.x, " y: ", _element.y, " view_region: ", _element.view_region.toString());
		//print("cx: ", _element.content[0].x, " cy: ", _element.content[0].y);
	//}
	
	//var _element = my_ui.getElement("tabPanels");
	//print(_element.getData("test"));
	
	//my_ui.setVisible(!my_ui.visible);
	if my_ui.visible {
		my_ui.hide();
	} else {
		my_ui.show();
	}
	
	var _surface_element = my_ui.getElement("LuiSurface");
	print(_surface_element.view_region);
}