LIME_RESOLUTION.update();

if tabs.active_tab == tab_stress_test && is_undefined(stress_test_panel) {
	stress_test_panel = demoStressTest(tab_stress_test);
}

if !is_undefined(inventory_inspect_message) && inventory_inspect_message.is_destroyed {
	inventory_inspect_message = undefined;
}

var _inspect_open = !is_undefined(inventory_inspect_message);
var _list_open = !_inspect_open && tabs.active_tab == tab_list_benchmark;
if _list_open {
	if is_undefined(list_benchmark_panel) {
		list_benchmark_panel = demoBuildListBenchmark(tab_list_benchmark);
	}
	if is_undefined(list_benchmark_saved_alpha) {
		list_benchmark_saved_alpha = tabs.visual_alpha;
		tabs.visual_alpha = 1;
	}
	if keyboard_check_pressed(vk_f8) {
		list_benchmark_scroll = !list_benchmark_scroll;
	}
	if list_benchmark_scroll && list_benchmark_panel._intersects_clip_region {
		var _min_offset = list_benchmark_panel._getMinScrollOffset();
		var _offset = list_benchmark_panel.scroll_offset_y;
		if _offset <= _min_offset {
			list_benchmark_direction = 1;
		} else if _offset >= 0 {
			list_benchmark_direction = -1;
		}
		_offset = clamp(_offset + 24 * list_benchmark_direction, _min_offset, 0);
		list_benchmark_panel.scroll_offset_y = _offset;
		list_benchmark_panel.scroll_target_offset_y = _offset;
		list_benchmark_panel._requestScrollUpdate();
	}
} else if !is_undefined(list_benchmark_saved_alpha) {
	tabs.visual_alpha = list_benchmark_saved_alpha;
	list_benchmark_saved_alpha = undefined;
	list_benchmark_scroll = false;
}

if _inspect_open && keyboard_check_pressed(vk_f8) {
	inventory_inspect_message.backdrop_blur = inventory_inspect_message.backdrop_blur > 0 ? 0 : LUI_DEFAULT_ALERT_BLUR;
}

if !_inspect_open && !_list_open && keyboard_check_pressed(vk_f6) {
	render_benchmark_mode = (render_benchmark_mode + 1) mod 3;
	var _use_cache = render_benchmark_mode == 0 ? render_benchmark_original_cache : render_benchmark_mode == 2;
	render_benchmark_panel.setCacheAsSurface(_use_cache);
}

var _label = "";
if _inspect_open {
	_label = inventory_inspect_message.backdrop_blur > 0 ? "Inspect / Blur" : "Inspect / Dim";
} else if _list_open {
	_label = list_benchmark_scroll ? "1000 rows / Scroll" : "1000 rows / Idle";
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
	render_benchmark_tree_us = 0;
	render_benchmark_layout_us = 0;
	render_benchmark_cache_us = 0;
	render_benchmark_draw_us = 0;
	render_benchmark_bakes = 0;
	render_benchmark_result = "";
}

if render_benchmark_frames > 0 {
	my_ui.update(render_benchmark_metrics);
} else {
	my_ui.update();
}
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
