function LuiProgressBar(x = LUI_AUTO, y = LUI_AUTO, width = 128, height = 16, value_min, value_max, draggable, value, callback) : LuiBase() constructor {
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	
	self.value_min = min(value_min, value_max);
	self.value_max = max(value_min, value_max);
	self.draggable = draggable;
	self.dragging = false;
	self.value = value;
	self.callback = method(self, callback);
	
	static draw_progress = function(sprite, index, x1, y1, x2, y2, f, c, alpha) {
        draw_sprite_stretched_ext(sprite, index, x1, y1, max((x2 - x1) * f, 0), y2 - y1, c, alpha);
    };
	
	self.step = function() {
		var x1 = x;
	    var y1 = y;
	    var x2 = x1 + self.width;
	    var y2 = y1 + self.height;
		
		if self.draggable && mouse_hover() {
            if mouse_check_button_pressed(mb_left) {
                self.dragging = true;
            }
            
            if (self.dragging) {
                if mouse_check_button(mb_left) {
                    //knob_color = EMU_COLOR_SELECTED;
                    self.value = clamp(((device_mouse_x_to_gui(0) - view_get_xport(view_current)) - x1) / (x2 - x1) * (self.value_max - self.value_min) + self.value_min, self.value_min, self.value_max);
                    //if (self.integers_only) {
                    //    self.value = round(self.value);
                    //}
                    self.callback();
                } else {
                    self.dragging = false;
                }
            }
        }
	}
	
	self.draw = function() {
		var _bar_value = clamp((self.value - self.value_min) / (self.value_max - self.value_min), 0, 1);
		draw_sprite_stretched_ext(LUI_SPRITE_PANEL, 0, x, y, width, height, c_white, 1);
		draw_sprite_stretched_ext(LUI_SPRITE_PANEL, 0, x, y, width * _bar_value, height, c_green, 1);
		draw_sprite_stretched_ext(LUI_SPRITE_PANEL_BORDER, 0, x, y, width, height, c_gray, 1);
		
		if self.draggable
		draw_sprite_stretched_ext(LUI_SPRITE_PANEL, 0, x + width * _bar_value - 8, y, height, height, c_dkgray, 1);
	}
}