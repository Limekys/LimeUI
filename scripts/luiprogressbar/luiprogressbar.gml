///@arg {Any} x
///@arg {Any} y
///@arg {Any} width
///@arg {Any} height
///@arg {Real} value_min
///@arg {Real} value_max
///@arg {Bool} show_value
///@arg {Real} value
function LuiProgressBar(x, y, width = 128, height = 16, value_min = 0, value_max = 100, show_value = true, value = 0) : LuiBase() constructor {
	self.name = "LuiProgressBar";
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	
	self.value_min = min(value_min, value_max);
	self.value_max = max(value_min, value_max);
	self.value = value;
	self.show_value = show_value;
	
	self.draw = function(x = self.x, y = self.y) {
		var _bar_value = Range(self.value, self.value_min, self.value_max, 0, 1);
		if self.style.sprite_panel != undefined draw_sprite_stretched_ext(self.style.sprite_panel, 0, x, y, width, height, self.style.color_main, 1);
		if self.style.sprite_panel != undefined draw_sprite_stretched_ext(self.style.sprite_panel, 0, x, y, width * _bar_value, height, self.style.color_slider, 1);
		if self.style.sprite_panel_border != undefined draw_sprite_stretched_ext(self.style.sprite_panel_border, 0, x, y, width, height, self.style.color_border, 1);
		
		if self.show_value {
			
		}
	}
}