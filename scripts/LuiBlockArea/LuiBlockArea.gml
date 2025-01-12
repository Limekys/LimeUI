///@desc Black transparent area. Use to darken an area or the whole screen, e.g. for a pop-up message.
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
function LuiBlockArea(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = "LuiBlockArea") : LuiBase() constructor {
	
	self.name = name;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	initElement();
	
	self.color = c_black;
	self.alpha = 0.5;
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		draw_set_alpha(self.alpha);
		draw_set_color(self.color);
		draw_rectangle(0, 0, self.width, self.height, false);
	}
	
	self.setColor = function(_color) {
		self.color = _color;
		return self;
	}
	
	self.setAlpha = function(_alpha) {
		self.alpha = _alpha;
		return self;
	}
}