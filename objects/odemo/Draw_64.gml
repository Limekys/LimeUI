///@desc render ui
my_ui.render();
LUI_OVERLAY.render();

DrawSetText(c_red, fDebug, fa_left, fa_bottom, 1);
draw_text(16, room_height - 16*0, "hover my_ui: " + string(my_ui.mouse_hover()));
draw_text(16, room_height - 16*1, "hover my_ui.childs: " + string(my_ui.mouse_hover_childs()));
draw_text(16, room_height - 16*2, "hover btn_show_msg.parent: " + string(btn_show_msg.mouse_hover_parent()));