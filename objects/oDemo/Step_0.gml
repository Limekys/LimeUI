LIME_RESOLUTION.update();

my_ui.update();

luiRescale(my_ui, display_get_gui_width(), display_get_gui_height());

if keyboard_check_pressed(vk_f6) {
	render_benchmark_mode = (render_benchmark_mode + 1) mod 3;
	var _use_cache = render_benchmark_mode == 0 ? render_benchmark_original_cache : render_benchmark_mode == 2;
	render_benchmark_panel.setCacheAsSurface(_use_cache);
	render_benchmark_frames = 0;
	render_benchmark_result = "";
}

if render_benchmark_mode != 0 && keyboard_check_pressed(vk_f7) {
	render_benchmark_frames = 180;
	render_benchmark_cache_us = 0;
	render_benchmark_draw_us = 0;
	render_benchmark_bakes = 0;
	render_benchmark_result = "";
}

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
