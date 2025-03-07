/// @desc UPDATE UI
my_ui.update();

if demo_loading_state {
	demo_loading_value = ApproachDelta(demo_loading_value, 100, 10);
}

// Smooth moving for tab_group lerp(tab_group.pos_y, tab_group_target_y, 0.25) (WIP) //???//
if tab_group.x != tab_group_target_x || tab_group.y != tab_group_target_y {
	tab_group.setPosition(tab_group_target_x, tab_group_target_y);
}

checkAndRescaleWindow(my_ui);

// Scrolling test
/*
var _scrl_pnl = my_ui.getElement("firstScrollPanel");
if _scrl_pnl != -1 {
	if _scrl_pnl.visible {
		_scrl_pnl.scroll_target_offset_y -= 1;
	}
}