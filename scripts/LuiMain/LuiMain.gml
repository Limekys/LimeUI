function LuiMain() : LuiBase() constructor {
	
	//Init main variables
	self.width = display_get_gui_width();
	self.height = display_get_gui_height();
	self.ui_screen_surface = -1;
	self.update_ui_screen_surface = true;
	self.pre_draw_list = [];
	self.element_names = {};
	
	//Init screen grid
	self._screen_grid = {};
	for (var _x = 0, _width = ceil(display_get_gui_width() / LUI_GRID_SIZE); _x <= _width; ++_x) {
		for (var _y = 0, _height = ceil(display_get_gui_height() / LUI_GRID_SIZE); _y <= _height; ++_y) {
			var _key = string(_x) + "_" + string(_y);
			self._screen_grid[$ _key] = array_create(0);
		}
	}
	
	//Cleanup
	self.cleanUp = function() {
		self.pre_draw_list = -1;
		if surface_exists(self.ui_screen_surface) {
			surface_free(self.ui_screen_surface);
		}
		//delete self._screen_grid;
		//delete self.element_names;
	}
	
	///@desc Get element by name
	///@return {Struct}
	static getElement = function(_name) {
		if variable_struct_exists(self.element_names, _name) {
			return variable_struct_get(self.element_names, _name);
		} else {
			print($"ERROR: Can't find element {_name}!");
			return -1;
		}
	}
}