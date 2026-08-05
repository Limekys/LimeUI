enum LUI_ANIM {
	none,
}

///@desc Single source of truth for all default style values.
/// To add a new style property, just add it here — the LuiStyle constructor picks it up automatically.
///@return {Struct} Fresh struct with default values
function LuiStyleDefaults() {
	return {
		// Fonts
		font_default: undefined,
		font_buttons: undefined,
		font_debug: undefined,
		// Sprites
		sprite_panel: undefined,
		sprite_panel_border: undefined,
		sprite_input: undefined,
		sprite_input_border: undefined,
		sprite_button: undefined,
		sprite_button_border: undefined,
		sprite_checkbox: undefined,
		sprite_checkbox_pin: undefined,
		sprite_checkbox_border: undefined,
		sprite_progress_bar: undefined,
		sprite_progress_bar_value: undefined,
		sprite_progress_bar_border: undefined,
		sprite_progress_ring: undefined,
		sprite_progress_ring_value: undefined,
		sprite_progress_ring_border: undefined,
		sprite_slider_knob: undefined,
		sprite_slider_knob_border: undefined,
		sprite_scroll_pin: undefined,
		sprite_scroll_pin_border: undefined,
		sprite_scroll_slider: undefined,
		sprite_combobox: undefined,
		sprite_combobox_border: undefined,
		sprite_combobox_item: undefined,
		sprite_combobox_item_border: undefined,
		sprite_combobox_arrow: undefined,
		sprite_tab: undefined,
		sprite_tab_border: undefined,
		sprite_tabs: undefined,
		sprite_tabs_border: undefined,
		sprite_tooltip: undefined,
		sprite_tooltip_border: undefined,
		sprite_toggleswitch: undefined,
		sprite_toggleswitch_slider: undefined,
		sprite_toggleswitch_border: undefined,
		sprite_toggleswitch_slider_border: undefined,
		// Colors
		color_primary: c_white,
		color_secondary: c_white,
		color_accent: #45C952,
		color_border: c_gray,
		color_back: c_ltgray,
		color_deactivated: c_gray,
		color_text: c_black,
		color_text_hint: c_gray,
		color_hover: c_gray,
		color_semantic_success: #4CAF50,
		color_semantic_warning: #FF9800,
		color_semantic_error: #F44336,
		color_shadow: c_black,
		// Sounds
		sound_click: undefined,
		// Settings
		min_width: 1,
		min_height: 1,
		margin: 0,
		padding: 0,
		gap: 0,
		border: 0,
		scroll_step: 32,
		scroll_slider_width: 16,
		render_region_offset: { left: 0, right: 0, top: 0, bottom: 0 },
		input_cursor: "|",
		input_password: "•",
		// Render functions
		sprite_render_function: draw_sprite_stretched_ext,
		// Animations (WIP)
		anim_on_create: LUI_ANIM.none,
		anim_on_destroy: LUI_ANIM.none,
		anim_on_mouse_enter: LUI_ANIM.none,
		anim_on_mouse_leave: LUI_ANIM.none
	};
}

