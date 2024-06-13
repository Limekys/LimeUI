/// @desc Change style to light
my_ui.setStyle(global.demo_style_light);
var _b = layer_background_get_id("Backgrounds_1");
layer_background_blend(_b, c_white);
var _b = layer_background_get_id("Background");
layer_background_blend(_b, c_ltgray);

//Set colors to buttons 
btn_show_msg.setColor(merge_color(#ffff77, c_black, 0.1));
btn_restart.setColor(merge_color(#ff7777, c_black, 0.1));