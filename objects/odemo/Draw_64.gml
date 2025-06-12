///@desc RENDER UI

// If LUI_FORCE_ALPHA_1 setted to false you should see ui flashes
if enable_alpha_test {
	draw_set_alpha(Wave(0, 1, 1.0, 0));
}

// UI render
my_ui.render();

// Debug info in demo
DrawSetText(c_red, fDebug, fa_left, fa_bottom, 1);
draw_text(4, display_get_gui_height() - 4, 
" UI isInteracting: " + string(my_ui.isInteracting()) +
" Element count: " + string(global.lui_element_count) +
" FPS: " + string(fps) + " FPS_REAL: " + string(fps_real));