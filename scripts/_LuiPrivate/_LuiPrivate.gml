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

///@desc Converts a LuiStyle instance into a plain raw struct (instance variables only)
///@param {Struct} _style LuiStyle instance
///@return {Struct} Plain struct with all style fields
///@ignore
function _luiStyleToRawStruct(_style) {
	var _raw = {};
	if (!is_struct(_style)) return _raw;
	var _names = variable_struct_get_names(_style);
	for (var i = 0; i < array_length(_names); i++) {
		var _key = _names[i];
		_raw[$ _key] = variable_struct_get(_style, _key);
	}
	return _raw;
}

///@desc Merges override keys from _src into _dest in place.
/// Undefined values remove the corresponding key from _dest. Returns _dest.
///@param {Struct} _dest Target struct (created if undefined)
///@param {Struct} _src Source struct with overrides
///@return {Struct} Merged destination struct
///@ignore
function _luiMergeOverrides(_dest, _src) {
	if (!is_struct(_dest)) _dest = {};
	if (!is_struct(_src)) return _dest;
	var _names = variable_struct_get_names(_src);
	for (var i = 0; i < array_length(_names); i++) {
		var _key = _names[i];
		var _value = _src[$ _key];
		if (is_undefined(_value)) {
			variable_struct_remove(_dest, _key);
		} else {
			_dest[$ _key] = _value;
		}
	}
	return _dest;
}

///@desc Merges _src into _dest in place. Unlike _luiMergeOverrides, this function
/// preserves undefined values (does not remove keys). Used for merging defaults.
///@param {Struct} _dest Target struct
///@param {Struct} _src Source struct
///@return {Struct} Merged destination struct
///@ignore
function _luiMergeStruct(_dest, _src) {
	if (!is_struct(_dest)) _dest = {};
	if (!is_struct(_src)) return _dest;
	var _names = variable_struct_get_names(_src);
	for (var i = 0; i < array_length(_names); i++) {
		var _key = _names[i];
		_dest[$ _key] = _src[$ _key];
	}
	return _dest;
}