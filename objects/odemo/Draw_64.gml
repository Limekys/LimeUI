///@desc render ui
my_ui.render();
LUI_OVERLAY.render();

DrawSetText(c_red, fDebug, fa_left, fa_bottom, 1);
draw_text(16, room_height - 16*0, "Mouse is hover on ui: " + string(my_ui.mouse_hover_childs()));