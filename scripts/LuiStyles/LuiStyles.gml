enum LUI_ANIM {
	none,
}

///@desc Style for UI
///@arg {Struct} [_style]
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
	color_primary = _style[$ "color_primary"] ?? c_white;
	color_secondary = _style[$ "color_secondary"] ?? c_ltgray;
    color_accent = _style[$ "color_accent"] ?? #45C952;
    color_border = _style[$ "color_border"] ?? c_gray;
    color_deactivated = _style[$ "color_deactivated"] ?? c_gray;
    color_text = _style[$ "color_text"] ?? c_black;
	color_text_hint = _style[$ "color_text_hint"] ?? c_gray;
    color_hover = _style[$ "color_hover"] ?? c_gray;
    color_semantic_success = _style[$ "color_semantic_success"] ?? #4CAF50;
    color_semantic_error = _style[$ "color_semantic_error"] ?? #F44336;
    color_semantic_warning = _style[$ "color_semantic_warning"] ?? #FF9800;
    color_shadow = _style[$ "color_shadow"] ?? c_black;
	//Sounds
	sound_click = _style[$ "sound_click"] ?? undefined;
	//Settings
	min_width = _style[$ "min_width"] ?? 32;
	min_height = _style[$ "min_height"] ?? 32;
	padding = _style[$ "padding"] ?? 0;
	scroll_step = _style[$ "scroll_step"] ?? 32;
	scroll_slider_width = _style[$ "scroll_slider_width"] ?? 16;
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
	
	// FONTS FUNCTIONS
	
	static setFonts = function(_default = undefined, _buttons = undefined, _debug = undefined) {
		// Fonts
		font_default = _default;
		font_buttons = _buttons;
		font_debug = _debug;
		
		return self;
	}
	
	// SPRITES FUNCTIONS
	
	///@func setSprites
	static setSprites = function(_panel = undefined, _element = undefined, _panel_border = undefined, _element_border = undefined) {
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
		sprite_checkbox_pin = _element;
		sprite_progress_bar = _element;
		sprite_progress_bar_value = _element;
		sprite_slider_knob = _element;
		sprite_scroll_slider = _element;
		sprite_dropdown = _element;
		sprite_dropdown_item = _element;
		sprite_tooltip = _element;
		sprite_progress_ring = _element;
		sprite_progress_ring_value = _element;
		sprite_dropdown_arrow = _element;
		// Border
		sprite_textbox_border = _element_border;
		sprite_button_border = _element_border;
		sprite_checkbox_border = _element_border;
		sprite_progress_bar_border = _element_border;
		sprite_slider_knob_border = _element_border;
		sprite_dropdown_border = _element_border;
		sprite_dropdown_item_border = _element_border;
		sprite_tooltip_border = _element_border;
		sprite_progress_ring_border = _element_border;
		
		return self;
	}
	
	static setSpriteCheckbox = function(_checkbox = undefined, _checkbox_pin = undefined, _checkbox_border = undefined) {
		sprite_checkbox = _checkbox;
		sprite_checkbox_border = _checkbox_border;
		sprite_checkbox_pin = _checkbox_pin;
		
		return self;
	}
	
	static setSpriteProgressBar = function(_progressbar = undefined, _progressbar_value = undefined, _progressbar_border = undefined) {
		sprite_progress_bar = _progressbar;
		sprite_progress_bar_value = _progressbar_value;
		sprite_progress_bar_border = _progressbar_border;
		
		return self;
	}
	
	static setSpriteSliderKnob = function(_slider_knob = undefined, _slider_knob_border = undefined) {
		sprite_slider_knob = _slider_knob;
		sprite_slider_knob_border = _slider_knob_border;
		
		return self;
	}
	
	static setSpriteTabGroup = function(_tabgroup = undefined, _tab = undefined, _tabgroup_border = undefined, _tab_border = undefined) {
		sprite_tabgroup = _tabgroup;
		sprite_tabgroup_border = _tabgroup_border;
		sprite_tab = _tab;
		sprite_tab_border = _tab_border;
		
		return self;
	}
	
	static setSpriteDropdownArrow = function(_dropdown_arrow = undefined) {
		sprite_dropdown_arrow = _dropdown_arrow;
		
		return self;
	}
	
	static setSpriteRing = function(_ring = undefined, _ring_value = undefined, _ring_border = undefined) {
		sprite_progress_ring = _ring;
		sprite_progress_ring_value = _ring_value;
		sprite_progress_ring_border = _ring_border;
		
		return self;
	}
	
	static setSpriteScrollSlider = function(_scroll_slider = undefined, _scroll_pin = undefined, _scroll_pin_border = undefined) {
		sprite_scroll_slider = _scroll_slider;
		sprite_scroll_pin = _scroll_pin;
		sprite_scroll_pin_border = _scroll_pin_border;
		
		return self;
	}
	
	static setSpriteTooltip = function(_tooltip = undefined, _tooltip_border = undefined) {
		sprite_tooltip = _tooltip;
		sprite_tooltip_border = _tooltip_border;
		
		return self;
	}
	
	// COLORS FUNCTIONS
	
	///@desc Sets the primary, secondary, accent, and border colors for UI elements.
    ///@arg {Real} [_primary] The primary color for elements (default: c_white).
    ///@arg {Real} [_secondary] The secondary color for interactive elements (default: c_ltgray).
    ///@arg {Real} [_accent] The accent color for active states (default: c_green).
    ///@arg {Real} [_border] The border color for elements (default: c_gray).
    static setColors = function(_primary = c_white, _secondary = c_ltgray, _accent = c_green, _border = c_gray) {
        // Panel
        color_primary = _primary;
        color_secondary = _secondary;
        color_accent = _accent;
        color_border = _border;
        
        return self;
    }
    
    ///@desc [DEPRECATED] Sets the accent color (use setColorAccent instead).
    ///@arg {Real} [_color] The accent color for active states (default: c_green).
    ///@deprecated
    static setColorValue = function(_color = c_green) {
        color_accent = _color;
        print("function setColorValue is deprecated");
        
        return self;
    }
    
    ///@desc Sets the accent color for interactive elements.
    ///@arg {Real} [_color] The accent color for active states (default: c_green).
    static setColorAccent = function(_color = c_green) {
        color_accent = _color;
        
        return self;
    }
    
    ///@desc Sets the hover color for UI elements.
    ///@arg {Real} [_hover] The hover color to be mixed with element colors (default: c_gray).
    static setColorHover = function(_hover = c_gray) {
        color_hover = _hover;
        
        return self;
    }
    
    ///@desc [DEPRECATED] Sets the text and text hint colors (use setColorText instead).
    ///@arg {Real} [_font] The color for text (default: c_black).
    ///@arg {Real} [_font_hint] The color for text hints (default: c_gray).
    ///@deprecated
    static setColorFont = function(_font = c_black, _font_hint = c_gray) {
        color_text = _font;
        color_text_hint = _font_hint;
        print("function setColorFont is deprecated");
        
        return self;
    }
    
    ///@desc Sets the text and text hint colors for UI elements.
    ///@arg {Real} [_font] The color for text (default: c_black).
    ///@arg {Real} [_font_hint] The color for text hints (default: c_gray).
    static setColorText = function(_font = c_black, _font_hint = c_gray) {
        color_text = _font;
        color_text_hint = _font_hint;
        
        return self;
    }
    
    ///@desc [DEPRECATED] Previously set the tooltip colors (no longer used).
    ///@arg {Real} [_tooltip] The tooltip background color (default: c_white).
    ///@arg {Real} [_tooltip_border] The tooltip border color (default: c_black).
    ///@deprecated
    static setColorTooltip = function(_tooltip = c_white, _tooltip_border = c_black) {
        print("function setColorTooltip is deprecated");
        
        return self;
    }
    
    ///@desc Sets the color for deactivated elements, which can be mixed with active colors.
    ///@arg {Real} [_color] The base color for deactivated elements (default: c_gray).
    static setColorDeactivated = function(_color = c_gray) {
        color_deactivated = _color;
        return self;
    }
    
    ///@desc Sets the semantic colors for success, error, and warning states.
    ///@arg {Real} [_success] The color for success (default: #4CAF50).
    ///@arg {Real} [_error] The color for error (default: #F44336).
    ///@arg {Real} [_warning] The color for warning (default: #FF9800).
    static setColorSemantic = function(_success = #4CAF50, _error = #F44336, _warning = #FF9800) {
        color_semantic_success = _success;
        color_semantic_error = _error;
        color_semantic_warning = _warning;
        return self;
    }
    
    ///@desc Sets the optional shadow color for UI elements (default: undefined).
    ///@arg {Real} [_color] The shadow color (default: undefined).
    static setColorShadow = function(_color = undefined) {
        color_shadow = _color;
        return self;
    }
	
	// SOUNDS FUNCTIONS
	
	static setSounds = function(_click = undefined) {
		// Sounds
		sound_click = _click;
		
		return self;
	}
	
	// SETTINGS FUNCTIONS
	
	static setMinSize = function(_min_width = 32, _min_height = 32) {
		min_width = _min_width;
		min_height = _min_height;
		
		return self;
	}
	
	static setPadding = function(_padding = 16) {
		padding = _padding;
		
		return self;
	}
	
	static setScrollStep = function(_scroll_step = 32) {
		scroll_step = _scroll_step;
		
		return self;
	}
	
	static setScrollSliderWidth = function(_width = 16) {
		scroll_slider_width = _width;
		
		return self;
	}
	
	static setRenderRegionOffset = function(_region = {left : 0, right : 0, top : 0, bottom : 0}) {
		if is_struct(_region) {
			render_region_offset = _region;
		} else if is_array(_region) {
			if array_length(_region) != 4 {
				array_resize(_region, 4);
			}
			render_region_offset = {
				left : _region[0],
				right : _region[1],
				top : _region[2],
				bottom : _region[3]
			}
		} else if LUI_LOG_ERROR_MODE == 2 print($"LIME_UI.WARNING: setRenderRegionOffset: Wrong type appear, when struct or array is expected!");
		
		return self;
	}
	
	static setSymbolCursor = function(_symbol_cursor = "|") {
		textbox_cursor = _symbol_cursor;
		
		return self;
	}
	
	static setSymbolPassword = function(_symbol_password = "•") {
		textbox_password = _symbol_password;
		
		return self;
	}
}
