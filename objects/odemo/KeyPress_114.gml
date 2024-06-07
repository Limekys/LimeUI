/// @desc change style to dark
my_ui.set_style(global.demo_style_dark);
var _b = layer_background_get_id("Backgrounds_1");
layer_background_blend(_b, #333333);
var _b = layer_background_get_id("Background");
layer_background_blend(_b, #191919);

//Set colors to buttons 
btn_show_msg.set_color(merge_color(#ffff77, c_black, 0.5));
btn_restart.set_color(merge_color(#ff7777, c_black, 0.5));