///@desc Style for UI. Built by merging default values with the provided ones,
/// so new keys can be added without changing this constructor.
/// Undefined values are ignored (the default is used instead).
///@arg {Struct} [_style] Style data
function LuiStyle(_style = {}) constructor {
	if (!is_struct(_style)) _style = {};
	// Merge: defaults <- user values (undefined values are skipped)
	var _merged = _luiMergeOverrides(LuiStyleDefaults(), _style);
	// Copy the merged result onto self
	var _names = variable_struct_get_names(_merged);
	for (var i = 0; i < array_length(_names); i++) {
		var _key = _names[i];
		variable_struct_set(self, _key, _merged[$ _key]);
	}
	// Nested structs must be independent copies, not shared references
	self._class_overrides = struct_copy(_style[$ "_class_overrides"] ?? {});
	self.render_region_offset = struct_copy(self.render_region_offset);
	
	// Specific styles
	
	/// @desc Set padding for specific class elements
	/// @param {real} value padding value
	/// @param {array} class_names Array of class names ["LuiPanel", "LuiContainer"]
	static setPaddingFor = function(value, class_names) {
	    for (var i = 0; i < array_length(class_names); i++) {
	        var cls = class_names[i];
	        if (!variable_struct_exists(self._class_overrides, cls)) {
	            self._class_overrides[$ cls] = {};
	        }
	        self._class_overrides[$ cls][$ "padding"] = value;
	    }
		return self;
	}
	
	/// Аналогично для border
	static setBorderFor = function(value, class_names) {
	    for (var i = 0; i < array_length(class_names); i++) {
	        var cls = class_names[i];
	        if (!variable_struct_exists(self._class_overrides, cls)) {
	            self._class_overrides[$ cls] = {};
	        }
	        self._class_overrides[$ cls][$ "border"] = value;
	    }
		return self;
	}
	
	/// Аналогично для margin (если нужно)
	static setMarginFor = function(value, class_names) {
	    for (var i = 0; i < array_length(class_names); i++) {
	        var cls = class_names[i];
	        if (!variable_struct_exists(self._class_overrides, cls)) {
	            self._class_overrides[$ cls] = {};
	        }
	        self._class_overrides[$ cls][$ "margin"] = value;
	    }
		return self;
	}
	
	/// Аналогично для gap (если нужно)
	static setGapFor = function(value, class_names) {
	    for (var i = 0; i < array_length(class_names); i++) {
	        var cls = class_names[i];
			if (!variable_struct_exists(self._class_overrides, cls)) {
	            self._class_overrides[$ cls] = {};
	        }
	        self._class_overrides[$ cls][$ "gap"] = value;
	    }
		return self;
	}
	
	// FONTS FUNCTIONS
	
	///@desc Set fonts (_default, _buttons, _debug)
	///@arg {asset.GMFont} _default
	///@arg {asset.GMFont} _buttons
	///@arg {asset.GMFont} _debug
	static setFonts = function(_default, _buttons, _debug) {
		// Fonts
		self.font_default = _default;
		self.font_buttons = _buttons;
		self.font_debug = _debug;
		return self;
	}
	
	// SPRITES FUNCTIONS
	
	///@desc Set default sprites for almost all components (_panel, _element, _panel_border, _element_border)
	///@arg {asset.GMSprite} _panel
	///@arg {asset.GMSprite} _element
	///@arg {asset.GMSprite} [_panel_border]
	///@arg {asset.GMSprite} [_element_border]
	static setSprites = function(_panel, _element, _panel_border = undefined, _element_border = undefined) {
		// Panel
		self.sprite_panel = _panel;
		self.sprite_panel_border = _panel_border;
		self.sprite_tab = _panel;
		self.sprite_tab_border = _panel_border;
		self.sprite_tabs = _panel;
		self.sprite_tabs_border = _panel_border;
		self.sprite_scroll_pin = _panel;
		self.sprite_scroll_pin_border = _panel_border;
		// Element
		self.sprite_input = _element;
		self.sprite_button = _element;
		self.sprite_checkbox = _element;
		self.sprite_checkbox_pin = _element;
		self.sprite_progress_bar = _element;
		self.sprite_progress_bar_value = _element;
		self.sprite_slider_knob = _element;
		self.sprite_scroll_slider = _element;
		self.sprite_combobox = _element;
		self.sprite_combobox_item = _element;
		self.sprite_tooltip = _element;
		self.sprite_progress_ring = _element;
		self.sprite_progress_ring_value = _element;
		self.sprite_combobox_arrow = _element;
		self.sprite_toggleswitch = _element;
		self.sprite_toggleswitch_slider = _element;
		// Border
		self.sprite_input_border = _element_border;
		self.sprite_button_border = _element_border;
		self.sprite_checkbox_border = _element_border;
		self.sprite_progress_bar_border = _element_border;
		self.sprite_slider_knob_border = _element_border;
		self.sprite_combobox_border = _element_border;
		self.sprite_combobox_item_border = _element_border;
		self.sprite_tooltip_border = _element_border;
		self.sprite_progress_ring_border = _element_border;
		self.sprite_toggleswitch_border = _element_border;
		self.sprite_toggleswitch_slider_border = _element_border;
		return self;
	}
	
	///@desc Set sprites for CheckBox component (_checkbox, _checkbox_pin, _checkbox_border)
	///@arg {asset.GMSprite} _checkbox
	///@arg {asset.GMSprite} _checkbox_pin
	///@arg {asset.GMSprite} [_checkbox_border]
	static setSpriteCheckbox = function(_checkbox, _checkbox_pin, _checkbox_border = undefined) {
		self.sprite_checkbox = _checkbox;
		self.sprite_checkbox_pin = _checkbox_pin;
		self.sprite_checkbox_border = _checkbox_border;
		return self;
	}
	
	///@desc Set sprites for ToggleSwitch component (_toggleswitch, _toggleswitch_slider, _toggleswitch_border, _toggleswitch_slider_border)
	///@arg {asset.GMSprite} _toggleswitch
	///@arg {asset.GMSprite} _toggleswitch_slider
	///@arg {asset.GMSprite} [_toggleswitch_border]
	///@arg {asset.GMSprite} [_toggleswitch_slider_border]
	static setSpriteToggleSwitch = function(_toggleswitch, _toggleswitch_slider, _toggleswitch_border = undefined, _toggleswitch_slider_border = undefined) {
		self.sprite_toggleswitch = _toggleswitch;
		self.sprite_toggleswitch_slider = _toggleswitch_slider;
		self.sprite_toggleswitch_border = _toggleswitch_border;
		self.sprite_toggleswitch_slider_border = _toggleswitch_slider_border;
		return self;
	}
	
	///@desc Set sprites for ProgressBar component (_progressbar, _progressbar_value, _progressbar_border)
	///@arg {asset.GMSprite} _progressbar
	///@arg {asset.GMSprite} _progressbar_value
	///@arg {asset.GMSprite} [_progressbar_border]
	static setSpriteProgressBar = function(_progressbar, _progressbar_value, _progressbar_border = undefined) {
		self.sprite_progress_bar = _progressbar;
		self.sprite_progress_bar_value = _progressbar_value;
		self.sprite_progress_bar_border = _progressbar_border;
		return self;
	}
	
	///@desc Set sprites for SliderKnob component (_slider_knob, _slider_knob_border)
	///@arg {asset.GMSprite} _slider_knob
	///@arg {asset.GMSprite} [_slider_knob_border]
	static setSpriteSliderKnob = function(_slider_knob, _slider_knob_border = undefined) {
		self.sprite_slider_knob = _slider_knob;
		self.sprite_slider_knob_border = _slider_knob_border;
		return self;
	}
	
	///@desc Set sprites for Tabs component (_tabs, _tab, _tabs_border, _tab_border)
	///@arg {asset.GMSprite} _tabs
	///@arg {asset.GMSprite} _tab
	///@arg {asset.GMSprite} [_tabs_border]
	///@arg {asset.GMSprite} [_tab_border]
	static setSpriteTabs = function(_tabs, _tab, _tabs_border = undefined, _tab_border = undefined) {
		self.sprite_tabs = _tabs;
		self.sprite_tabs_border = _tabs_border;
		self.sprite_tab = _tab;
		self.sprite_tab_border = _tab_border;
		return self;
	}
	
	///@desc Set sprite for ComboBox arrow (_combobox_arrow)
	///@arg {asset.GMSprite} [_combobox_arrow]
	static setSpriteComboBoxArrow = function(_combobox_arrow = undefined) {
		self.sprite_combobox_arrow = _combobox_arrow;
		return self;
	}
	
	///@desc Set sprites for ProgressRing component (_ring, _ring_value, _ring_border)
	///@arg {asset.GMSprite} _ring
	///@arg {asset.GMSprite} _ring_value
	///@arg {asset.GMSprite} [_ring_border]
	static setSpriteRing = function(_ring, _ring_value, _ring_border = undefined) {
		self.sprite_progress_ring = _ring;
		self.sprite_progress_ring_value = _ring_value;
		self.sprite_progress_ring_border = _ring_border;
		return self;
	}
	
	///@desc Set sprites for Scroll slider (_scroll_slider, _scroll_pin, _scroll_pin_border)
	///@arg {asset.GMSprite} _scroll_slider
	///@arg {asset.GMSprite} _scroll_pin
	///@arg {asset.GMSprite} [_scroll_pin_border]
	static setSpriteScrollSlider = function(_scroll_slider, _scroll_pin, _scroll_pin_border = undefined) {
		self.sprite_scroll_slider = _scroll_slider;
		self.sprite_scroll_pin = _scroll_pin;
		self.sprite_scroll_pin_border = _scroll_pin_border;
		return self;
	}
	
	///@desc Set sprites for tooltip (_tooltip, _tooltip_border)
	///@arg {asset.GMSprite} _tooltip
	///@arg {asset.GMSprite} [_tooltip_border]
	static setSpriteTooltip = function(_tooltip, _tooltip_border = undefined) {
		self.sprite_tooltip = _tooltip;
		self.sprite_tooltip_border = _tooltip_border;
		return self;
	}
	
	// COLORS FUNCTIONS
	
	///@desc Sets the primary, secondary, accent, and border colors for UI elements.
    ///@arg {Real} [_primary] The primary color for elements (default: c_white).
    ///@arg {Real} [_secondary] The secondary color for interactive elements (default: c_ltgray).
    ///@arg {Real} [_back] The back color for interactive elements (default: c_ltgray).
    ///@arg {Real} [_accent] The accent color for active states (default: c_green).
    ///@arg {Real} [_border] The border color for elements (default: c_gray).
    static setColors = function(_primary = c_white, _secondary = c_ltgray, _back = c_ltgray, _accent = c_green, _border = c_gray) {
        // Panel
        self.color_primary = _primary;
        self.color_secondary = _secondary;
		self.color_back = _back;
        self.color_accent = _accent;
        self.color_border = _border;
        return self;
    }
    
    ///@desc Sets the accent color for interactive elements.
    ///@arg {Real} [_color] The accent color for active states (default: c_green).
    static setColorAccent = function(_color = c_green) {
        self.color_accent = _color;
        return self;
    }
    
    ///@desc Sets the hover color for UI elements.
    ///@arg {Real} [_hover] The hover color to be mixed with element colors (default: c_gray).
    static setColorHover = function(_hover = c_gray) {
        self.color_hover = _hover;
        return self;
    }
    
    ///@desc Sets the text and text hint colors for UI elements.
    ///@arg {Real} [_font] The color for text (default: c_black).
    ///@arg {Real} [_font_hint] The color for text hints (default: c_gray).
    static setColorText = function(_font = c_black, _font_hint = c_gray) {
        self.color_text = _font;
        self.color_text_hint = _font_hint;
        return self;
    }
    
    ///@desc [DEPRECATED] Previously set the tooltip colors (no longer used).
    ///@arg {Real} [_tooltip] The tooltip background color (default: c_white).
    ///@arg {Real} [_tooltip_border] The tooltip border color (default: c_black).
    ///@deprecated
    static setColorTooltip = function(_tooltip = c_white, _tooltip_border = c_black) {
        _luiPrintWarning($"setColorTooltip: function is deprecated!");
        return self;
    }
    
    ///@desc Sets the color for deactivated elements, which can be mixed with active colors.
    ///@arg {Real} [_color] The base color for deactivated elements (default: c_gray).
    static setColorDeactivated = function(_color = c_gray) {
        self.color_deactivated = _color;
        return self;
    }
    
    ///@desc Sets the semantic colors for success, error, and warning states.
    ///@arg {Real} [_success] The color for success (default: #4CAF50).
	///@arg {Real} [_warning] The color for warning (default: #FF9800).
    ///@arg {Real} [_error] The color for error (default: #F44336).
    static setColorSemantic = function(_success = #4CAF50, _warning = #FF9800, _error = #F44336) {
        self.color_semantic_success = _success;
        self.color_semantic_warning = _warning;
		self.color_semantic_error = _error;
        return self;
    }
    
    ///@desc Sets the optional shadow color for UI elements (default: undefined).
    ///@arg {Real} [_color] The shadow color (default: undefined).
    static setColorShadow = function(_color = undefined) {
        self.color_shadow = _color;
        return self;
    }
	
	// SOUNDS FUNCTIONS
	
	///@desc Set sounds (_click)
	///@arg {asset.GMSound} [_click]
	static setSounds = function(_click = undefined) {
		self.sound_click = _click;
		return self;
	}
	
	// SETTINGS FUNCTIONS
	
	///@desc Set default min size for all elements (_min_width, _min_height)
	///@arg {real} [_min_width]
	///@arg {real} [_min_height]
	static setMinSize = function(_min_width = 32, _min_height = 32) {
		self.min_width = _min_width;
		self.min_height = _min_height;
		return self;
	}
	
	///@desc Set default margin for all elements (_margin)
	///@arg {real} [_margin]
	static setMargin = function(_margin) {
		self.margin = _margin;
		return self;
	}
	
	///@desc Set default padding for all elements (_padding)
	///@arg {real} [_padding]
	static setPadding = function(_padding) {
		self.padding = _padding;
		return self;
	}
	
	///@desc Set default gap for all elements (_gap)
	///@arg {real} [_gap]
	static setGap = function(_gap) {
		self.gap = _gap;
		return self;
	}
	
	///@desc Set default border for all elements (_border)
	///@arg {real} [_border]
	static setBorder = function(_border) {
		self.border = _border;
		return self;
	}
	
	///@desc Set scroll step size for LuiScrollPanel (_scroll_step)
	///@arg {real} [_scroll_step]
	static setScrollStep = function(_scroll_step = 32) {
		self.scroll_step = _scroll_step;
		return self;
	}
	
	///@desc Set scroll slider width of LuiScrollPanel (_width)
	///@arg {real} [_width]
	static setScrollSliderWidth = function(_width = 16) {
		self.scroll_slider_width = _width;
		return self;
	}
	
	///@desc Set default render region offset for elements
	///@arg {struct, array} _region struct{left, right, top, bottom} or array [left, right, top, bottom]
	static setRenderRegionOffset = function(_region = {left : 0, right : 0, top : 0, bottom : 0}) {
		if is_struct(_region) {
			self.render_region_offset = _region;
		} else if is_array(_region) {
			if array_length(_region) != 4 {
				array_resize(_region, 4);
			}
			self.render_region_offset = {
				left : _region[0],
				right : _region[1],
				top : _region[2],
				bottom : _region[3]
			}
		} else {
			_luiPrintWarning($"setRenderRegionOffset: Wrong type appear, when struct or array is expected!");
		}
		return self;
	}
	
	///@desc Set text cursor for LuiInput (_text_cursor)
	///@arg {string} [_text_cursor]
	static setTextCursor = function(_text_cursor = "|") {
		self.input_cursor = _text_cursor;
		return self;
	}
	
	///@desc Set password symbol (_symbol_password)
	///@arg {string} [_symbol_password]
	static setSymbolPassword = function(_symbol_password = "•") {
		self.input_password = _symbol_password;
		return self;
	}
}
