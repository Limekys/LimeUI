///@desc render ui
my_ui.render();
//LUI_OVERLAY.render();

DrawSetText(c_red, fDebug, fa_left, fa_top, 1);

DrawSetText(c_red, fDebug, fa_left, fa_bottom, 1);
draw_text(4, room_height - 4, 
" Mouse is hover on ui: " + string(my_ui.mouse_hover_childs()) +
" Element count: " + string(my_ui._lui_elements_count) +
" FPS: " + string(fps) + " FPS_REAL: " + string(fps_real));