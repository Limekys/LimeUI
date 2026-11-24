///@desc Colored and may be transparent rectangle area.
/// Available parameters:
/// color
/// alpha
///@arg {Struct} [_params] Struct with parameters
function LuiBox(_params = {}) : LuiBase(_params) constructor {
	// STATE

	self.color = _params[$ "color"] ?? c_black;
	self.alpha = _params[$ "alpha"] ?? 0.5;
	
	// PUBLIC API

	///@desc Set color for block area (default is c_black)
	///@arg {any} _color
	static setColor = function(_color) {
		self.color = _color;
		return self;
	}
	
	///@desc Set alpha for block area (default is 0.5)
	///@arg {real} _alpha
	static setAlpha = function(_alpha) {
		self.alpha = _alpha;
		return self;
	}

	// DRAW

	self.draw = function() {
		var _alpha = draw_get_alpha();
		draw_set_alpha(self.alpha * _alpha);
		draw_set_color(self.color);
		draw_rectangle(self.x, self.y, self.x + self.width, self.y + self.height, false);
		draw_set_alpha(_alpha);
	}
}