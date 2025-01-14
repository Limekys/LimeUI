enum LUI_ANIM {
	none,
}

///@desc Style for UI
///@arg {Struct} _style
function LuiStyle(_style) constructor {
	//Fonts
	font_default = _style[$ "font_default"] ?? undefined;
	font_buttons = _style[$ "font_buttons"] ?? undefined;
	font_sliders = _style[$ "font_sliders"] ?? undefined;
	font_debug = _style[$ "font_debug"] ?? undefined;
	//Sprites
	sprite_panel = _style[$ "sprite_panel"] ?? undefined;
	sprite_panel_border = _style[$ "sprite_panel_border"] ?? undefined;
	sprite_textbox = _style[$ "sprite_textbox"] ?? undefined;
	sprite_textbox_border = _style[$ "sprite_textbox_border"] ?? undefined;
	sprite_button = _style[$ "sprite_button"] ?? undefined;
	sprite_button_border = _style[$ "sprite_button_border"] ?? undefined;
	sprite_checkbox = _style[$ "sprite_checkbox"] ?? undefined;
	sprite_checkbox_pin = _style[$ "sprite_checkbox_pin"] ?? undefined;
	sprite_checkbox_border = _style[$ "sprite_checkbox_border"] ?? undefined;
	sprite_progress_bar = _style[$ "sprite_progress_bar"] ?? undefined;
	sprite_progress_bar_value = _style[$ "sprite_progress_bar_value"] ?? undefined;
	sprite_progress_bar_border = _style[$ "sprite_progress_bar_border"] ?? undefined;
	sprite_slider_knob = _style[$ "sprite_slider_knob"] ?? undefined;
	sprite_slider_knob_border = _style[$ "sprite_slider_knob_border"] ?? undefined;
	sprite_scroll_slider = _style[$ "sprite_scroll_slider"] ?? undefined;
	sprite_scroll_slider_back = _style[$ "sprite_scroll_slider_back"] ?? undefined;
	sprite_dropdown = _style[$ "sprite_dropdown"] ?? undefined;
	sprite_dropdown_border = _style[$ "sprite_dropdown_border"] ?? undefined;
	sprite_dropdown_item = _style[$ "sprite_dropdown_item"] ?? undefined;
	sprite_dropdown_item_border = _style[$ "sprite_dropdown_item_border"] ?? undefined;
	sprite_dropdown_arrow = _style[$ "sprite_dropdown_arrow"] ?? undefined;
	sprite_tab = _style[$ "sprite_tab"] ?? undefined;
	sprite_tab_border = _style[$ "sprite_tab_border"] ?? undefined;
	sprite_tabgroup = _style[$ "sprite_tabgroup"] ?? undefined;
	sprite_tabgroup_border = _style[$ "sprite_tabgroup_border"] ?? undefined;
	sprite_tooltip = _style[$ "sprite_tooltip"] ?? undefined;
	sprite_tooltip_border = _style[$ "sprite_tooltip_border"] ?? undefined;
	//Colors
	color_font = _style[$ "color_font"] ?? c_black;
	color_font_hint = _style[$ "color_font_hint"] ?? c_gray;
	color_main = _style[$ "color_main"] ?? c_white;
	color_border = _style[$ "color_border"] ?? c_gray;
	color_button = _style[$ "color_button"] ?? c_white;
	color_button_border = _style[$ "color_button_border"] ?? c_gray;
	color_hover = _style[$ "color_hover"] ?? c_gray; //mixes the color of the main color of this element by 50%
	color_checkbox = _style[$ "color_checkbox"] ?? c_white;
	color_checkbox_pin = _style[$ "color_checkbox_pin"] ?? #45C952;
	color_checkbox_border = _style[$ "color_checkbox_border"] ?? c_gray;
	color_progress_bar = _style[$ "color_progress_bar"] ?? c_white;
	color_progress_bar_value = _style[$ "color_progress_bar_value"] ?? #45C952;
	color_progress_bar_border = _style[$ "color_progress_bar_border"] ?? c_gray;
	color_textbox = _style[$ "color_textbox"] ?? c_white;
	color_textbox_border = _style[$ "color_textbox_border"] ?? c_dkgray;
	color_scroll_slider = _style[$ "color_scroll_slider"] ?? c_white;
	color_scroll_slider_back = _style[$ "color_scroll_slider_back"] ?? c_gray;
	color_dropdown = _style[$ "color_dropdown"] ?? c_white;
	color_dropdown_border = _style[$ "color_dropdown_border"] ?? c_gray;
	color_dropdown_arrow = _style[$ "color_dropdown_arrow"] ?? c_gray;
	color_tooltip = _style[$ "color_tooltip"] ?? c_black;
	color_tooltip_border = _style[$ "color_tooltip_border"] ?? c_black;
	//Sounds
	sound_click = _style[$ "sound_click"] ?? undefined;
	//Settings
	default_min_width = _style[$ "default_min_width"] ?? 32;
	default_min_height = _style[$ "default_min_height"] ?? 32;
	padding = _style[$ "padding"] ?? 16;
	checkbox_pin_margin = _style[$ "checkbox_pin_margin"] ?? 6;
	scroll_step = _style[$ "scroll_step"] ?? 32;
	scroll_surface_offset = _style[$ "scroll_surface_offset"] ?? [0,0,0,0];
	textbox_cursor = _style[$ "textbox_cursor"] ?? "|";
	textbox_password = _style[$ "textbox_password"] ?? "•";
	//Render functions
	sprite_render_function = _style[$ "sprite_render_function"] ?? undefined; //function(_sprite, _subimg, _x, _y, _width, _height, _color, _alpha)
	//Animations (WIP)
	anim_on_create = _style[$ "anim_on_create"] ?? LUI_ANIM.none;
	anim_on_destroy = _style[$ "anim_on_destroy"] ?? LUI_ANIM.none;
	anim_on_mouse_enter = _style[$ "anim_on_mouse_enter"] ?? LUI_ANIM.none;
	anim_on_mouse_leave = _style[$ "anim_on_mouse_leave"] ?? LUI_ANIM.none;
}