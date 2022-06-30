function LuiScrollPanel(x, y, width = 256, height = 256, name = "LuiScrollPanel") : LuiBase() constructor {
	self.name = name;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	
	self.panel_surface = -1;
	self.scroll_offset_y = 0;
	self.scroll_target_offset_y = 0;
	self.surface_offset = {
		left : 0,
		right : 0,
		top : 1,
		bottom : 3
	};
	
	///@func set_surface_offset(array:[left,right,top,bottom])
	static set_surface_offset = function(array) {
		self.surface_offset = {
			left : array[0],
			right : array[1],
			top : array[2],
			bottom : array[3]
		};
		return self;
	}
	
	self.render = function(base_x = 0, base_y = 0) {
		//Create surface
		if !surface_exists(self.panel_surface) {
			self.panel_surface = surface_create(self.width, self.height - self.surface_offset.top - self.surface_offset.bottom);
		}
		
		//Draw on surface
		surface_set_target(self.panel_surface);
		draw_clear_alpha(c_white, 0);
			
		if is_array(self.contents)
		for (var i = 0, n = array_length(self.contents); i < n; i++) {
			var _element = self.contents[i];
			_element.update(base_x + self.pos_x, base_y + self.pos_y + self.scroll_offset_y + self.surface_offset.top);
			_element.step();
			_element.draw(_element.pos_x, _element.pos_y + self.scroll_offset_y);
			_element.render(self.x, self.y);
			if global.LUI_DEBUG_MODE _element.render_debug();
		}
		
		surface_reset_target();
	}
	
	self.draw = function(x = self.x, y = self.y) {
		//Base
		if LUI_SPRITE_PANEL != undefined draw_sprite_stretched_ext(LUI_SPRITE_PANEL, 0, x, y, self.width, self.height, self.blend_color, 1);
		
		//Surface
		if surface_exists(self.panel_surface)
		draw_surface(self.panel_surface, x, y + self.surface_offset.top);
		
		//Border
		if LUI_SPRITE_PANEL_BORDER != undefined draw_sprite_stretched_ext(LUI_SPRITE_PANEL_BORDER, 0, x, y, self.width, self.height, LUI_COLOR_BORDER, 1);
	}
	
	self.step = function() {
		if mouse_hover() {
			var _wheel = mouse_wheel_up() - mouse_wheel_down();
			if _wheel != 0 {
				self.scroll_target_offset_y += LUI_SCROLL_SIZE * _wheel;
				var _contents_height = 0;
				if array_length(self.contents) > 0
				for (var i = 0; i < array_length(self.contents); ++i) {
				    var _element = self.contents[i];
					_contents_height += _element.height + LUI_PADDING;
				}
				self.scroll_target_offset_y = clamp(self.scroll_target_offset_y, -_contents_height + self.height - LUI_PADDING, 0);
			}
		}
		self.scroll_offset_y = ReachTween(self.scroll_offset_y, self.scroll_target_offset_y, 2);
	}
	
	self.destroy_main = method(self, self.destroy);
	self.destroy = function() {
		if surface_exists(self.panel_surface) surface_free(self.panel_surface);
		self.destroy_main();
	}
}