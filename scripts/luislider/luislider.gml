///@arg {Any} x
///@arg {Any} y
///@arg {Any} width
///@arg {Any} height
///@arg {Real} value_min
///@arg {Real} value_max
///@arg {Real} value
///@arg {Function} callback
function LuiSlider(x, y, width, height, value_min = 0, value_max = 100, value = 0, callback = undefined) : LuiBase() constructor {
	self.name = "LuiSlider";
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height ?? self.min_height;
	self.max_height = self.height;
	
	self.value_min = min(value_min, value_max);
	self.value_max = max(value_min, value_max);
	self.integers_only = false;
	self.dragging = false;
	self.value = value;
	
	set_callback(callback);
	
	self.render_mode = 1;
	///@desc 0 - raw value, 1 - integer only
	set_render_mode = function(mode) {
		render_mode = mode;
		return self;
	}
	
	self.step = function() {
		var x1 = self.get_absolute_x();
		var y1 = self.get_absolute_y();
		var x2 = x1 + self.width;
		var y2 = y1 + self.height;
		
		if mouse_check_button_pressed(mb_left) && mouse_hover() {
			self.dragging = true;
		}
		
		if (self.dragging) {
			if mouse_check_button(mb_left) {
				self.value = clamp(((device_mouse_x_to_gui(0) - view_get_xport(view_current)) - x1) / (x2 - x1) * (self.value_max - self.value_min) + self.value_min, self.value_min, self.value_max);
				if (self.integers_only) {
				    self.value = round(self.value);
				}
				self.callback();
			} else {
				self.dragging = false;
			}
		}
	}
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		//Bar
		var _bar_value = Range(self.value, self.value_min, self.value_max, 0, 1);
		if !is_undefined(self.style.sprite_panel) draw_sprite_stretched_ext(self.style.sprite_panel, 0, draw_x, draw_y, width, height, self.style.color_main, 1);
		if !is_undefined(self.style.sprite_panel) draw_sprite_stretched_ext(self.style.sprite_panel, 0, draw_x, draw_y, width * _bar_value, height, self.style.color_slider, 1);
		if !is_undefined(self.style.sprite_panel_border) draw_sprite_stretched_ext(self.style.sprite_panel_border, 0, draw_x, draw_y, width, height, self.style.color_border, 1);
		//Text value
		var _value = render_mode == 0 ? string(self.value) : string(round(self.value));
		if !is_undefined(self.style.font_sliders) draw_set_font(self.style.font_sliders);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text(draw_x + self.width div 2, draw_y + self.height div 2, _value);
		//Slider knob
		var _knob_width = !is_undefined(self.style.sprite_slider_knob) ? sprite_get_nineslice(self.style.sprite_slider_knob).left + sprite_get_nineslice(self.style.sprite_slider_knob).right : self.height;
		var _knob_x = clamp(draw_x + self.width * _bar_value - _knob_width div 2, draw_x, draw_x + self.width - _knob_width);
		var _knob_extender = 1;
		if !is_undefined(self.style.sprite_slider_knob) {
			var _blend_color = self.style.color_main;
			if self.mouse_hover() _blend_color = merge_colour(self.style.color_main, self.style.color_hover, 0.25);
			draw_sprite_stretched_ext(self.style.sprite_slider_knob, 0, _knob_x - _knob_extender, draw_y - _knob_extender, _knob_width + _knob_extender*2, self.height + _knob_extender*2, _blend_color, 1);
		}
		if !is_undefined(self.style.sprite_slider_knob_border) draw_sprite_stretched_ext(self.style.sprite_slider_knob_border, 0, _knob_x - _knob_extender, draw_y - _knob_extender, _knob_width + _knob_extender*2, self.height + _knob_extender*2, self.style.color_border, 1);
	}
	
	return self;
}