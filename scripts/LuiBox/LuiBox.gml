///@desc Colored and may be transparent rectangle area. Use to colored an area or the whole screen, e.g. for a pop-up message. Now used in luiShowMessage
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String,real} name
function LuiBox(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = LUI_AUTO) : LuiColumn(x, y, width, height, name) constructor {
	
	self.ignore_mouse = false;
	self.color = c_black;
	self.alpha = 0.5;
	
	self.draw = function() {
		draw_set_alpha(self.alpha);
		draw_set_color(self.color);
		draw_rectangle(self.x, self.y, self.x + self.width, self.y + self.height, false);
	}
	
	///@desc Set color for block area (default is c_black)
	static setColor = function(_color) {
		self.color = _color;
		return self;
	}
	
	///@desc Set alpha for block area (default is 0.5)
	static setAlpha = function(_alpha) {
		self.alpha = _alpha;
		return self;
	}
}