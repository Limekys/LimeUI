function LuiMain() : LuiBase() constructor {
	
	//Init main variables
	self.width = display_get_gui_width();
	self.height = display_get_gui_height();
	self.ui_screen_surface = -1;
	self.update_ui_screen_surface = true;
	self.main_ui_pre_draw_list = [];
	
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
		self.main_ui_pre_draw_list = -1;
		if surface_exists(self.ui_screen_surface) {
			surface_free(self.ui_screen_surface);
		}
		delete self._screen_grid;
	}
	
	//Return self
	return self;
}