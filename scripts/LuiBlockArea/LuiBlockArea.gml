///@arg {Any} x
///@arg {Any} y
///@arg {Any} width
///@arg {Any} height
///@arg {String} name
function LuiBlockArea(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = "LuiBlockArea") : LuiBase() constructor {
	
	self.name = name;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	init_element();
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		draw_set_alpha(0.5);
		draw_set_color(c_black);
		draw_rectangle(0, 0, self.width, self.height, false);
	}
	
	return self;
}