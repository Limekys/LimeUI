if !surface_exists(demo_surface) {
	demo_surface = surface_create(100, 100);
	my_ui.getElement("LuiSurface").set(demo_surface);
} else {
	surface_set_target(demo_surface);
	draw_clear_alpha(c_red, 1);
	draw_circle_color(0, 0, Wave(64, 128, 1.0, 0), c_blue, c_aqua, false);
	surface_reset_target();
}