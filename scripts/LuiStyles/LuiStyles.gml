///@func LuiStyle(_style)
///@desc Style for UI
function LuiStyle(_style) constructor {
	//Fonts
	font_default = _style[$ "font_default"] ?? undefined;
	font_buttons = _style[$ "font_buttons"] ?? undefined;
	font_sliders = _style[$ "font_sliders"] ?? undefined;
	font_debug = _style[$ "font_debug"] ?? undefined;
	//Colors
	color_font = _style[$ "color_font"] ?? c_black;
	color_font_hint = _style[$ "color_font_hint"] ?? c_gray;
	color_main = _style[$ "color_main"] ?? c_white;
	color_border = _style[$ "color_border"] ?? c_gray;
	color_checkbox_pin = _style[$ "color_checkbox_pin"] ?? #45C952;
	color_slider = _style[$ "color_slider"] ?? #45C952;
	color_textbox_border = _style[$ "color_textbox_border"] ?? c_dkgray;
	//Sprites
	sprite_panel = _style[$ "sprite_panel"] ?? undefined;
	sprite_panel_border = _style[$ "sprite_panel_border"] ?? undefined;
	sprite_button = _style[$ "sprite_button"] ?? undefined;
	sprite_button_border = _style[$ "sprite_button_border"] ?? undefined;
	sprite_slider_knob = _style[$ "sprite_slider_knob"] ?? undefined;
	sprite_slider_knob_border = _style[$ "sprite_slider_knob_border"] ?? undefined;
	//Sounds
	sound_click = _style[$ "sound_click"] ?? undefined;
	//Settings
	padding = _style[$ "padding"] ?? 16;
	scroll_step = _style[$ "scroll_step"] ?? 32;
	textbox_cursor = _style[$ "textbox_cursor"] ?? "|";
	textbox_password = _style[$ "textbox_password"] ?? "•";
}