///@func LuiStyle(style)
///@desc Style for UI
function LuiStyle(style) constructor {
	//Fonts
	font_default = style[$ "font_default"] ?? undefined;
	font_buttons = style[$ "font_buttons"] ?? undefined;
	font_sliders = style[$ "font_sliders"] ?? undefined;
	//Colors
	color_font = style[$ "color_font"] ?? c_black;
	color_font_hint = style[$ "color_font_hint"] ?? c_gray;
	color_main = style[$ "color_main"] ?? c_white;
	color_border = style[$ "color_border"] ?? c_gray;
	color_button = style[$ "color_button"] ?? c_white;
	color_button_border = style[$ "color_button_border"] ?? c_gray;
	color_checkbox_pin = style[$ "color_checkbox_pin"] ?? #45C952;
	color_slider = style[$ "color_slider"] ?? #45C952;
	color_textbox_border = style[$ "color_textbox_border"] ?? c_dkgray;
	//Sprites
	sprite_panel = style[$ "sprite_panel"] ?? undefined;
	sprite_panel_border = style[$ "sprite_panel_border"] ?? undefined;
	sprite_button = style[$ "sprite_button"] ?? undefined;
	sprite_button_border = style[$ "sprite_button_border"] ?? undefined;
	sprite_slider_knob = style[$ "sprite_slider_knob"] ?? undefined;
	sprite_slider_knob_border = style[$ "sprite_slider_knob_border"] ?? undefined;
	//Sounds
	sound_click = style[$ "sound_click"] ?? undefined;
	//Settings
	padding = style[$ "padding"] ?? 16;
	scroll_step = style[$ "scroll_step"] ?? 32;
	textbox_cursor = style[$ "textbox_cursor"] ?? "|";
	textbox_password = style[$ "textbox_password"] ?? "•";
}