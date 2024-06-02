///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
function LuiPanel(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = "LuiPanel") : LuiBase() constructor {
	
	self.name = name;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	init_element();
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		if !is_undefined(self.style.sprite_panel)
		draw_sprite_stretched_ext(self.style.sprite_panel, 0, draw_x, draw_y, width, height, self.style.color_main, 1);
		if !is_undefined(self.style.sprite_panel_border)
		draw_sprite_stretched_ext(self.style.sprite_panel_border, 0, draw_x, draw_y, width, height, self.style.color_border, 1);
	}
	
	return self;
}