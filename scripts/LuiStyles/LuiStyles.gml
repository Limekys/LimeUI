///@func LuiStyle(_style)
///@desc Style for UI
///@arg {Struct} _style
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
	color_button = _style[$ "color_button"] ?? c_white;
	color_button_border = _style[$ "color_button_border"] ?? c_gray;
	color_hover = _style[$ "color_hover"] ?? c_gray;	//mixes the color of the main color of this element by 50%
	color_checkbox_pin = _style[$ "color_checkbox_pin"] ?? #45C952;
	color_slider = _style[$ "color_slider"] ?? #45C952;
	color_textbox_border = _style[$ "color_textbox_border"] ?? c_dkgray;
	color_scroll_slider = _style[$ "color_scroll_slider"] ?? c_white;
	color_scroll_slider_back = _style[$ "color_scroll_slider_back"] ?? c_gray;
	//Sprites
	sprite_panel = _style[$ "sprite_panel"] ?? undefined;
	sprite_panel_border = _style[$ "sprite_panel_border"] ?? undefined;
	sprite_textbox = _style[$ "sprite_textbox"] ?? undefined;
	sprite_textbox_border = _style[$ "sprite_textbox_border"] ?? undefined;
	sprite_button = _style[$ "sprite_button"] ?? undefined;
	sprite_button_border = _style[$ "sprite_button_border"] ?? undefined;
	sprite_slider_knob = _style[$ "sprite_slider_knob"] ?? undefined;
	sprite_slider_knob_border = _style[$ "sprite_slider_knob_border"] ?? undefined;
	sprite_scroll_slider = _style[$ "sprite_scroll_slider"] ?? undefined;
	sprite_scroll_slider_back = _style[$ "sprite_scroll_slider_back"] ?? undefined;
	//Sounds
	sound_click = _style[$ "sound_click"] ?? undefined;
	//Settings
	padding = _style[$ "padding"] ?? 16;
	scroll_step = _style[$ "scroll_step"] ?? 32;
	textbox_cursor = _style[$ "textbox_cursor"] ?? "|";
	textbox_password = _style[$ "textbox_password"] ?? "•";
	//Animations
	
}