///@desc RENDER
my_ui.render();

if debug_grid {
	my_ui._draw_screen_grid();
}

DrawSetText(c_red, fDebug, fa_left, fa_bottom, 1);
draw_text(4, room_height - 4, 
" Mouse is hover on ui: " + string(my_ui.mouse_hover_childs()) +
" Element count: " + string(global.lui_element_count) +
" FPS: " + string(fps) + " FPS_REAL: " + string(fps_real));