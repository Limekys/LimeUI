///@desc RENDER UI

// If LUI_FORCE_ALPHA_1 setted to false you should see ui flashes
if enable_alpha_test {
	draw_set_alpha(Wave(0, 1, 1.0, 0));
}

if render_benchmark_frames > 0 {
	my_ui.render(render_benchmark_metrics);
	render_benchmark_cache_us += render_benchmark_metrics.cache_us;
	render_benchmark_draw_us += render_benchmark_metrics.draw_us;
	render_benchmark_bakes += render_benchmark_metrics.bakes;
	render_benchmark_frames--;

	if render_benchmark_frames == 0 {
		var _cache_ms = render_benchmark_cache_us / 180000;
		var _draw_ms = render_benchmark_draw_us / 180000;
		render_benchmark_result = $"[{render_benchmark_label}] 180 frames | cache {string_format(_cache_ms, 1, 3)} ms | draw {string_format(_draw_ms, 1, 3)} ms | total {string_format(_cache_ms + _draw_ms, 1, 3)} ms | bakes {render_benchmark_bakes}";
		show_debug_message(render_benchmark_result);
	}
} else {
	my_ui.render();
}

if render_benchmark_label != "" {
	var _switch_hint = is_undefined(inventory_inspect_message) ? "F6: Switch cache mode" : "F8: Toggle blur";
	DrawSetText(c_yellow, fDebug, fa_left, fa_bottom, 1);
	draw_text(4, display_get_gui_height() - 46, $"{render_benchmark_label} | {_switch_hint} | F7: Record 180 frames");
	var _status = render_benchmark_frames > 0 ? $"Recording: {render_benchmark_frames} frames left" : render_benchmark_result;
	draw_text(4, display_get_gui_height() - 25, _status);
}

// Debug info in demo
DrawSetText(c_red, fDebug, fa_left, fa_bottom, 1);
draw_text(4, display_get_gui_height() - 4, 
" UI isInteracting: " + string(my_ui.isInteracting()) +
" Element count: " + string(global.lui_element_count) +
" FPS: " + string(fps) + " FPS_REAL: " + string(fps_real));
