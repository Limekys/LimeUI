enum LUI_ANIM {
	none,
}

///@desc Style for UI
///@arg {Struct} _style
function LuiStyle(_style = {}) constructor {
	//Fonts
	font_default = _style[$ "font_default"] ?? undefined;
	font_buttons = _style[$ "font_buttons"] ?? undefined;
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
	sprite_progress_ring = _style[$ "sprite_progress_ring"] ?? undefined;
	sprite_progress_ring_value = _style[$ "sprite_progress_ring_value"] ?? undefined;
	sprite_progress_ring_border = _style[$ "sprite_progress_ring_border"] ?? undefined;
	sprite_slider_knob = _style[$ "sprite_slider_knob"] ?? undefined;
	sprite_slider_knob_border = _style[$ "sprite_slider_knob_border"] ?? undefined;
	sprite_scroll_pin = _style[$ "sprite_scroll_pin"] ?? undefined;
	sprite_scroll_pin_border = _style[$ "sprite_scroll_pin_border"] ?? undefined;
	sprite_scroll_slider = _style[$ "sprite_scroll_slider"] ?? undefined;
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
	color_value = _style[$ "color_value"] ?? #45C952;
	color_hover = _style[$ "color_hover"] ?? c_gray; //mixes the color of the main color of this element by 50%
	color_checkbox = _style[$ "color_checkbox"] ?? c_white;
	color_checkbox_pin = _style[$ "color_checkbox_pin"] ?? #45C952;
	color_checkbox_border = _style[$ "color_checkbox_border"] ?? c_gray;
	color_progress_bar = _style[$ "color_progress_bar"] ?? c_white;
	color_progress_bar_value = _style[$ "color_progress_bar_value"] ?? #45C952;
	color_progress_bar_border = _style[$ "color_progress_bar_border"] ?? c_gray;
	color_progress_ring = _style[$ "color_progress_ring"] ?? c_white;
	color_progress_ring_value = _style[$ "color_progress_ring_value"] ?? #45C952;
	color_progress_ring_border = _style[$ "color_progress_ring_border"] ?? c_gray;
	color_textbox = _style[$ "color_textbox"] ?? c_white;
	color_textbox_border = _style[$ "color_textbox_border"] ?? c_dkgray;
	color_scroll_pin = _style[$ "color_scroll_pin"] ?? c_white;
	color_scroll_pin_border = _style[$ "color_scroll_pin_border"] ?? c_dkgray;
	color_scroll_slider_back = _style[$ "color_scroll_slider_back"] ?? c_gray;
	color_dropdown = _style[$ "color_dropdown"] ?? c_white;
	color_dropdown_border = _style[$ "color_dropdown_border"] ?? c_gray;
	color_dropdown_item = _style[$ "color_dropdown_item"] ?? c_white;
	color_dropdown_item_border = _style[$ "color_dropdown_item_border"] ?? c_gray;
	color_dropdown_arrow = _style[$ "color_dropdown_arrow"] ?? c_gray;
	color_tooltip = _style[$ "color_tooltip"] ?? c_black;
	color_tooltip_border = _style[$ "color_tooltip_border"] ?? c_black;
	//Sounds
	sound_click = _style[$ "sound_click"] ?? undefined;
	//Settings
	default_min_width = _style[$ "default_min_width"] ?? 32;
	default_min_height = _style[$ "default_min_height"] ?? 32;
	padding = _style[$ "padding"] ?? 16;
	checkbox_pin_margin = _style[$ "checkbox_pin_margin"] ?? 0;
	scroll_step = _style[$ "scroll_step"] ?? 32;
	render_region_offset = _style[$ "render_region_offset"] ?? {left : 0, right : 0, top : 0, bottom : 0};
	textbox_cursor = _style[$ "textbox_cursor"] ?? "|";
	textbox_password = _style[$ "textbox_password"] ?? "•";
	//Render functions
	sprite_render_function = _style[$ "sprite_render_function"] ?? undefined; //function(_sprite, _subimg, _x, _y, _width, _height, _color, _alpha)
	//Animations (WIP)
	anim_on_create = _style[$ "anim_on_create"] ?? LUI_ANIM.none;
	anim_on_destroy = _style[$ "anim_on_destroy"] ?? LUI_ANIM.none;
	anim_on_mouse_enter = _style[$ "anim_on_mouse_enter"] ?? LUI_ANIM.none;
	anim_on_mouse_leave = _style[$ "anim_on_mouse_leave"] ?? LUI_ANIM.none;
	
	// Functions
	setFonts = function(_default = undefined, _buttons = undefined, _debug = undefined) {
		// Fonts
		font_default = _default;
		font_buttons = _buttons;
		font_debug = _debug;
		
		return self;
	}
	
	setSprites = function(_panel = undefined, _panel_border = undefined, _element = undefined, _element_border = undefined, _checkbox_pin = undefined, _dropdown_arrow = undefined, _ring = undefined, _ring_border = undefined) {
		// Panel
		sprite_panel = _panel;
		sprite_panel_border = _panel_border;
		sprite_tab = _panel;
		sprite_tab_border = _panel_border;
		sprite_tabgroup = _panel;
		sprite_tabgroup_border = _panel_border;
		sprite_scroll_pin = _panel;
		sprite_scroll_pin_border = _panel_border;
		// Element
		sprite_textbox = _element;
		sprite_button = _element;
		sprite_checkbox = _element;
		sprite_progress_bar = _element;
		sprite_progress_bar_value = _element;
		sprite_slider_knob = _element;
		sprite_scroll_slider = _element;
		sprite_dropdown = _element;
		sprite_dropdown_item = _element;
		sprite_tooltip = _element;
		// Border
		sprite_textbox_border = _element_border;
		sprite_button_border = _element_border;
		sprite_checkbox_border = _element_border;
		sprite_progress_bar_border = _element_border;
		sprite_slider_knob_border = _element_border;
		sprite_dropdown_border = _element_border;
		sprite_dropdown_item_border = _element_border;
		sprite_tooltip_border = _element_border;
		// Other
		sprite_checkbox_pin = _checkbox_pin;
		sprite_dropdown_arrow = _dropdown_arrow;
		sprite_progress_ring = _ring;
		sprite_progress_ring_value = _ring;
		sprite_progress_ring_border = _ring_border;
		
		return self;
	}
	
	setColors = function(_panel = c_white, _panel_border = c_gray, _element = c_white, _element_border = c_gray, _value = #45C952, _font = c_black, _font_hint = c_gray, _hover = c_gray) {
		// Panel
		color_main = _panel;
		color_border = _panel_border;
		// Element
		color_button = _element;
		color_checkbox = _element;
		color_progress_bar = _element;
		color_textbox = _element;
		color_scroll_pin = _element;
		color_dropdown = _element;
		color_dropdown_item = _element;
		color_tooltip = _element;
		// Border
		color_button_border = _element_border;
		color_checkbox_border = _element_border;
		color_progress_bar_border = _element_border;
		color_progress_ring = _element_border;
		color_progress_ring_border = _element_border;
		color_textbox_border = _element_border;
		color_scroll_pin_border = _element_border;
		color_scroll_slider_back = _element_border;
		color_dropdown_border = _element_border;
		color_dropdown_item_border = _element_border;
		color_dropdown_arrow = _element_border;
		color_tooltip_border = _element_border;
		// Value
		color_value = _value;
		color_checkbox_pin = _value;
		color_progress_bar_value = _value;
		color_progress_ring_value = _value;
		// Fonts
		color_font = _font;
		color_font_hint = _font_hint;
		// Other
		color_hover = _hover;
		
		return self;
	}
	
	setSounds = function(_click = undefined) {
		// Sounds
		sound_click = _click;
		
		return self;
	}
	
	setSettings = function(_min_width = 32, _min_height = 32, _padding = 16, _checkbox_pin_margin = 0, _scroll_step = 32, _render_region_offset = {left : 0, right : 0, top : 0, bottom : 0}, _symbol_cursor = "|", _symbol_password = "•") {
		// Settings
		default_min_width = _min_width;
		default_min_height = _min_height;
		padding = _padding;
		checkbox_pin_margin = _checkbox_pin_margin;
		scroll_step = _scroll_step;
		render_region_offset = _render_region_offset;
		textbox_cursor = _symbol_cursor;
		textbox_password = _symbol_password;
		
		return self;
	}
	
	setSpriteTabGroup = function(_tabgroup = undefined, _tabgroup_border = undefined, _tab = undefined, _tab_border = undefined) {
		sprite_tabgroup = _tabgroup;
		sprite_tabgroup_border = _tabgroup_border;
		sprite_tab = _tab;
		sprite_tab_border = _tab_border;
		
		return self;
	}
}
