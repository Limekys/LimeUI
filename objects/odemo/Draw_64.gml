///@desc RENDER UI
my_ui.render();

if debug_grid {
	my_ui._drawScreenGrid();
}

DrawSetText(c_red, fDebug, fa_left, fa_bottom, 1);
draw_text(4, room_height - 4, 
" UI isInteracting: " + string(my_ui.isInteracting()) +
" Element count: " + string(global.lui_element_count) +
" FPS: " + string(fps) + " FPS_REAL: " + string(fps_real));