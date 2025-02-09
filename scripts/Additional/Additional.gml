function checkAndRescaleWindow(_ui) {
	// Check window for rescale
	if !variable_instance_exists(self, "window_w") variable_instance_set(self, "window_w", -1);
	if !variable_instance_exists(self, "window_h") variable_instance_set(self, "window_h", -1);
	if window_w != window_get_width() || window_h != window_get_height() {
		window_w = window_get_width();
		window_h = window_get_height();
		camera_set_view_size(view_camera[0], window_get_width(), window_get_height())
		display_set_gui_size(window_get_width(), window_get_height());
		_ui.setSize(display_get_gui_width(), display_get_gui_height());
	}
}