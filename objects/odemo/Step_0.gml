LIME_RESOLUTION.update();

my_ui.update();

luiRescale(my_ui, display_get_gui_width(), display_get_gui_height());

if demo_loading_state {
	demo_loading_value = ApproachDelta(demo_loading_value, 100, 10);
}

// Smooth moving for tabs
tabs_anim_x = SmoothApproachDelta(tabs_anim_x, tabs_target_x, 0.05, 0.1);
tabs_anim_y = SmoothApproachDelta(tabs_anim_y, tabs_target_y, 0.05, 0.1);
tabs.setPosition(tabs_anim_x, tabs_anim_y);

// Scrolling test
/*
var _scrl_pnl = my_ui.getElement("firstScrollPanel");
if _scrl_pnl != -1 {
	if _scrl_pnl.visible {
		_scrl_pnl.scroll_target_offset_y -= 1;
	}
}