/// @desc UPDATE UI
my_ui.update();

if demo_loading_state {
	if demo_loading.get() < 100 {
		demo_loading.set(demo_loading.get() + 0.1);
	}
}