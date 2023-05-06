///@arg {Any} x
///@arg {Any} y
///@arg {Any} width
///@arg {Any} height
///@arg {String} name
function LuiContainer(x, y, width, height, name = "LuiContainer") : LuiBase() constructor {
	self.name = name;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height ?? self.min_height;
	
	return self;
}