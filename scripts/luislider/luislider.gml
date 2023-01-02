function LuiSlider(x, y, width = 128, height = 16, value_min = 0, value_max = 100, value = 0, callback = undefined) : LuiBase() constructor {
	self.name = "LuiSlider";
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	
	self.value_min = min(value_min, value_max);
	self.value_max = max(value_min, value_max);
	self.integers_only = false;
	self.dragging = false;
	self.value = value;
	self.set_callback(callback);
	
	self.render_mode = 1;
	///@desc 0 - raw value, 1 - integer only
	set_render_mode = function(mode) {
		render_mode = mode;
		return self;
	}
	
	self.step = function() {
		var x1 = self.x;
		var y1 = self.y;
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
	
	self.draw = function(x = self.x, y = self.y) {
		//Bar
		var _bar_value = Range(self.value, self.value_min, self.value_max, 0, 1);
		if self.style.sprite_panel != undefined draw_sprite_stretched_ext(self.style.sprite_panel, 0, x, y, width, height, self.style.color_main, 1);
		if self.style.sprite_panel != undefined draw_sprite_stretched_ext(self.style.sprite_panel, 0, x, y, width * _bar_value, height, self.style.color_slider, 1);
		if self.style.sprite_panel_border != undefined draw_sprite_stretched_ext(self.style.sprite_panel_border, 0, x, y, width, height, self.style.color_border, 1);
		//Text value
		var _value = render_mode == 0 ? string(self.value) : string(round(self.value));
		draw_set_font(self.style.font_sliders);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text(x + self.width div 2, y + self.height div 2, _value);
		//Slider knob
		var _knob_width = height;
		var _knob_x = clamp(x + width * _bar_value - _knob_width div 2, x, x + width - _knob_width);
		var _knob_extender = 1;
		if self.style.sprite_panel != undefined draw_sprite_stretched_ext(self.style.sprite_panel, 0, _knob_x - _knob_extender, y - _knob_extender, _knob_width + _knob_extender*2, height + _knob_extender*2, self.style.color_main, 1);
		if self.style.sprite_panel_border != undefined draw_sprite_stretched_ext(self.style.sprite_panel_border, 0, _knob_x - _knob_extender, y - _knob_extender, _knob_width + _knob_extender*2, height + _knob_extender*2, self.style.color_border, 1);
	}
}