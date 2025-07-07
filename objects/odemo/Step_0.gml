LIME_RESOLUTION.update();

my_ui.update();

checkAndRescaleUI(my_ui, display_get_gui_width(), display_get_gui_height());

if demo_loading_state {
	demo_loading_value = ApproachDelta(demo_loading_value, 100, 10);
}

// Smooth moving for tab_group (WIP) //???//
if tab_group.x != tab_group_target_x || tab_group.y != tab_group_target_y {
	tab_group.setPosition(tab_group_target_x, tab_group_target_y);
	//tab_group.x = lerp(tab_group.x, tab_group_target_x, 0.1);
	//tab_group.y = lerp(tab_group.y, tab_group_target_y, 0.1);
	//tab_group.setPosX(SmoothApproachDelta(tab_group.x, tab_group_target_x, 0.1));
	//tab_group.setPosY(SmoothApproachDelta(tab_group.y, tab_group_target_y, 0.1));
}

// Scrolling test

var _scrl_pnl = my_ui.getElement("firstScrollPanel");
if _scrl_pnl != -1 {
	if _scrl_pnl.visible {
		//_scrl_pnl.scroll_target_offset_y -= 1;
	}
}