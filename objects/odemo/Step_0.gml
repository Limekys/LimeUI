LIME_RESOLUTION.update();

my_ui.update();

luiRescale(my_ui, display_get_gui_width(), display_get_gui_height());

if demo_loading_state {
	demo_loading_value = ApproachDelta(demo_loading_value, 100, 10);
}

// Scrolling test
/*
var _scrl_pnl = my_ui.getElement("firstScrollPanel");
if _scrl_pnl != -1 {
	if _scrl_pnl.visible {
		_scrl_pnl.scroll_target_offset_y -= 1;
	}
}