///@ignore
function _luiPrintError(_text) {
	if LUI_LOG_ERROR_MODE >= 1 {
		var _element_name = self[$ "name"];
		print($"LIME_UI.ERROR.{_element_name}.{instanceof(self)}: " + _text);
	}
}

///@ignore
function _luiPrintWarning(_text) {
	if LUI_LOG_ERROR_MODE >= 2 {
		var _element_name = self[$ "name"];
		print($"LIME_UI.WARNING.{_element_name}.{instanceof(self)}: " + _text);
	}
}

///@ignore
function _luiGetConstructorKeys(_class) {
	static _base_keys = ["x", "y", "r", "b", "min_width", "min_height", "max_width", "max_height", "width", "w", "height", "h", "name"];
	static _widget_keys = {
		LuiBase: [],
		LuiAbsoluteContainer: [],
		LuiBox: ["color", "alpha"],
		LuiButton: ["text", "color"],
		LuiCheckbox: ["value", "text", "icon_spacing"],
		LuiColumn: [],
		LuiComboBox: ["text", "color", "placeholder"],
		LuiComboBoxItem: ["text", "color"],
		LuiContainer: [],
		LuiImage: ["value", "subimg", "color", "alpha", "maintain_aspect"],
		LuiImageButton: ["value", "subimg", "color", "alpha", "maintain_aspect"],
		LuiInput: ["value", "placeholder", "is_masked", "max_length", "input_mode", "excluded_chars", "allowed_chars"],
		LuiLayer: [],
		LuiMessage: ["color", "alpha", "text", "content", "backdrop_blur", "button_text"],
		LuiPanel: ["allow_resize", "scroll_x", "scroll_y"],
		LuiProgressBar: ["value", "min_value", "max_value", "rounding", "display_value", "bar_height", "color"],
		LuiProgressRing: ["value", "min_value", "max_value", "rounding", "display_value", "bar_height", "color"],
		LuiRow: [],
		LuiScrollPanel: ["allow_resize", "scroll_x", "scroll_y"],
		LuiSlider: ["value", "min_value", "max_value", "rounding", "display_value", "bar_height", "color"],
		LuiSurface: ["value", "color", "alpha", "maintain_aspect"],
		LuiTab: ["text", "color"],
		LuiTabs: ["allow_resize", "scroll_x", "scroll_y", "tab_height", "tab_indent"],
		LuiText: ["value", "text_halign", "text_valign", "overflow", "scale_to_fit"],
		LuiToggleButton: ["text", "color", "value"],
		LuiToggleSwitch: ["value", "text", "icon_spacing"],
		LuiWindow: ["allow_resize", "scroll_x", "scroll_y", "title", "show_controls"],
		LuiWindowHeader: ["title", "show_controls"]
	};
	if _class == "LuiScrollThumb" return ["panel", "horizontal"];
	var _keys = _widget_keys[$ _class];
	if is_undefined(_keys) return undefined;
	return array_concat(_base_keys, _keys);
}

///@desc Converts a LuiStyle instance into a plain raw struct (instance variables only)
///@arg {Struct} _style LuiStyle instance
///@return {Struct} Plain struct with all style fields
///@ignore
function _luiStyleToRawStruct(_style) {
	var _raw = {};
	if !is_struct(_style) return _raw;
	var _names = variable_struct_get_names(_style);
	for (var i = 0; i < array_length(_names); i++) {
		var _key = _names[i];
		_raw[$ _key] = variable_struct_get(_style, _key);
	}
	return _raw;
}

///@desc Merges override keys from _src into _dest in place.
/// Undefined values remove the corresponding key from _dest. Returns _dest.
///@arg {Struct} _dest Target struct (created if undefined)
///@arg {Struct} _src Source struct with overrides
///@return {Struct} Merged destination struct
///@ignore
function _luiMergeOverrides(_dest, _src) {
	if !is_struct(_dest) {
		_dest = {};
	}
	if !is_struct(_src) return _dest;
	var _names = variable_struct_get_names(_src);
	for (var i = 0; i < array_length(_names); i++) {
		var _key = _names[i];
		var _value = _src[$ _key];
		if is_undefined(_value) {
			variable_struct_remove(_dest, _key);
		} else {
			_dest[$ _key] = _value;
		}
	}
	return _dest;
}

///@desc Merges _src into _dest in place. Unlike _luiMergeOverrides, this function
/// preserves undefined values (does not remove keys). Used for merging defaults.
///@arg {Struct} _dest Target struct
///@arg {Struct} _src Source struct
///@return {Struct} Merged destination struct
///@ignore
function _luiMergeStruct(_dest, _src) {
	if !is_struct(_dest) {
		_dest = {};
	}
	if !is_struct(_src) return _dest;
	var _names = variable_struct_get_names(_src);
	for (var i = 0; i < array_length(_names); i++) {
		var _key = _names[i];
		_dest[$ _key] = _src[$ _key];
	}
	return _dest;
}
