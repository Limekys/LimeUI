/// @desc update ui
my_ui.update();
LUI_OVERLAY.update();

if demo_loading_state demo_loading.value += demo_loading.value < 100 ? 0.1 : 0;

//my_panel.pos_x += 0.1