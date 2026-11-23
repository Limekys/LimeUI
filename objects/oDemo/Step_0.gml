LIME_RESOLUTION.update();

my_ui.update();

luiRescale(my_ui, display_get_gui_width(), display_get_gui_height());

if !is_undefined(inventory_inspect_message) && inventory_inspect_message.is_destroyed {
	inventory_inspect_message = undefined;
}

var _inspect_open = !is_undefined(inventory_inspect_message);
if _inspect_open && keyboard_check_pressed(vk_f8) {
	inventory_inspect_message.backdrop_blur = inventory_inspect_message.backdrop_blur > 0 ? 0 : LUI_DEFAULT_ALERT_BLUR;
}

if !_inspect_open && keyboard_check_pressed(vk_f6) {
	render_benchmark_mode = (render_benchmark_mode + 1) mod 3;
	var _use_cache = render_benchmark_mode == 0 ? render_benchmark_original_cache : render_benchmark_mode == 2;
	render_benchmark_panel.setCacheAsSurface(_use_cache);
}

var _label = "";
if _inspect_open {
	_label = inventory_inspect_message.backdrop_blur > 0 ? "Inspect / Blur" : "Inspect / Dim";
} else if render_benchmark_mode != 0 {
	_label = render_benchmark_mode == 1 ? "First panel / Direct" : "First panel / Cached";
}

if _label != render_benchmark_label {
	render_benchmark_label = _label;
	render_benchmark_frames = 0;
	render_benchmark_result = "";
}

if render_benchmark_label != "" && keyboard_check_pressed(vk_f7) {
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
