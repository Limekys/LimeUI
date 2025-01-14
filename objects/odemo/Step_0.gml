/// @desc UPDATE UI
my_ui.update();

if demo_loading_state {
	if demo_loading.get() < 100 {
		demo_loading.set(demo_loading.get() + 0.1);
	}
}

// Smooth moving for tab_group
tab_group.pos_x = lerp(tab_group.pos_x, tab_group_target_x, 0.25);
tab_group.pos_y = lerp(tab_group.pos_y, tab_group_target_y, 0.25);