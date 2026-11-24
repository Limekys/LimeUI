///@desc The basic constructor of all elements, which contains all the basic functions and logic of each element.
/// Available parameters:
/// x - x position for element (left position of flex node)
/// y - y position for element (top position of flex node)
/// r - right position for element (right position of flex node)
/// b - bottom position for element (bottom position of flex node)
/// width - width of element
/// w - alias for width
/// height - height of element
/// h - alias for height
/// min_width - minimum width of element
/// min_height - minimum height of element
/// max_width - maximum width of element
/// max_height - maximum height of element
/// name - unique name_id for element
///@arg {Struct} [_params] Struct with parameters
function LuiBase(_params = {}) constructor {
	// STATE AND PARAMETERS

	self.element_id = undefined; // Assigned when attached to a UI root.
	self.name = LUI_AUTO_NAME;							//Unique element identifier
	self.value = undefined;								//Value
	self.data = undefined;								//Different user data for personal use

	// Inherited and local styles
	self.style = undefined;								//Inheritable style (LuiStyle), flows down the hierarchy
	self.local_style = undefined;						//Local style overrides for this element only (plain struct)
	self._style_dirty = true;							//True when the cached effective style must be rebuilt
	self._cached_style = undefined;						//Cached effective style: style + class rules + local_style
	self._has_own_style = false;						//True if the style was set via setStyle() (protected from parent inheritance)
	self._style_delta = undefined;						//Persistent overrides applied on top of the inherited style (set by setStyle with a struct)

	// Layout bounds and constraints
	self.x = LUI_AUTO;									//Actual real calculated x position on the screen
	self.y = LUI_AUTO;									//Actual real calculated y position on the screen
	self.r = LUI_AUTO;
	self.b = LUI_AUTO;
	self.z = 0;											//Depth
	self.start_x = -1;									//First x position
	self.start_y = -1;									//First y position
	self.prev_x = -1;									//Previous floor(x) position on the screen
	self.prev_y = -1;									//Previous floor(y) position on the screen
	self.width = LUI_AUTO;								//Actual real calculated width of element
	self.height = LUI_AUTO;								//Actual real calculated height of element
	self.prev_w = -1;									//Previous width
	self.prev_h = -1;									//Previous height
	self.min_width = LUI_AUTO;
	self.min_height = LUI_AUTO;
	self._explicit_min_width = LUI_AUTO;
	self._explicit_min_height = LUI_AUTO;
	self._content_min_height = 0;
	self._applied_style = undefined;
	self.max_width = LUI_AUTO;
	self.max_height = LUI_AUTO;
	self.auto_x = false;
	self._position_type = flexpanel_position_type.relative;
	self._position_edges = {x: undefined, y: undefined, r: undefined, b: undefined};
	self._keep_in_viewport = false;
	self._viewport_align_right = false;
	self._viewport_clamp_revision = -1;
	self.auto_y = false;
	self.auto_width = false;
	self.auto_height = false;
	self._requested_width = undefined;
	self._requested_height = undefined;
	self._align_x = undefined;
	self._align_y = undefined;

	// Element tree
	self.parent = undefined;
	self._scroll_owner = undefined;
	self._flex_bounds = undefined;
	self._overlay_bounds = undefined;
	self._child_bounds_stale = true;
	self.content = [];
	self.delayed_content = [];
	self.container = self; 								//Sometimes the container may not be the element itself, but the element inside it (for example: LuiTab, LuiScrollPanel...)

	// Visibility and input state
	self.deactivated = false;
	self.visible = true;
	self._allows_visibility_changes = true;
	self.has_focus = false;
	self._keyboard_focusable = undefined;
	self._blocks_keyboard_shortcuts = false;
	self._shortcut_key = undefined;
	self._tags = [];
	self.ignore_mouse = false;
	self.ignore_mouse_all = undefined;
	self._content_update_pending = false;
	self.main_ui = undefined;
	self.tooltip = "";
	self._value_binding = undefined;
	self.is_pressed = false;
	self.is_mouse_hovered = false;
	self.is_adding = false;
	self.is_destroyed = false;
	self._is_modal = false;
	self.is_initialized = false;
	self._clip_children = false;
	self.render_region_offset = { //???// it may still be useful
		left : 0,
		right : 0,
		top : 0,
		bottom : 0
	};
	self.flex_node = flexpanel_create_node({ name: self.name, data: {} });
	var _data = flexpanel_node_get_data(self.flex_node);
	_data.element = self;

	// Memo for _drawTruncatedText
	self._tc_string = "";
	self._tc_width = -1;
	self._tc_font = -1;
	self._tc_result = "";

	// Screen grid system
	self._screen_grid_cell_ids = []; //Screen grid to optimize the search for items under the mouse cursor
	
	// View region system
	self._visible_bounds = {
		x1: 0,
		y1: 0,
		x2: 10000,
		y2: 10000
	};
	self.prev_view_region = { //???// Can be used for some events
		x1: 0,
		y1: 0,
		x2: 10000,
		y2: 10000
	};
	
	// Region to which children are cropped (differs from _visible_bounds only for non-clipping parents)
	self._child_clip_bounds = { x1: 0, y1: 0, x2: 10000, y2: 10000 };
	self._intersects_clip_region = false;
	
	// Depth system
	self.nesting_level = 0;
	self._z_order_path = [];
	
	// Dragging system
	self.can_drag = false;
	self.is_dragging = false;
	self.drag_offset_x = 0;
	self.drag_offset_y = 0;

	// Visual Transform (Offset Transform) - Does not affect Flex layout or mouse collision
	self.visual_x = 0;
	self.visual_y = 0;
	self.visual_scale_x = 1;
	self.visual_scale_y = 1;
	self.visual_angle = 0;
	self.visual_alpha = 1;
	self.pivot_x = 0.5; // 0.0 to 1.0
	self.pivot_y = 0.5; // 0.0 to 1.0

	// Surface Caching (Render to Texture)
	self.cache_as_surface = false;		// Explicit caching requested by the caller
	self.cache_padding = 0;				// Extra space for content extending beyond the element
	self._cache_active = false;			// A complete cache is ready to draw
	self._cached_surface = -1;
	self._is_cache_dirty = true;
	self._last_visual_alpha = self.visual_alpha;

	self.material = undefined;

	// Child draw order, sorted by z when it changes
	self._draw_children = [];
	self._draw_order_dirty = true;

	// Constructor parameters
	self._debug_param_keys = undefined;
	if is_struct(_params) {
		if LUI_DEBUG_VALIDATE_PARAMS || global.lui_debug_mode != 0 {
			self._debug_param_keys = variable_struct_get_names(_params);
		}
		self.x = _params[$ "x"] ?? LUI_AUTO;
		self.y = _params[$ "y"] ?? LUI_AUTO;
		self.r = _params[$ "r"] ?? LUI_AUTO;
		self.b = _params[$ "b"] ?? LUI_AUTO;
		self.min_width = _params[$ "min_width"] ?? LUI_AUTO;
		self.min_height = _params[$ "min_height"] ?? LUI_AUTO;
		self._explicit_min_width = self.min_width;
		self._explicit_min_height = self.min_height;
		self.max_width = _params[$ "max_width"] ?? 10000;
		self.max_height = _params[$ "max_height"] ?? 10000;
		self.width = _params[$ "width"] ?? _params[$ "w"] ?? LUI_AUTO;
		self.height = _params[$ "height"] ?? _params[$ "h"] ??  LUI_AUTO;
		self.name = _params[$ "name"] ?? LUI_AUTO_NAME;
	} else {
		_luiPrintError($"A structure with parameters was expected, but a {typeof(_params)} was received!");
	}

	// Optional instance hooks

	///@desc Calls every step
	self.step = undefined;

	///@desc Pre draw method call before draw method (for surfaces for example)
	self.preDraw = undefined;

	///@desc Draw method for element
	self.draw = undefined;

	// Event listeners
	self.event_listeners = {};

	// PUBLIC API

	// Data and identity

	///@desc Get value of this element
	///@return {any} Value depends on element
	static get = function() {
		return self.value;
	}

	///@desc Set value
	///@arg {any} _value
	static set = function(_value) {
		if self.value != _value {
			var _redraw = self._valueAffectsRender(self.value, _value);
			self.value = _value;
			if !is_undefined(self._value_binding) {
				self._writeBoundValue();
			}
			self._dispatchEvent(LUI_EV_VALUE_UPDATE);
			if _redraw {
				self.invalidateCache();
			}
		}
		return self;
	}

	///@ignore
	static _valueAffectsRender = function(_previous, _next) {
		return true;
	}

	///@desc Get data struct or specified value from it
	///@arg {string} _key variable name
	static getData = function(_key = undefined) {
		if is_undefined(_key) {
			return self.data;
		} else {
			return self.data[$ _key];
		}
	}

	///@desc Sets one data field or merges all fields from a struct.
	///@arg {String|Struct} _key Field name or struct of fields
	///@arg {Any} [_value] Value when a field name is supplied
	///@return {Struct} This element
	static setData = function(_key, _value = undefined) {
		if is_undefined(self.data) {
			self.data = {};
		}
		if is_struct(_key) {
			var _keys = variable_struct_get_names(_key);
			for (var i = 0, n = array_length(_keys); i < n; i++) {
				var _name = _keys[i];
				self.data[$ _name] = _key[$ _name];
			}
		} else {
			self.data[$ _key] = _value;
		}
		return self;
	}

	///@desc Adds a case-sensitive tag. Built-in tags use the lowercase concrete widget class without the Lui prefix.
	///@arg {String} _tag Tag to add
	///@return {Struct} This element
	static addTag = function(_tag) {
		if self.is_destroyed || _tag == "" || array_contains(self._tags, _tag) return self;
		array_push(self._tags, _tag);
		if !is_undefined(self.main_ui) {
			self._indexTag(_tag);
		}
		return self;
	}

	///@desc Use addTag() to add a tag.
	///@deprecated
	static setTag = function(_tag) {
		return self.addTag(_tag);
	}

	///@desc Removes a tag from this element.
	///@arg {String} _tag Tag to remove
	///@return {Struct} This element
	static removeTag = function(_tag) {
		var _index = array_get_index(self._tags, _tag);
		if _index < 0 return self;
		array_delete(self._tags, _index, 1);
		if !is_undefined(self.main_ui) {
			self._unindexTag(_tag);
		}
		return self;
	}

	///@desc Set element unique identificator name (Used for get element from main ui container via getElement())
	static setName = function(_string) {
		if is_undefined(self.main_ui) || !variable_struct_exists(self.main_ui, "element_names") {
			self.name = _string;
		} else {
			if !variable_struct_exists(self.main_ui.element_names, _string) {
				self._deleteElementName();
				self.name = _string;
				self._registerElementName();
			} else {
				_luiPrintWarning($"Element name \"{_string}\" already exists! Please give another name!");
			}
		}
		return self;
	}

	///@desc Binds the object/struct variable to the element value
	static bindVariable = function(_source, _variable) {
		if _source != noone && _variable != "" {
			self._value_binding = {
				source : _source,
				variable : _variable
			}
			if !variable_instance_exists(_source, _variable) {
				_luiPrintWarning($"Trying to bind variable: Can't find variable '{_variable}'!");
			}
		} else {
			_luiPrintError($"Wrong variable name or instance!");
		}
		return self;
	}

	// Content and containers

	///@desc Get container element
	self.getContainer = function() {
		return self.container;
	}

	///@desc Set container, Sometimes the container may not be the element itself, but the element inside it (for example: LuiTab, LuiScrollPanel...)
	static setContainer = function(_container) {
		self.container = _container;
		return self;
	}

	///@desc Get content array
	self.getContent = function() {
		return self.getContainer().content;
	}

	///@desc Returns the first user content element.
	static getFirst = function() {
		return array_first(self.getContent());
	};

	///@desc Returns the last user content element.
	static getLast = function() {
		return array_last(self.getContent());
	};

	///@desc Added elements into container of these element
	///@arg {Any} elements
	self.addContent = function(elements) {
		if self.is_destroyed return self;
		self.getContainer().addContentDirect(elements);
		return self;
	}

	///@desc Adds content directly to this element, bypassing its redirected content container.
	///@arg {Any} elements Element or array of elements
	self.addContentDirect = function(elements) {

		// Convert to array if one element
		if !is_array(elements) {
			elements = [elements];
		}

		var _elements_count = array_length(elements);
		if self.is_destroyed || _elements_count == 0 return self;

		// Update array with delayed content for unordered adding
		if is_undefined(self.main_ui) {
			array_push(self.delayed_content, elements);
			return self;
		}

		// Take ranges from array
		var _ranges = elements[_elements_count - 1];
		if is_array(_ranges) {
			if array_length(_ranges) != _elements_count - 1 {
				if LUI_LOG_ERROR_MODE == 2 {
					_luiPrintWarning($"Incorrect number of ratios for {self.name} ({instanceof(self)}). Elements {_elements_count - 1}, but ratios {array_length(_ranges)}.\nThe others will be filled in automatically and the extra ones will be cut off.");
				}

				var _current_length = array_length(_ranges);
				var _target_length = _elements_count - 1;

				if _current_length < _target_length {
					var _sum = 0;
					for (var i = 0; i < _current_length; i++) {
						_sum += _ranges[i];
					}
					var _remaining = 1 - _sum;
					var _num = _remaining / (_target_length - _current_length);

					while (array_length(_ranges) < _target_length) {
						array_push(_ranges, _num);
					}
				}
			}

			_elements_count--;
		}

		// Adding
		for (var i = 0; i < _elements_count; i++) {

			// Get element
			var _element = elements[i];
			if !is_struct(_element) || !is_instanceof(_element, LuiBase) {
				_luiPrintWarning("addContent expects a LimeUI element.");
				continue;
			}
			if _element == self || _element.is_destroyed || _element.is_adding || !is_undefined(_element.main_ui) {
				_luiPrintWarning($"Cannot add element \"{_element.name}\". It is already attached, being added, or destroyed.");
				continue;
			}

			// Init element
			_element._initElement();

			_element.is_adding = true;

			// Init depth
			_element.nesting_level = self.nesting_level + 1;
			_element.element_id = self.main_ui._next_element_id++;
			self.main_ui.element_count++;
			_element.z = self.main_ui._next_z++;
			_element._z_order_path = array_concat(self._z_order_path, [_element.z]);

			// Inherit variables
			_element.parent = self;
			_element.main_ui = self.main_ui;

			// Style inheritance:
			// - Elements without their own style inherit the parent style as-is
			// - Elements with delta overrides rebuild their style on top of the parent style
			// - Elements with a fully autonomous style keep it untouched
			if !_element._has_own_style || is_struct(_element._style_delta) {
				_element._rebuildStyleFromInherited(self.style);
			}
			_element._style_dirty = true;

			// Mouse ignoring
			if !is_undefined(self.ignore_mouse_all) {
				_element.ignore_mouse_all = true;
				_element.ignore_mouse = true;
			}

			// Visibility
			if self.visible == false {
				_element.visible = self.visible;
			}

			// Flex setting up
			if array_length(_ranges) > 0 && i+1 <= array_length(_ranges) {
				flexpanel_node_style_set_flex(_element.flex_node, _ranges[i]);
				flexpanel_node_style_set_flex_shrink(_element.flex_node, _ranges[i]);
			}
			flexpanel_node_insert_child(self.flex_node, _element.flex_node, flexpanel_node_get_num_children(self.flex_node));

			// Apply styles settings
			_element._applyStyles();

			// Register element name
			_element._registerElementName();
			_element._registerTags();
			_element._validateConstructorParams();
			if !is_undefined(_element._shortcut_key) {
				_element._syncShortcutRegistration();
			}

			// Add to content array
			if !is_array(self.content) {
				self.content = [];
			}
			array_push(self.content, _element);
			self._draw_order_dirty = true;
			_element._addDelayedContent();

			// Call create event
			_element._dispatchEvent(LUI_EV_CREATE);

			_element.is_adding = false;
		}

		// Update content
		self.requestContentUpdate();

		// Update flex
		self.requestFlexLayout();

		return self;
	}

	///@desc Use addContentDirect() to add content directly.
	///@deprecated
	self.addContentOriginal = function(elements) {
		return self.addContentDirect(elements);
	}

	///@desc Destroys all elements from real element container
	self.destroyContent = function() {
		if self.is_destroyed return;
		self.getContainer()._destroyAllNestedElements();
	}

	///@desc Requests a content update. Optionally also requests updates on all ancestors.
	///@arg {Bool} [_update_parent] Include ancestors
	///@return {Struct} This element
	static requestContentUpdate = function(_update_parent = false) {
		self._content_update_pending = true;
		if _update_parent {
			if is_undefined(self.parent) return self;
			self.parent.requestContentUpdate(true);
		}
		return self;
	}

	///@desc Compatibility alias for requestContentUpdate().
	///@deprecated
	///@arg {Bool} [_update_parent] Include ancestors
	///@return {Struct} This element
	///@deprecated
	static setNeedToUpdateContent = function(_update_parent = false) {
		return self.requestContentUpdate(_update_parent);
	}

	// Layout

	///@desc Returns the last Flex layout bounds without recalculating layout.
	/// Bounds are in GUI coordinates by default and exclude visual transforms.
	/// Coordinates and dimensions are zero before the first layout and after destruction.
	///@arg {Bool} [_relative] Return bounds relative to the Flex parent when true
	///@return {Struct} Calculated bounds with left, top, width and height
	static getLayoutBounds = function(_relative = false) {
		if self.is_destroyed || is_undefined(self.flex_node) {
			return {left: 0, top: 0, width: 0, height: 0};
		}
		if is_method(self._overlay_bounds) {
			if is_undefined(self._flex_bounds) return {left: 0, top: 0, width: 0, height: 0};
			var _overlay = self._overlay_bounds();
			if _relative && !is_undefined(self.parent) {
				_overlay.left -= self.parent.x;
				_overlay.top -= self.parent.y;
			}
			return _overlay;
		}
		var _bounds = flexpanel_node_layout_get_position(self.flex_node, _relative);
		var _node = self;
		while !is_undefined(_node) {
			if !is_undefined(_node._scroll_owner) {
				var _offset = _node._scroll_owner._getLayoutOffset();
				_bounds.left += _offset.x;
				_bounds.top += _offset.y;
			}
			if _relative return _bounds;
			_node = _node.parent;
		}
		return _bounds;
	}

	///@desc Returns the width from the last Flex layout in GUI units.
	///@return {Real} Calculated width
	static getWidth = function() {
		return self.getLayoutBounds().width;
	}

	///@desc Returns the height from the last Flex layout in GUI units.
	///@return {Real} Calculated height
	static getHeight = function() {
		return self.getLayoutBounds().height;
	}

	///@desc Set flexpanel(element) position type (default is flexpanel_position_type.relative)
	///@arg {constant.flexpanel_position_type} [_type]
	static setPositionType = function(_type = flexpanel_position_type.relative) {
		var _flex_node = self.flex_node;
		self._position_type = _type;
		flexpanel_node_style_set_position_type(_flex_node, _type);
		if self.is_initialized && _type == flexpanel_position_type.absolute {
			self._applyAbsoluteDefaults();
		}
		self.requestFlexLayout();
		return self;
	}

	///@desc Shortcut method to make element position type absolute (eq. setPositionType(flexpanel_position_type.absolute))
	static setPositionAbsolute = function() {
		self.setPositionType(flexpanel_position_type.absolute);
		return self;
	}

	///@desc Set flexpanel(element) X position
	///@arg {real} [_x] left = X
	static setPosX = function(_x = LUI_AUTO) {
		return self.setPosition(_x);
	}

	///@desc Sets the requested top position.
	///@arg {Real} [_y] Top position
	static setPosY = function(_y = LUI_AUTO) {
		return self.setPosition(, _y);
	}

	///@desc Sets the requested right position.
	///@arg {Real} [_r] Right position
	static setPosR = function(_r = LUI_AUTO) {
		return self.setPosition(, , _r);
	}

	///@desc Sets the requested bottom position.
	///@arg {Real} [_b] Bottom position
	static setPosB = function(_b = LUI_AUTO) {
		return self.setPosition(, , , _b);
	}

	///@desc Sets the requested Flex offsets. Omit an offset to keep its current value.
	///@arg {Real} [_x] Left position
	///@arg {Real} [_y] Top position
	///@arg {Real} [_r] Right position
	///@arg {Real} [_b] Bottom position
	static setPosition = function(_x = LUI_AUTO, _y = LUI_AUTO, _r = LUI_AUTO, _b = LUI_AUTO) {
		var _changed = false;
		if _x != LUI_AUTO {
			_changed = self._setPositionEdge(flexpanel_edge.left, "x", _x) || _changed;
		}
		if _y != LUI_AUTO {
			_changed = self._setPositionEdge(flexpanel_edge.top, "y", _y) || _changed;
		}
		if _r != LUI_AUTO {
			_changed = self._setPositionEdge(flexpanel_edge.right, "r", _r) || _changed;
		}
		if _b != LUI_AUTO {
			_changed = self._setPositionEdge(flexpanel_edge.bottom, "b", _b) || _changed;
		}
		if _changed {
			self.requestFlexLayout();
		}
		return self;
	}

	///@desc Keeps an absolute element within the GUI viewport after layout.
	///@arg {Bool} [_enabled] Enable viewport clamping
	///@return {Struct} This element
	static setKeepInViewport = function(_enabled = true) {
		self._keep_in_viewport = _enabled;
		self.requestFlexLayout();
		return self;
	}

	///@desc Sets width in pixels or as a percentage of the Flex containing block.
	///@arg {Real|String} [_width] Pixel size or a string such as "50%"
	static setWidth = function(_width = LUI_AUTO) {
		return self.setSize(_width);
	}

	///@desc Sets height in pixels or as a percentage of the Flex containing block.
	///@arg {Real|String} [_height] Pixel size or a string such as "50%"
	static setHeight = function(_height = LUI_AUTO) {
		return self.setSize(, _height);
	}

	///@desc Sets the size. Omit either dimension to keep it unchanged.
	///@arg {Real|String} [_width] Pixel size or a percentage string
	///@arg {Real|String} [_height] Pixel size or a percentage string
	static setSize = function(_width = LUI_AUTO, _height = LUI_AUTO) {
		var _width_changed = self._setDimension(true, _width);
		var _height_changed = self._setDimension(false, _height);
		if _width_changed || _height_changed {
			self.requestFlexLayout();
		}
		return self;
	}

	///@desc Sets both dimensions to 100% of the Flex containing block.
	static setFullSize = function() {
		return self.setSize("100%", "100%");
	}

	///@desc Set flexpanel(element) min width
	///@arg {real} [_min_width]
	static setMinWidth = function(_min_width = LUI_AUTO) {
		if _min_width != LUI_AUTO {
			self._explicit_min_width = _min_width;
		}
		var _flex_node = self.flex_node;
		var _update_flex = false;
		if _min_width != LUI_AUTO && self.min_width != _min_width {
			self.min_width = _min_width;
			flexpanel_node_style_set_min_width(_flex_node, _min_width, flexpanel_unit.point);
			_update_flex = true;
		}
		if _update_flex {
			self.requestFlexLayout();
		}
		return self;
	}

	///@desc Set flexpanel(element) max width
	///@arg {real} [_max_width]
	static setMaxWidth = function(_max_width = LUI_AUTO) {
		var _flex_node = self.flex_node;
		var _update_flex = false;
		if _max_width != LUI_AUTO && self.max_width != _max_width {
			self.max_width = _max_width;
			flexpanel_node_style_set_max_width(_flex_node, _max_width, flexpanel_unit.point);
			_update_flex = true;
		}
		if _update_flex {
			self.requestFlexLayout();
		}
		return self;
	}

	///@desc Set flexpanel(element) min height
	///@arg {real} [_min_height]
	static setMinHeight = function(_min_height = LUI_AUTO) {
		if _min_height != LUI_AUTO {
			self._explicit_min_height = _min_height;
		}
		var _flex_node = self.flex_node;
		var _update_flex = false;
		if _min_height != LUI_AUTO && self.min_height != _min_height {
			self.min_height = _min_height;
			flexpanel_node_style_set_min_height(_flex_node, _min_height, flexpanel_unit.point);
			_update_flex = true;
		}
		if _update_flex {
			self.requestFlexLayout();
		}
		return self;
	}

	///@desc Set flexpanel(element) max height
	///@arg {real} [_max_height]
	static setMaxHeight = function(_max_height = LUI_AUTO) {
		var _flex_node = self.flex_node;
		var _update_flex = false;
		if _max_height != LUI_AUTO && self.max_height != _max_height {
			self.max_height = _max_height;
			flexpanel_node_style_set_max_height(_flex_node, _max_height, flexpanel_unit.point);
			_update_flex = true;
		}
		if _update_flex {
			self.requestFlexLayout();
		}
		return self;
	}

	///@desc Set flexpanel(element) min/max sizes
	///@arg {real} [_min_width]
	///@arg {real} [_max_width]
	///@arg {real} [_min_height]
	///@arg {real} [_max_height]
	static setMinMaxSize = function(_min_width = LUI_AUTO, _max_width = LUI_AUTO, _min_height = LUI_AUTO, _max_height = LUI_AUTO) {
		if _min_width != LUI_AUTO {
			self._explicit_min_width = _min_width;
		}
		if _min_height != LUI_AUTO {
			self._explicit_min_height = _min_height;
		}
		var _flex_node = self.flex_node;
		var _update_flex = false;
		if _min_width != LUI_AUTO && self.min_width != _min_width {
			self.min_width = _min_width;
			flexpanel_node_style_set_min_width(_flex_node, _min_width, flexpanel_unit.point);
			_update_flex = true;
		}
		if _max_width != LUI_AUTO && self.max_width != _max_width {
			self.max_width = _max_width;
			flexpanel_node_style_set_max_width(_flex_node, _max_width, flexpanel_unit.point);
			_update_flex = true;
		}
		if _min_height != LUI_AUTO && self.min_height != _min_height {
			self.min_height = _min_height;
			flexpanel_node_style_set_min_height(_flex_node, _min_height, flexpanel_unit.point);
			_update_flex = true;
		}
		if _max_height != LUI_AUTO && self.max_height != _max_height {
			self.max_height = _max_height;
			flexpanel_node_style_set_max_height(_flex_node, _max_height, flexpanel_unit.point);
			_update_flex = true;
		}
		if _update_flex {
			self.requestFlexLayout();
		}
		return self;
	}

	///@desc Sets the flexpanel margin as a local style override
	///@arg {real} _margin
	static setMargin = function(_margin) {
		return self.setLocalStyle({margin: _margin});
	}

	///@desc Sets the flexpanel padding as a local style override
	///@arg {real} _padding
	static setPadding = function(_padding) {
		return self.setLocalStyle({padding: _padding});
	}

	///@desc Sets the flexpanel gap as a local style override
	///@arg {real} _gap
	static setGap = function(_gap) {
		return self.setLocalStyle({gap: _gap});
	}

	///@desc Sets the flexpanel border as a local style override
	///@arg {real} _border
	static setBorder = function(_border) {
		return self.setLocalStyle({border: _border});
	}

	///@desc Set flexpanel direction (Default: flexpanel_flex_direction.column)
	///@arg {constant.flexpanel_flex_direction} [_direction]
	static setFlexDirection = function(_direction = flexpanel_flex_direction.column) {
		var _flex_node = self.getContainer().flex_node;
		flexpanel_node_style_set_flex_direction(_flex_node, _direction);
		self.requestFlexLayout();
		return self;
	}

	///@desc Set flexpanel wrap type (Default: flexpanel_wrap.no_wrap)
	///@arg {constant.flexpanel_wrap} [_wrap]
	static setFlexWrap = function(_wrap = flexpanel_wrap.no_wrap) {
		var _flex_node = self.getContainer().flex_node;
		flexpanel_node_style_set_flex_wrap(_flex_node, _wrap);
		self.requestFlexLayout();
		return self;
	}

	///@desc Set flexpanel grow (Default: 1)
	///@arg {real} [_grow]
	static setFlexGrow = function(_grow = 1) {
		var _flex_node = self.flex_node;
		flexpanel_node_style_set_flex_grow(_flex_node, _grow);
		self.requestFlexLayout();
		return self;
	}

	///@desc Set flexpanel shrink type (Default: 1)
	///@arg {real} [_shrink]
	static setFlexShrink = function(_shrink = 1) {
		var _flex_node = self.flex_node;
		flexpanel_node_style_set_flex_shrink(_flex_node, _shrink);
		self.requestFlexLayout();
		return self;
	}

	///@desc Set flexpanel justify content (Default: flexpanel_justify.start)
	///Aligns items along the main axis, controlling horizontal spacing
	///@arg {constant.flexpanel_justify} [_flex_justify]
	static setFlexJustifyContent = function(_flex_justify = flexpanel_justify.start) {
		var _flex_node = self.getContainer().flex_node;
		flexpanel_node_style_set_justify_content(_flex_node, _flex_justify);
		self.requestFlexLayout();
		return self;
	}

	///@desc Set flexpanel align items (Default: flexpanel_align.stretch)
	///Aligns items along the cross axis, affecting vertical alignment
	///@arg {constant.flexpanel_align} [_flex_align]
	static setFlexAlignItems = function(_flex_align = flexpanel_align.stretch) {
		var _flex_node = self.getContainer().flex_node;
		flexpanel_node_style_set_align_items(_flex_node, _flex_align);
		self.requestFlexLayout();
		return self;
	}

	///@desc Set flexpanel align content (Default: flexpanel_justify.start)
	///Defines the spacing between flex lines when wrapping occurs.
	///@arg {constant.flexpanel_justify} [_flex_justify]
	static setFlexAlignContent = function(_flex_justify = flexpanel_justify.start) {
		var _flex_node = self.getContainer().flex_node;
		flexpanel_node_style_set_align_content(_flex_node, _flex_justify);
		self.requestFlexLayout();
		return self;
	}

	///@desc Set flexpanel align self (Default: flexpanel_align.auto)
	///Overrides the container's alignment for this item on the cross axis
	///@arg {constant.flexpanel_align} [_flex_align]
	static setFlexAlignSelf = function(_flex_align = flexpanel_align.auto) {
		var _flex_node = self.flex_node;
		flexpanel_node_style_set_align_self(_flex_node, _flex_align);
		self.requestFlexLayout();
		return self;
	}

	///@desc Centers this element in the free space available on both axes in its Flex parent.
	static alignCenter = function() {
		return self._setSelfAlignment(0, 0);
	}

	///@desc Aligns this element to the left in its Flex parent.
	static alignLeft = function() {
		return self._setSelfAlignment(-1, undefined);
	}

	///@desc Aligns this element to the right in its Flex parent.
	static alignRight = function() {
		return self._setSelfAlignment(1, undefined);
	}

	///@desc Aligns this element to the top in its Flex parent.
	static alignTop = function() {
		return self._setSelfAlignment(undefined, -1);
	}

	///@desc Aligns this element to the bottom in its Flex parent.
	static alignBottom = function() {
		return self._setSelfAlignment(undefined, 1);
	}

	///@desc Set flexpanel display(flex) or not(none) (Default: flexpanel_display.flex)
	///@arg {constant.flexpanel_display} [_flex_display]
	static setFlexDisplay = function(_flex_display = flexpanel_display.flex) {
		var _flex_node = self.flex_node;
		if flexpanel_node_style_get_display(_flex_node) != _flex_display {
			flexpanel_node_style_set_display(_flex_node, _flex_display);
			self.requestFlexLayout();
			self.requestContentUpdate(true);
		}
		return self;
	}

	///@desc Centers the content. Calls setFlexJustifyContent and setFlexAlignItems with centering
	static centerContent = function() {
		self.setFlexJustifyContent(flexpanel_justify.center)
			.setFlexAlignItems(flexpanel_align.center);
		return self;
	}

	// Style

	///@desc Returns the effective style (inherited style + class rules + local overrides).
	/// The result is cached and rebuilt only when the style is marked dirty.
	static getStyle = function() {
		if self._style_dirty {
			self._cached_style = self._buildEffectiveStyle();
			self._style_dirty = false;
		}
		return self._cached_style;
	}

	///@desc Returns the inheritable style without local overrides
	static getMainStyle = function() {
		return self.style;
	}

	///@desc Sets the style for this element and its subtree.
	/// - Plain struct (e.g. { padding: 8 }) is merged as overrides on top of the inherited style.
	///   The overrides are persistent and survive parent theme changes.
	///   Pass undefined as a value to remove a single override, e.g. { padding: undefined }.
	/// - LuiStyle instance replaces the style completely (fully autonomous style).
	/// - undefined resets the own style back to parent inheritance.
	///@arg {Struct|LuiStyle} [_style] Style data or a LuiStyle instance
	static setStyle = function(_style) {
		if is_undefined(_style) {
			// Reset: inherit from the parent again
			self._has_own_style = false;
			self._style_delta = undefined;
			self.style = is_undefined(self.parent) ? undefined : self.parent.getMainStyle();
		} else if instanceof(_style) == "LuiStyle" {
			// Full replacement with a ready-made style instance
			self._style_delta = undefined;
			self.style = _style;
			self._has_own_style = true;
		} else {
			// Partial overrides: accumulate in delta and rebuild on top of the inherited style
			self._style_delta = _luiMergeOverrides(self._style_delta, _style);
			var _base = is_undefined(self.parent) ? undefined : self.parent.getMainStyle();
			if array_length(variable_struct_get_names(self._style_delta)) == 0 {
				// No overrides left: fall back to plain inheritance
				self._style_delta = undefined;
				self._has_own_style = false;
				self.style = _base;
			} else {
				self._has_own_style = true;
				self._rebuildStyleFromInherited(_base);
			}
		}
		self._style_dirty = true;
		self._propagateStyleToChildren();
		self._applyStyles();
		self.requestFlexLayout();
		self.invalidateCache();
		return self;
	}

	///@desc Merges local style overrides for this element only (not inherited by children).
	/// Accepts a full style definition or a partial struct, e.g. { padding: 16 }.
	/// Pass undefined to clear all local overrides.
	/// Pass undefined as a value to remove a single override, e.g. { padding: undefined }.
	///@arg {Struct} [_local_style] Local overrides struct or undefined to clear all
	static setLocalStyle = function(_local_style) {
		if is_undefined(_local_style) {
			// Full reset of the local style
			self.local_style = undefined;
		} else {
			self.local_style = _luiMergeOverrides(self.local_style, _local_style);
		}
		self._style_dirty = true;
		self._applyStyles();
		self.requestFlexLayout();
		self.invalidateCache();
		return self;
	}

	///@desc Invalidates the cached effective style and re-applies styles in this subtree.
	/// Call this after mutating a shared style object in place.
	static invalidateStyle = function() {
		self._style_dirty = true;
		self._applyStyles(true);
		self._propagateStyleToChildren(true);
		self.requestFlexLayout();
		self.invalidateCache();
		return self;
	}

	// Visibility and input

	///@desc Set element visibility (only visibility not flex display)
	static setVisible = function(_visible) {
		if self._allows_visibility_changes {
			if self.visible != _visible {
				// Change visible
				self.visible = _visible;
				// Events show/hide
				if _visible {
					self._dispatchEvent(LUI_EV_SHOW);
				} else {
					self._dispatchEvent(LUI_EV_HIDE);
				}
				// Grid update
				self._updateScreenGrid();
				// Update childs
				for (var i = array_length(self.content) - 1; i >= 0; i--) {
					self.content[i].setVisible(self.visible);
				}
				// Main surface update
				self.invalidateCache();
			}
		}
		return self;
	}

	///@desc Set visible to true and flex display to flex
	static show = function() {
		self.setVisible(true).setFlexDisplay(flexpanel_display.flex);
		return self;
	}

	///@desc Set visible to false and flex display to none
	static hide = function() {
		self.setVisible(false).setFlexDisplay(flexpanel_display.none);
		return self;
	}

	///@desc Enable or disable visibility switching by function setVisible()
	static allowVisibilityChanges = function(_allow = true) {
		self._allows_visibility_changes = _allow;
		return self;
	}

	///@desc Use allowVisibilityChanges() to control whether visibility can change.
	///@deprecated
	static setVisibilitySwitching = function(_allow) {
		return self.allowVisibilityChanges(_allow);
	}

	///@desc Activate an element
	static activate = function() {
		if self.deactivated {
			self.deactivated = false;
			if is_array(self.content) {
				array_foreach(self.content, function(_elm) {
					_elm.activate();
				});
			}
			self.invalidateCache();
		}
		return self;
	}

	///@desc Deactivate an element
	static deactivate = function() {
		if !self.deactivated {
			self.deactivated = true;
			if is_array(self.content) {
				array_foreach(self.content, function(_elm) {
					_elm.deactivate();
				});
			}
			self.invalidateCache();
		}
		return self;
	}

	///@desc setFocus
	static setFocus = function() {
		self.has_focus = true;
		self._dispatchEvent(LUI_EV_FOCUS_SET);
		return self;
	}

	///@desc Remove focus from element
	static removeFocus = function() {
		self.has_focus = false;
		self._dispatchEvent(LUI_EV_FOCUS_REMOVE);
		return self;
	}

	///@desc Overrides automatic keyboard focus detection. Pass undefined to restore automatic detection.
	///@arg {Bool|Undefined} [_focusable] Whether arrow navigation can focus this element
	static setKeyboardFocusable = function(_focusable = true) {
		self._keyboard_focusable = _focusable;
		return self;
	}

	///@desc Binds a key to this element's click action. Omit the key to clear the binding.
	///@arg {Real|Undefined} [_key] GameMaker keyboard key code
	///@return {Struct} This element
	static setShortcut = function(_key = undefined) {
		self._shortcut_key = _key;
		self._syncShortcutRegistration();
		return self;
	}

	///@desc Enables/Disables mouse ignore mode
	static setMouseIgnore = function(_ignore = true) {
		self.ignore_mouse = _ignore;
		return self;
	}

	///@desc Enables/Disables mouse ignore mode for this and all nested elements
	static setMouseIgnoreAll = function(_ignore = true) {
		self.ignore_mouse = _ignore;
		self.ignore_mouse_all = _ignore;
		var _content = self.getContent();
		for (var i = 0, n = array_length(_content); i < n; i++) {
			var _e = _content[i];
			_e.setMouseIgnoreAll(self.ignore_mouse_all);
		}
		return self;
	}

	///@desc Returns true if the mouse is hovered over this element
	static isMouseHovered = function() {
		return self.is_mouse_hovered;
	}

	///@desc Tests the pointer against this visible element's own bounds.
	static isPointerInsideBounds = function() {
		if !self.visible return false;
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		var _element_x = self.x;
		var _element_y = self.y;
		var _on_this = point_in_rectangle(_mouse_x, _mouse_y, _element_x, _element_y, _element_x + self.width - 1, _element_y + self.height - 1);
		return _on_this;
	}

	///@desc Tests this element and all its clipping ancestors against the pointer.
	static isPointerInsideClippedBounds = function() {
		if !self.isPointerInsideBounds() return false;
		var _p = self.parent;
		while (!is_undefined(_p)) {
			if _p._clip_children && !_p.isPointerInsideBounds() return false;
			_p = _p.parent;
		}
		return true;
	}

	///@desc Returns whether this element or one of its descendants is hovered.
	///@deprecated
	static isMouseHoveredChilds = function() {
		if !self.visible return false;
		var _mouse_x = device_mouse_x_to_gui(0);
		var _mouse_y = device_mouse_y_to_gui(0);
		var _on_element = false;
		for (var i = 0, n = array_length(self.content); i < n; ++i) {
			var _element = self.content[i];
			if _element.isMouseHoveredChilds() {
				return true;
			}
		}
		return self.isMouseHovered() ? true : false;
	}

	///@desc Use isPointerInsideBounds() to test this element's bounds.
	///@deprecated
	static isMouseHoveredExc = function() {
		return self.isPointerInsideBounds();
	}

	///@desc Use isPointerInsideClippedBounds() to include clipping ancestors.
	///@deprecated
	static isMouseHoveredParents = function() {
		return self.isPointerInsideClippedBounds();
	}

	///@desc Set popup text to element when mouse on it
	static setTooltip = function(_string) {
		self.tooltip = _string;
		return self;
	}

	// Draw order and cache settings

	///@desc Sets a new depth value for the element and recalculates _z_order_path for itself and its children
	static setDepth = function(_new_z) {
		self.z = _new_z;
		if !is_undefined(self.main_ui) {
			self.main_ui._next_z = max(self.main_ui._next_z, _new_z + 1);
		}
		if !is_undefined(self.parent) {
			self.parent._draw_order_dirty = true;
		}
		self._rebuildDepthArrayRec();
		self.invalidateCache();
		return self;
	}

	///@desc Brings the element to the front by setting a new maximum z value
	static bringToFront = function() {
		if is_undefined(self.main_ui) return self;
		return self.setDepth(self.main_ui._next_z);
	}

	///@desc Set offset region for render content
	///@arg {struct, array} _region struct{left, right, top, bottom} or array [left, right, top, bottom]
	///@deprecated
	static setRenderRegionOffset = function(_region = {left : 0, right : 0, top : 0, bottom : 0}) { //???// it may still be useful
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

	///@desc Set material (see luiMaterial)
	///@arg {Struct} _material
	static setMaterial = function(_material) {
		self.material = _material;
		self.invalidateCache();
		return self;
	}

	///@desc Enables or disables surface caching (flattens children into a single texture)
	///@arg {bool} _enable
	static setCacheAsSurface = function(_enable) {
		if self.cache_as_surface == _enable return self;
		self.cache_as_surface = _enable;
		self._is_cache_dirty = true;
		if !_enable {
			self._cache_active = false;
			self._freeCache();
		}
		self.invalidateCache();
		return self;
	}

	///@desc Extra pixels around the element inside cached surface (for shadows, glow, overflowing children)
	///@arg {real} _padding
	static setCachePadding = function(_padding) {
		self.cache_padding = max(0, _padding);
		self.invalidateCache();
		return self;
	}

	///@desc Marks this element's cache and its ancestor caches for redraw.
	static invalidateCache = function() {
		var _element = self;
		while !is_undefined(_element) {
			_element._is_cache_dirty = true;
			_element = _element.parent;
		}
		return self;
	}

	///@desc Use invalidateCache() after changing rendered content.
	///@deprecated
	static updateMainUiSurface = function() {
		if is_undefined(self.main_ui) return self;
		return self.invalidateCache();
	}

	// Events

	///@desc Add a callback for a specific event
	/// Check "LuiEvents" script for available events
	///@arg {string} _eventType The event type (constants of string e.g., LUI_EV_CREATE, LUI_EV_CLICK)
	///@arg {function} _callback The callback function to execute
	///@return {struct} The element itself for chaining
	static addEvent = function(_eventType, _callback) {
		if is_undefined(self.event_listeners[$ _eventType]) {
			self.event_listeners[$ _eventType] = [];
		}
		array_push(self.event_listeners[$ _eventType], _callback);
		return self;
	}

	///@desc Remove a callback for a specific event //???// It may not be appropriate to unsubscribe from an event with a callback (searching by exact callback is a peculiar solution).
	///@arg {string} _eventType The event type
	///@arg {function} _callback The callback function to remove
	///@return {struct} The element itself for chaining
	static removeEvent = function(_eventType, _callback) {
		if !is_undefined(self.event_listeners[$ _eventType]) {
			var _listeners = self.event_listeners[$ _eventType];
			for (var i = array_length(_listeners) - 1; i >= 0; i--) {
				if _listeners[i] == _callback {
					array_delete(_listeners, i, 1);
				}
			}
		}
		return self;
	}

	// LIFECYCLE

	///@desc Init element variables
	///@ignore
	static _initElement = function() {
		self.auto_x = self.x == LUI_AUTO && self.r == LUI_AUTO;
		self.auto_y = self.y == LUI_AUTO && self.b == LUI_AUTO;
		self.auto_width = is_undefined(self._requested_width) && self.width == LUI_AUTO;
		self.auto_height = is_undefined(self._requested_height) && self.height == LUI_AUTO;
		self._initFlexNode();
		self.is_initialized = true;
	}

	///@ignore
	static _syncShortcutRegistration = function() {
		if is_undefined(self.main_ui) return;
		var _ui = self.main_ui;
		var _index = array_get_index(_ui._shortcut_elements, self);
		if self.is_destroyed || is_undefined(self._shortcut_key) {
			if _index >= 0 {
				array_delete(_ui._shortcut_elements, _index, 1);
			}
		} else if _index < 0 {
			array_push(_ui._shortcut_elements, self);
		}
	}

	///@desc Adds elements from a delayed array
	///@ignore
	static _addDelayedContent = function() {
		var _batches = self.delayed_content;
		self.delayed_content = [];
		for (var i = 0, n = array_length(_batches); i < n; i++) {
			self.addContentDirect(_batches[i]);
		}
	}

	///@desc This function updates all nested elements
	static update = function() {
		if !self._intersects_clip_region || !self.visible || self.deactivated return false;

		// Define the list of items to be processed
		var _elements = self.content;
		var _source_length = array_length(_elements);

		for (var i = _source_length - 1; i >= 0; --i) {
			var _element = _elements[i];

			// Delete destroyed elements
			if _element.is_destroyed {
				array_delete(_elements, i, 1);
				self._draw_order_dirty = true;
				continue;
			}

			// Skip the invisible elements
			if !_element._intersects_clip_region || !_element.visible || self.deactivated continue;

			// Updating the bound variables
			if !is_undefined(_element._value_binding) && _element.get() != variable_instance_get(_element._value_binding.source, _element._value_binding.variable) {
				_element._readBoundValue();
			}

			// Update content if required
			if _element._content_update_pending {
				_element._dispatchEvent(LUI_EV_CONTENT_UPDATE);
				_element._content_update_pending = false;
			}

			// Execute custom step and recursive update
			if is_method(_element.step) {
				_element.step();
			}

			// Call update for nested elements
			_element.update();
		}
	}

	///@desc Destroys self and all nested elements
	self.destroy = function() {
		// Double-Destroy protection
		if self.is_destroyed {
			return;
		}
		// Double-Destroy protection
		self.is_destroyed = true;
		if !is_undefined(self.main_ui) {
			for (var i = 0, n = array_length(self._tags); i < n; i++) {
				self._unindexTag(self._tags[i]);
			}
		}
		self._tags = [];
		self._deleteElementName();
		if !is_undefined(self._shortcut_key) {
			self._syncShortcutRegistration();
		}

		self._freeCache();
		// Destroy all content
		self._destroyAllNestedElements();
		// Release keyboard input before the element's listeners are removed.
		if !is_undefined(self.main_ui) && self == self.main_ui.element_in_focus {
			self.main_ui.element_in_focus = undefined;
			self.removeFocus();
		}
		self._cleanupScreenGrid();
		if !is_undefined(self.parent) {
			self.parent.requestContentUpdate(true);
		}
		self.requestFlexLayout();
		self.invalidateCache();
		// Delete flex_node
		if !is_undefined(self.flex_node) {
			// For the rest of the elements to react to the disappearance of this
			flexpanel_node_style_set_display(self.flex_node, flexpanel_display.none);
			// Delete flex node from memory
			self.flex_node = flexpanel_delete_node(self.flex_node, true);
		}
		// Call destroy event
		self._dispatchEvent(LUI_EV_DESTROY);
		// Clean all arrays and structs
		self.content = -1;
		self._z_order_path = -1;
		// Do not use delete here: _cached_style may reference a shared style object
		self.local_style = undefined;
		self._cached_style = undefined;
		self._applied_style = undefined;
		self._style_delta = undefined;
		delete self.render_region_offset; self.render_region_offset = undefined;
		delete self._visible_bounds; self._visible_bounds = undefined;
		delete self._child_clip_bounds; self._child_clip_bounds = undefined;
		self._draw_children = [];
		delete self.prev_view_region; self.prev_view_region = undefined;
		delete self._value_binding; self._value_binding = undefined;
		delete self.data; self.data = undefined;
		self.event_listeners = {}
		if !is_undefined(self.main_ui) {
			self.main_ui.element_count--;
		}
	}

	///@desc Destroys all nested elements
	///@ignore
	static _destroyAllNestedElements = function() {
		var _pending = self.delayed_content;
		self.delayed_content = [];
		for (var i = 0, n = array_length(_pending); i < n; i++) {
			var _batch = _pending[i];
			for (var j = 0, m = array_length(_batch); j < m; j++) {
				var _child = _batch[j];
				if is_struct(_child) && is_instanceof(_child, LuiBase) && is_undefined(_child.main_ui) {
					_child.destroy();
				}
			}
		}
		while (array_length(self.content) > 0) {
			var _element = array_pop(self.content);
			if !is_undefined(_element) {
				_element.destroy();
			}
		}
	}

	// INTERNALS

	// Event dispatch and registration

	///@ignore
	static _handlePointerWheel = function(_data) {
	}

	///@desc Call events from event listener
	///@ignore
	static _dispatchEvent = function(_eventType, _data = undefined) {
		if !is_undefined(self.event_listeners[$ _eventType]) {
			var _listeners = self.event_listeners[$ _eventType];
			for (var i = 0; i < array_length(_listeners); i++) {
				_listeners[i](self, _data);
			}
		}
	}

	///@ignore
	static _registerElementName = function() {
		if !variable_struct_exists(self.main_ui.element_names, self.name) && self.name != LUI_AUTO_NAME {
			variable_struct_set(self.main_ui.element_names, self.name, self);
		} else {
			if self.name != LUI_AUTO_NAME {
				_luiPrintWarning($"Element name \"{self.name}\" already exists! A new name will be given automatically.");
			}
			if self.name == LUI_AUTO_NAME {
				self.name = "";
			}
			var _new_name = self.name + "_" + string(self.element_id) + "_" + md5_string_utf8(self.name + string(self.element_id));
			variable_struct_set(self.main_ui.element_names, _new_name, self);
			self.name = _new_name;
		}
	}

	///@ignore
	static _deleteElementName = function() {
		if !is_undefined(self.main_ui) && self != self.main_ui {
			if self.main_ui.element_names[$ self.name] == self {
				variable_struct_remove(self.main_ui.element_names, self.name);
			}
		}
	}

	///@ignore
	static _registerTags = function() {
		var _class = instanceof(self);
		if string_copy(_class, 1, 3) == "Lui" {
			var _tag = string_lower(string_delete(_class, 1, 3));
			if !array_contains(self._tags, _tag) {
				array_push(self._tags, _tag);
			}
		}
		for (var i = 0, n = array_length(self._tags); i < n; i++) {
			self._indexTag(self._tags[i]);
		}
	}

	///@ignore
	static _indexTag = function(_tag) {
		var _index = self.main_ui._elements_by_tag;
		var _elements = _index[$ _tag] ?? [];
		array_push(_elements, self);
		_index[$ _tag] = _elements;
	}

	///@ignore
	static _unindexTag = function(_tag) {
		var _index = self.main_ui._elements_by_tag;
		var _elements = _index[$ _tag];
		if is_undefined(_elements) return;
		var _position = array_get_index(_elements, self);
		if _position < 0 return;
		array_delete(_elements, _position, 1);
		if array_length(_elements) == 0 {
			variable_struct_remove(_index, _tag);
		} else {
			_index[$ _tag] = _elements;
		}
	}

	///@ignore
	static _validateConstructorParams = function() {
		if is_undefined(self._debug_param_keys) return;
		var _keys = self._debug_param_keys;
		self._debug_param_keys = undefined;
		var _allowed = _luiGetConstructorKeys(instanceof(self));
		if is_undefined(_allowed) return;
		for (var i = 0, n = array_length(_keys); i < n; i++) {
			var _key = _keys[i];
			if !array_contains(_allowed, _key) {
				_luiPrintWarning($"Unknown constructor parameter \"{_key}\".");
			}
		}
	}

	// Variable binding

	///@desc Update element value from binded variable
	///@ignore
	static _readBoundValue = function() {
		var _source = self._value_binding.source;
		var _variable = self._value_binding.variable;
		if _source != noone && variable_instance_exists(_source, _variable) {
			var _source_value = variable_instance_get(_source, _variable);
			self.set(_source_value);
		} else {
			_luiPrintError($"Binded variable is wrong or no longer available!");
			self._value_binding = undefined;
		}
	}

	///@desc Update binded variable from element value
	///@ignore
	static _writeBoundValue = function() {
		var _source = self._value_binding.source;
		var _variable = self._value_binding.variable;
		if _source != noone && variable_instance_exists(_source, _variable) {
			var _element_value = self.get();
			variable_instance_set(_source, _variable, _element_value);
		} else {
			_luiPrintError($"Binded variable is wrong or no longer available!");
			self._value_binding = undefined;
		}
	}

	// Style inheritance

	///@desc Builds the effective style: style <- class rules <- local_style
	///@ignore
	static _buildEffectiveStyle = function() {
		var _base = self.style;
		var _has_local = is_struct(self.local_style) && array_length(variable_struct_get_names(self.local_style)) > 0;
		var _has_class_rules = is_struct(_base) && variable_struct_exists(_base._class_overrides, instanceof(self));
		// Fast path: nothing to overlay. If no base style exists, return a default style
		// so getStyle() always returns a valid LuiStyle instance (no undefined checks needed).
		if !_has_local && !_has_class_rules {
			return _base ?? new LuiStyle({});
		}
		// No base style: build from local overrides only
		if (is_undefined(_base)) return new LuiStyle(self.local_style ?? {});
		// Merge order: base <- class rules <- local overrides
		var _raw = _luiStyleToRawStruct(_base);
		if _has_class_rules {
			_raw = struct_merge(_raw, _base._class_overrides[$ instanceof(self)]);
		}
		if _has_local {
			_raw = struct_merge(_raw, self.local_style);
		}
		return new LuiStyle(_raw);
	}

	///@desc Passes the inheritable style down to children. Skips elements with a fully
	/// autonomous style; delta-based styles are rebuilt on top of the new inherited style.
	///@ignore
	static _propagateStyleToChildren = function(_force_notify = false) {
		if self.is_destroyed return self;
		// Composite widgets can redirect getContent to an inner container.
		var _content = self.content;
		for (var i = array_length(_content) - 1; i >= 0; --i) {
			var _child = _content[i];
			if _child.is_destroyed continue;
			if !_child._has_own_style || is_struct(_child._style_delta) {
				_child._applyInheritedStyle(self.style, _force_notify);
				if self.is_destroyed return self;
			}
		}
		return self;
	}

	///@desc Applies a style inherited from the parent. Called by the parent during propagation.
	///@ignore
	static _applyInheritedStyle = function(_style, _force_notify = false) {
		self._rebuildStyleFromInherited(_style);
		self._applyStyles(_force_notify);
		self.invalidateCache();
		self._propagateStyleToChildren();
		return self;
	}

	///@desc Rebuilds own style from the inherited style, applying delta overrides on top.
	/// Without delta, the inherited style is used as-is (shared reference, no copy).
	///@arg {Struct} _inherited_style Style inherited from the parent
	///@ignore
	static _rebuildStyleFromInherited = function(_inherited_style) {
		if is_struct(self._style_delta) {
			var _raw = is_undefined(_inherited_style) ? {} : _luiStyleToRawStruct(_inherited_style);
			self.style = new LuiStyle(struct_merge(_raw, self._style_delta));
		} else {
			self.style = _inherited_style;
		}
		self._style_dirty = true;
		return self;
	}

	///@desc Applies the effective style to the flex node. Class rules and local overrides
	/// are already baked into the effective style by _buildEffectiveStyle().
	///@ignore
	static _applyStyles = function(_force_notify = false) {
		if self.is_destroyed return;
		var _style = self.getStyle();
		if is_undefined(_style) return;
		var _container_node = self.getContainer().flex_node;
		flexpanel_node_style_set_margin(_container_node, flexpanel_edge.all_edges, _style.margin);
		flexpanel_node_style_set_padding(_container_node, flexpanel_edge.all_edges, _style.padding);
		flexpanel_node_style_set_gap(_container_node, flexpanel_gutter.all_gutters, _style.gap);
		flexpanel_node_style_set_border(_container_node, flexpanel_edge.all_edges, _style.border);
		self._applySelfAlignment(_style.margin);
		if !is_undefined(self.parent) {
			self._applyStyleMinSize(_style);
		}

		var _previous = self._applied_style;
		self._applied_style = _style;
		if !self.is_adding && !is_undefined(_previous) && (_force_notify || _previous != _style) {
			self._dispatchEvent(LUI_EV_STYLE_UPDATE, _style);
		}
	}

	///@ignore
	static _applyStyleMinSize = function(_style) {
		var _min_width = self._explicit_min_width;
		var _min_height = self._explicit_min_height;
		if _min_width == LUI_AUTO {
			_min_width = is_real(self._requested_width) ? min(self._requested_width, _style.min_width) : _style.min_width;
		}
		if _min_height == LUI_AUTO {
			_min_height = is_real(self._requested_height) ? min(self._requested_height, _style.min_height) : _style.min_height;
		}
		if is_undefined(self._requested_height) {
			_min_height = max(_min_height, self._content_min_height);
		}
		self.min_width = _min_width;
		self.min_height = _min_height;
		flexpanel_node_style_set_min_width(self.flex_node, _min_width, flexpanel_unit.point);
		flexpanel_node_style_set_min_height(self.flex_node, _min_height, flexpanel_unit.point);
	}

	// Flex layout

	///@desc Initialize flex node
	///@ignore
	static _initFlexNode = function() {
		if self.x != LUI_AUTO {
			self._setPositionEdge(flexpanel_edge.left, "x", self.x);
		}
		if self.r != LUI_AUTO {
			self._setPositionEdge(flexpanel_edge.right, "r", self.r);
		}
		if self.y != LUI_AUTO {
			self._setPositionEdge(flexpanel_edge.top, "y", self.y);
		}
		if self.b != LUI_AUTO {
			self._setPositionEdge(flexpanel_edge.bottom, "b", self.b);
		}
		if self._position_type == flexpanel_position_type.absolute {
			self._applyAbsoluteDefaults();
		}

		// Width
		if is_undefined(self._requested_width) {
			if self.auto_width {
				flexpanel_node_style_set_width(self.flex_node, 100, flexpanel_unit.percent);
				flexpanel_node_style_set_flex_shrink(self.flex_node, 1);
			} else {
				self._setDimension(true, self.width);
			}
		}

		// Height
		if is_undefined(self._requested_height) && !self.auto_height {
			self._setDimension(false, self.height);
		}
	}

	///@ignore
	static _setDimension = function(_horizontal, _size) {
		var _previous = _horizontal ? self._requested_width : self._requested_height;
		if _size == LUI_AUTO || _size == _previous return false;

		var _unit = flexpanel_unit.point;
		var _value = _size;
		if is_string(_size) {
			var _length = string_length(_size);
			var _number = string_copy(_size, 1, max(0, _length - 1));
			var _digits = string_digits(_number);
			if string_char_at(_size, _length) != "%" || _digits == ""
				|| string_replace_all(_number, ".", "") != _digits || string_count(".", _number) > 1 {
				_luiPrintWarning("Expected a size in pixels or a percentage string such as \"50%\".");
				return false;
			}
			_unit = flexpanel_unit.percent;
			_value = real(_number);
		} else if !is_real(_size) || _size < 0 {
			_luiPrintWarning("Expected a non-negative pixel size or percentage.");
			return false;
		}

		if _horizontal {
			self._requested_width = _size;
			flexpanel_node_style_set_width(self.flex_node, _value, _unit);
			if !self.is_initialized {
				self.width = _unit == flexpanel_unit.point ? _value : LUI_AUTO;
			}
		} else {
			self._requested_height = _size;
			flexpanel_node_style_set_height(self.flex_node, _value, _unit);
			if !self.is_initialized {
				self.height = _unit == flexpanel_unit.point ? _value : LUI_AUTO;
			}
		}
		return true;
	}

	///@ignore
	static _setSelfAlignment = function(_x, _y) {
		if !is_undefined(_x) {
			self._align_x = _x;
		}
		if !is_undefined(_y) {
			self._align_y = _y;
		}
		var _style = self.getStyle();
		self._applySelfAlignment(is_undefined(_style) ? 0 : _style.margin);
		self.requestFlexLayout();
		return self;
	}

	///@ignore
	static _applySelfAlignment = function(_margin) {
		if !is_undefined(self._align_x) {
			self._setAlignMargin(flexpanel_edge.left, self._align_x >= 0, _margin);
			self._setAlignMargin(flexpanel_edge.right, self._align_x <= 0, _margin);
		}
		if !is_undefined(self._align_y) {
			self._setAlignMargin(flexpanel_edge.top, self._align_y >= 0, _margin);
			self._setAlignMargin(flexpanel_edge.bottom, self._align_y <= 0, _margin);
		}
	}

	///@ignore
	static _setAlignMargin = function(_edge, _auto, _margin) {
		flexpanel_node_style_set_margin(self.flex_node, _edge, _auto ? 0 : _margin,
			_auto ? flexpanel_unit.auto : flexpanel_unit.point);
	}

	///@ignore
	static _setPositionEdge = function(_edge, _key, _value) {
		if self._position_edges[$ _key] == _value return false;
		self._position_edges[$ _key] = _value;
		flexpanel_node_style_set_position(self.flex_node, _edge, _value, flexpanel_unit.point);
		// Keep the requested value available until the first layout.
		if !self.is_initialized {
			self[$ _key] = _value;
		}
		if _edge == flexpanel_edge.left || _edge == flexpanel_edge.right {
			self.auto_x = false;
		} else {
			self.auto_y = false;
		}
		return true;
	}

	///@ignore
	static _applyAbsoluteDefaults = function() {
		if self.auto_x {
			self._setPositionEdge(flexpanel_edge.left, "x", 0);
		}
		if self.auto_y {
			self._setPositionEdge(flexpanel_edge.top, "y", 0);
		}
	}

	///@ignore
	static _moveAbsoluteInViewport = function(_left, _top, _width, _height, _target_x, _target_y) {
		var _ui = self.main_ui;
		if _ui.width <= 0 || _ui.height <= 0 || _width <= 0 || _height <= 0 return;
		var _max_x = _ui.width - _width;
		var _x = self._viewport_align_right && _max_x < 0 ? _max_x : clamp(_target_x, 0, max(0, _max_x));
		var _dx = _x - _left;
		var _dy = clamp(_target_y, 0, max(0, _ui.height - _height)) - _top;
		var _edges = self._position_edges;
		var _changed = false;
		if abs(_dx) >= 0.5 {
			if !is_undefined(_edges.x) {
				_changed = self._setPositionEdge(flexpanel_edge.left, "x", _edges.x + _dx) || _changed;
			}
			if !is_undefined(_edges.r) {
				_changed = self._setPositionEdge(flexpanel_edge.right, "r", _edges.r - _dx) || _changed;
			}
		}
		if abs(_dy) >= 0.5 {
			if !is_undefined(_edges.y) {
				_changed = self._setPositionEdge(flexpanel_edge.top, "y", _edges.y + _dy) || _changed;
			}
			if !is_undefined(_edges.b) {
				_changed = self._setPositionEdge(flexpanel_edge.bottom, "b", _edges.b - _dy) || _changed;
			}
		}
		if _changed {
			self.requestFlexLayout();
		}
	}

	///@desc Requests a Flex layout pass for the UI.
	///@return {Struct} This element
	static requestFlexLayout = function() {
		if !is_undefined(self.main_ui) {
			self.main_ui._flex_layout_dirty = true;
		}
		return self;
	}

	///@desc Use requestFlexLayout() to request a layout pass.
	///@deprecated
	///@arg {Bool} [_update_parent] Legacy argument retained for compatibility
	static updateMainUiFlex = function(_update_parent = false) {
		return self.requestFlexLayout();
	}

	///@desc Calculate all sizes and positions of elements
	///@ignore
	static _calculateLayout = function() {
		if !is_undefined(self.main_ui) {
			flexpanel_calculate_layout(self.main_ui.flex_node, self.main_ui.width, self.main_ui.height, flexpanel_direction.LTR);
			self.main_ui._layout_revision++;
			return true;
		}
		return false;
	}

	///@desc Update position, size and z depth for specified flex node
	///@ignore
	static _applyLayoutGeometry = function(_scroll_only = false, _offset_x = undefined, _offset_y = 0) {
		if is_undefined(self.flex_node) return;
		if is_undefined(_offset_x) {
			_offset_x = 0;
			var _ancestor = self.parent;
			while !is_undefined(_ancestor) {
				if !is_undefined(_ancestor._scroll_owner) {
					var _ancestor_offset = _ancestor._scroll_owner._getLayoutOffset();
					_offset_x += _ancestor_offset.x;
					_offset_y += _ancestor_offset.y;
				}
				_ancestor = _ancestor.parent;
			}
		}
		if !is_undefined(self._scroll_owner) {
			var _offset = self._scroll_owner._getLayoutOffset();
			_offset_x += _offset.x;
			_offset_y += _offset.y;
		}
		var _scroll_owner = self._scroll_owner;
		if !_scroll_only || is_undefined(self._flex_bounds)
			|| (!is_undefined(_scroll_owner) && _scroll_owner._needsScrollBoundsRefresh()) {
			self._flex_bounds = flexpanel_node_layout_get_position(self.flex_node, false);
		}
		var _pos = self._flex_bounds;
		var _left = _pos.left + _offset_x;
		var _top = _pos.top + _offset_y;
		if !_scroll_only && self.visible && self._keep_in_viewport && self._position_type == flexpanel_position_type.absolute
			&& self._viewport_clamp_revision != self.main_ui._layout_revision {
			self._viewport_clamp_revision = self.main_ui._layout_revision;
			self._moveAbsoluteInViewport(_left, _top, _pos.width, _pos.height, _left, _top);
		}
		if is_method(self._overlay_bounds) {
			_pos = self._overlay_bounds();
			_left = _pos.left;
			_top = _pos.top;
		}

		// Check position change
		var _position_changed = (self.x != _left || self.y != _top);
		// Check size change
		var _size_changed = (self.width != _pos.width || self.height != _pos.height);

		self.x = _left;
		self.y = _top;
		self.width = _pos.width;
		self.height = _pos.height;
		if self.start_x == -1 {
			self.start_x = self.x;
		}
		if self.start_y == -1 {
			self.start_y = self.y;
		}

		var _was_visible = self._intersects_clip_region;
		self._updateViewRegion();

		if _was_visible || self._intersects_clip_region {
			self._updateScreenGrid();
		}

		// On position change
		if _position_changed {
			self._dispatchEvent(LUI_EV_POSITION_UPDATE);
			if _scroll_only {
				self._is_cache_dirty = true;
			} else {
				self.invalidateCache();
			}
			self.prev_x = self.x;
			self.prev_y = self.y;
		}

		// On size change
		if _size_changed {
			self._dispatchEvent(LUI_EV_SIZE_UPDATE);
			self.invalidateCache();
			self.prev_w = self.width;
			self.prev_h = self.height;
		}

		// Update previous view region
		self.prev_view_region.x1 = self._visible_bounds.x1;
		self.prev_view_region.x2 = self._visible_bounds.x2;
		self.prev_view_region.y1 = self._visible_bounds.y1;
		self.prev_view_region.y2 = self._visible_bounds.y2;

		if !self._intersects_clip_region {
			if !_scroll_only {
				self._child_bounds_stale = true;
			}
			for (var i = 0, n = array_length(self.content); i < n; i++) {
				self.content[i]._propagateVisibleRegionState();
			}
			return;
		}

		var _reuse_children = _scroll_only && !self._child_bounds_stale;
		self._child_bounds_stale = false;
		if !is_undefined(_scroll_owner) {
			_scroll_owner._updateScrollChildren(_reuse_children, _offset_x, _offset_y);
		} else {
			self._applyChildLayoutGeometry(_reuse_children, _offset_x, _offset_y);
		}
	}

	///@ignore
	static _applyChildLayoutGeometry = function(_reuse_children, _offset_x, _offset_y) {
		for (var i = 0, n = array_length(self.content); i < n; i++) {
			self.content[i]._applyLayoutGeometry(_reuse_children, _offset_x, _offset_y);
		}
	}

	// Visible regions and screen grid

	///@ignore
	static _getClipInsets = function() {
		return self._getStyleClipInsets(self.getStyle());
	}

	///@ignore
	static _getStyleClipInsets = function(_style) {
		return is_undefined(_style) ? self.render_region_offset : _style.render_region_offset;
	}

	///@ignore
	static _updateViewRegion = function() {

		// Prevent this element from being updated if it has just been added
		if is_undefined(self._flex_bounds) return false;

		self._visible_bounds.x1 = self.x;
		self._visible_bounds.y1 = self.y;
		self._visible_bounds.x2 = self.x + self.width;
		self._visible_bounds.y2 = self.y + self.height;

		var _cr = self._child_clip_bounds;

		// Root
		if self.parent == undefined {
			self._intersects_clip_region = true;
			_cr.x1 = self._visible_bounds.x1; _cr.y1 = self._visible_bounds.y1;
			_cr.x2 = self._visible_bounds.x2; _cr.y2 = self._visible_bounds.y2;
			return;
		}

		// Crop to the region the parent allows for its children
		var _pr = self.parent._child_clip_bounds;
		self._visible_bounds.x1 = max(_pr.x1, self._visible_bounds.x1);
		self._visible_bounds.y1 = max(_pr.y1, self._visible_bounds.y1);
		self._visible_bounds.x2 = min(_pr.x2, self._visible_bounds.x2);
		self._visible_bounds.y2 = min(_pr.y2, self._visible_bounds.y2);

		self._intersects_clip_region = (self._visible_bounds.x2 - self._visible_bounds.x1 > 0)
								 && (self._visible_bounds.y2 - self._visible_bounds.y1 > 0);

		// Region for own children
		if self._clip_children {
			var _o = self._getClipInsets();
			_cr.x1 = max(_pr.x1, self.x + _o.left);
			_cr.y1 = max(_pr.y1, self.y + _o.top);
			_cr.x2 = min(_pr.x2, self.x + self.width - _o.right);
			_cr.y2 = min(_pr.y2, self.y + self.height - _o.bottom);
		} else {
			_cr.x1 = _pr.x1; _cr.y1 = _pr.y1; _cr.x2 = _pr.x2; _cr.y2 = _pr.y2;
		}
	}

	///@desc Recursively forces an invisible state onto itself and all descendants
	///@ignore
	static _propagateVisibleRegionState = function() {
		if self.is_destroyed || !self._intersects_clip_region return;

		self._intersects_clip_region = false;

		self._updateScreenGrid();

		for (var i = 0, n = array_length(self.content); i < n; i++) {
			self.content[i]._propagateVisibleRegionState();
		}
	}

	///@desc Update element in system ui grid
	///@ignore
	static _updateScreenGrid = function() {
		self._deleteFromScreenGrid();
		self._addToScreenGrid();
	}

	///@desc Add element in system ui grid
	///@ignore
	static _addToScreenGrid = function() {
		if !self._intersects_clip_region || !self.visible {
			return;
		}

		var _grid = self.main_ui._screen_grid;
		var _cols = array_length(_grid);

		// Cells that the element intersects, restricted to the existing grid
		var _x_start = max(0, floor(self._visible_bounds.x1 / LUI_GRID_SIZE));
		var _y_start = max(0, floor(self._visible_bounds.y1 / LUI_GRID_SIZE));
		var _x_end = min(_cols - 1, floor(self._visible_bounds.x2 / LUI_GRID_SIZE));
		var _y_end = floor(self._visible_bounds.y2 / LUI_GRID_SIZE);

		for (var _x = _x_start; _x <= _x_end; ++_x) {
			var _col = _grid[_x];
			var _y_last = min(array_length(_col) - 1, _y_end);
			for (var _y = _y_start; _y <= _y_last; ++_y) {
				var _cell = _col[_y];
				array_push(_cell, self);
				array_push(self._screen_grid_cell_ids, _x * LUI_GRID_STRIDE + _y);
			}
		}
	};

	///@desc Delete element from system ui grid
	///@ignore
	static _deleteFromScreenGrid = function() {
		if is_undefined(self.main_ui) || !is_array(self.main_ui._screen_grid) {
			self._screen_grid_cell_ids = [];
			return;
		}
		var _grid = self.main_ui._screen_grid;
		for (var i = 0, n = array_length(self._screen_grid_cell_ids); i < n; i++) {
			var _loc = self._screen_grid_cell_ids[i];
			var _cx = _loc div LUI_GRID_STRIDE;
			var _cy = _loc mod LUI_GRID_STRIDE;
			if _cx < array_length(_grid) && _cy < array_length(_grid[_cx]) {
				var _cell = _grid[_cx][_cy];
				var _index = array_get_index(_cell, self);
				if _index != -1 {
					var _last = array_length(_cell) - 1;
					_cell[_index] = _cell[_last];
					array_pop(_cell);
				}
			}
		}
		self._screen_grid_cell_ids = [];
	}

	///@desc Delete element from grid and clean up array
	///@ignore
	static _cleanupScreenGrid = function() {
		self._deleteFromScreenGrid();
		self._screen_grid_cell_ids = -1;
	}

	// Draw order and transforms

	///@desc Compare two depth arrays
	///@ignore
	function _compareDepthArrays(a, b) {
		var _len_a = array_length(a);
		var _len_b = array_length(b);
		var _min_len = min(_len_a, _len_b);

		for (var i = 0; i < _min_len; i++) {
			if a[i] > b[i] return 1;
			if a[i] < b[i] return -1;
		}

		if _len_a > _len_b return 1;
		if _len_a < _len_b return -1;
		return 0;
	}

	///@desc Recalculates _z_order_path for the element and all its children
	///@ignore
	static _recalculateDepthArray = function() {
		self._rebuildDepthArrayRec();
		self.invalidateCache();
		return self;
	}

	///@ignore
	static _rebuildDepthArrayRec = function() {
		if self.parent != undefined {
			self._z_order_path = array_concat(self.parent._z_order_path, [self.z]);
		} else {
			self._z_order_path = [self.z];
		}
		if !is_array(self.content) return;
		for (var i = 0, n = array_length(self.content); i < n; i++) {
			self.content[i]._rebuildDepthArrayRec();
		}
	}

	///@desc Children sorted by z (rebuilt only when order changed)
	///@ignore
	static _getDrawChildren = function() {
		var _n = array_length(self.content);
		if self._draw_order_dirty || array_length(self._draw_children) != _n {
			var _arr = array_create(_n);
			array_copy(_arr, 0, self.content, 0, _n);
			array_sort(_arr, function(a, b) { return a.z - b.z; });
			self._draw_children = _arr;
			self._draw_order_dirty = false;
		}
		return self._draw_children;
	}

	///@desc True if element has non-identity visual transform
	///@ignore
	static _hasVisualTransform = function() {
		return self.visual_x != 0 || self.visual_y != 0 || self.visual_angle != 0
			|| self.visual_scale_x != 1 || self.visual_scale_y != 1;
	}

	///@desc Builds the visual transformation matrix for rendering relative to pivot
	///@ignore
	static _buildVisualMatrix = function() {
		// Absolute pivot point on the screen
		var _abs_pivot_x = self.x + self.width * self.pivot_x;
		var _abs_pivot_y = self.y + self.height * self.pivot_y;

		// Move pivot to origin
		var _m1 = matrix_build(-_abs_pivot_x, -_abs_pivot_y, 0, 0, 0, 0, 1, 1, 1);

		// Apply scale and rotation at origin
		var _m2 = matrix_build(0, 0, 0, 0, 0, self.visual_angle, self.visual_scale_x, self.visual_scale_y, 1);

		// Move back to pivot + visual offset
		var _m3 = matrix_build(_abs_pivot_x + self.visual_x, _abs_pivot_y + self.visual_y, 0, 0, 0, 0, 1, 1, 1);

		// FIXED: Reversed order for GameMaker's row-vector convention
		// Application order: _m1 (to origin) -> _m2 (scale/rotate) -> _m3 (back)
		return matrix_multiply(matrix_multiply(_m1, _m2), _m3);
	}

	// Cache invalidation

	///@desc Only visual transform/alpha of this element changed: its own cache stays valid, ancestors must be rebaked
	static _invalidateAncestorCaches = function() {
		if is_undefined(self.main_ui) return self;
		var _n = self.parent;
		while (!is_undefined(_n)) {
			_n._is_cache_dirty = true;
			_n = _n.parent;
		}
		return self;
	}

	///@ignore
	static _freeCache = function() {
		if surface_exists(self._cached_surface) {
			surface_free(self._cached_surface);
		}
		self._cached_surface = -1;
		self._is_cache_dirty = true;
	}

	// TEXT DRAWING

	///@desc Draw text fit to width (the truncated string is memoized)
	///@ignore
	static _drawTruncatedText = function(_x, _y, _string, _width = infinity) {
		var _font = draw_get_font();
		if self._tc_string != _string || self._tc_width != _width || self._tc_font != _font {
			self._tc_result = self._truncateTextToFitWidth(_string, _width);
			self._tc_string = _string;
			self._tc_width = _width;
			self._tc_font = _font;
		}
		draw_text(_x, _y, self._tc_result);
	};

	///@desc Returns text fit to width
	///@return {string}
	///@ignore
	static _truncateTextToFitWidth = function(_string, _width = infinity) {
		// Calculate initial text width
		var _str_to_draw = _string;
		var _str_width = string_width(_str_to_draw);

		// Check if the text needs to be truncated
		if _str_width > _width {
			// Calculate the width of "..." once, to use in our calculations
			var _ellipsis = "...";
			var _ellipsis_width = string_width(_ellipsis);

			// Calculate the width available for the main part of the string
			var _available_width = _width - _ellipsis_width;

			// Initialize binary search bounds
			var _low = 1;
			var _high = string_length(_string);
			var _mid;

			// Perform binary search to find the cutoff point
			while (_low < _high) {
				_mid = floor((_low + _high) / 2);
				_str_to_draw = string_copy(_string, 1, _mid);
				_str_width = string_width(_str_to_draw);

				if _str_width < _available_width {
					_low = _mid + 1;
				} else {
					_high = _mid;
				}
			}

			// The final string should be within the bounds
			_str_to_draw = string_copy(_string, 1, _high - 1) + _ellipsis;
		}

		// Return the final text
		return _str_to_draw;
	};
}
