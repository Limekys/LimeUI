/// @desc UPDATE UI
my_ui.update();

if demo_loading_state {
	if demo_loading.get() < 100 {
		demo_loading.set(demo_loading.get() + 0.1);
	}
}

// Smooth moving for tab_group lerp(tab_group.pos_y, tab_group_target_y, 0.25) (WIP) //???//
if tab_group.x != tab_group_target_x || tab_group.y != tab_group_target_y {
	tab_group.setPosition(tab_group_target_x, tab_group_target_y);
}

checkAndRescaleWindow(my_ui);

var _scrl_pnl = my_ui.getElement("firstScrollPanel");
if _scrl_pnl != -1 {
	if _scrl_pnl.visible {
		//_scrl_pnl.scroll_target_offset_y -= 1;
	}
}