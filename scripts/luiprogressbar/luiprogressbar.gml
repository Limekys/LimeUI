///@arg {Any} x
///@arg {Any} y
///@arg {Any} width
///@arg {Any} height
///@arg {Real} value_min
///@arg {Real} value_max
///@arg {Bool} show_value
///@arg {Real} value
function LuiProgressBar(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, value_min = 0, value_max = 100, show_value = true, value = 0) : LuiBase() constructor {
	
	self.name = "LuiProgressBar";
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	init_element();
	
	self.value_min = min(value_min, value_max);
	self.value_max = max(value_min, value_max);
	self.value = value;
	self.show_value = show_value;
	
	self.render_mode = 1;
	///@desc 0 - raw value, 1 - integer only
	set_render_mode = function(mode) {
		render_mode = mode;
		return self;
	}
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		var _bar_value = Range(self.value, self.value_min, self.value_max, 0, 1);
		if !is_undefined(self.style.sprite_panel) draw_sprite_stretched_ext(self.style.sprite_panel, 0, draw_x, draw_y, width, height, self.style.color_main, 1);
		if !is_undefined(self.style.sprite_panel) draw_sprite_stretched_ext(self.style.sprite_panel, 0, draw_x, draw_y, width * _bar_value, height, self.style.color_slider, 1);
		if !is_undefined(self.style.sprite_panel_border) draw_sprite_stretched_ext(self.style.sprite_panel_border, 0, draw_x, draw_y, width, height, self.style.color_border, 1);
		
		if self.show_value {
			var _value = render_mode == 0 ? string(self.value) : string(round(self.value));
			if !is_undefined(self.style.font_sliders) draw_set_font(self.style.font_sliders);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_text(draw_x + self.width div 2, draw_y + self.height div 2, _value);
		}
	}
	
	return self;
}