///@desc RENDER UI
my_ui.render();

DrawSetText(c_red, fDebug, fa_left, fa_bottom, 1);
draw_text(4, display_get_gui_height() - 4, 
" UI isInteracting: " + string(my_ui.isInteracting()) +
" Element count: " + string(global.lui_element_count) +
" FPS: " + string(fps) + " FPS_REAL: " + string(fps_real));