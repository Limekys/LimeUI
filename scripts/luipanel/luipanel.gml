///@arg {Any} x
///@arg {Any} y
///@arg {Any} width
///@arg {Any} height
///@arg {String} name
function LuiPanel(x, y, width = 256, height = 256, name = "LuiPanel") : LuiBase() constructor {
	self.name = name;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	
	self.draw = function(x = self.x, y = self.y) {
		if self.style.sprite_panel != undefined draw_sprite_stretched_ext(self.style.sprite_panel, 0, x, y, width, height, self.style.color_main, 1);
		if self.style.sprite_panel_border != undefined draw_sprite_stretched_ext(self.style.sprite_panel_border, 0, x, y, width, height, self.style.color_border, 1);
	}
	
	return self;
}