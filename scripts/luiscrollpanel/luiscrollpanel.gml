///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
function LuiScrollPanel(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = "LuiScrollPanel") : LuiBase() constructor {
	
	self.name = name;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	init_element();
	
	self.render_content_enabled = false;
	self.panel_surface = -1;
	self.scroll_offset_y = 0;
	self.scroll_target_offset_y = 0;
	self.surface_offset = {
		left : 0,
		right : 0,
		top : 1,
		bottom : 3
	};
	
	self.on_content_update = function() {
		self.set_draw_relative(true);
	}
	
	self.pre_draw = function() {
		//Create surface
		if !surface_exists(self.panel_surface) {
			self.panel_surface = surface_create(self.width, self.height - self.surface_offset.top - self.surface_offset.bottom);
		}
		//Draw on surface
		surface_set_target(self.panel_surface);
		draw_clear_alpha(c_white, 0);
		//shader_set(shPremultiplyAlpha);
		//gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
		self.render();
		//gpu_set_blendmode(bm_normal);
		//shader_reset();
		surface_reset_target();
	}
	
	self.draw = function(draw_x = 0, draw_y = 0) {
		//Panel
		if !is_undefined(self.style.sprite_panel) {
			draw_sprite_stretched_ext(self.style.sprite_panel, 0, draw_x, draw_y, self.width, self.height, self.style.color_main, 1);
		}
		//Surface
		if surface_exists(self.panel_surface) {
			draw_set_alpha(1);
			draw_surface(self.panel_surface, draw_x, draw_y + self.surface_offset.top);
		}
		//Scroll slider
		var _scroll_slider_offset = 8;
		var _scroll_slider_x = draw_x + self.width - _scroll_slider_offset - _scroll_slider_offset div 2;
		if !is_undefined(self.style.sprite_scroll_slider_back) {
			draw_sprite_stretched_ext(self.style.sprite_scroll_slider_back, 0, _scroll_slider_x, draw_y + _scroll_slider_offset, _scroll_slider_offset, self.height - _scroll_slider_offset*2, self.style.color_scroll_slider_back, 1);
		}
		if !is_undefined(self.style.sprite_scroll_slider) && array_length(self.contents) > 0 {
			var _scroll_slider_y = Range(self.scroll_offset_y, 0, -(self.get_last().start_y + self.get_last().height + self.style.padding - self.height), 0, self.height - self.style.padding - _scroll_slider_offset);
			draw_sprite_stretched_ext(self.style.sprite_scroll_slider, 0, _scroll_slider_x, draw_y + _scroll_slider_offset + _scroll_slider_y, _scroll_slider_offset, _scroll_slider_offset, self.style.color_scroll_slider, 1);
		}
		//Panel border
		if !is_undefined(self.style.sprite_panel_border) {
			draw_sprite_stretched_ext(self.style.sprite_panel_border, 0, draw_x, draw_y, self.width, self.height, self.style.color_border, 1);
		}
	}
	
	self.step = function() {
		if mouse_hover_any() && array_length(self.contents) > 0 {
			var _wheel_up = mouse_wheel_up() ? 1 : 0;
			var _wheel_down = mouse_wheel_down() ? 1 : 0;
			var _wheel = _wheel_up - _wheel_down;
			if _wheel != 0 {
				self.scroll_target_offset_y += self.style.scroll_step * _wheel;
				self.scroll_target_offset_y = clamp(self.scroll_target_offset_y, -(self.get_last().start_y + self.get_last().height + self.style.padding - self.height), 0);
			}
		}
		if self.scroll_offset_y != self.scroll_target_offset_y {
			self.scroll_offset_y = SmoothApproachDelta(self.scroll_offset_y, self.scroll_target_offset_y, 2);
			array_foreach(self.contents, function(_elm) {
				_elm.pos_y = _elm.start_y + self.scroll_offset_y;
			})
		}
	}
	
	self.clean_up = function() {
		if surface_exists(self.panel_surface) {
			surface_free(self.panel_surface);
		}
	}
	
	///@func set_surface_offset(array:[left,right,top,bottom])
	static set_surface_offset = function(array) {
		self.surface_offset = {
			left : array[0],
			right : array[1],
			top : array[2],
			bottom : array[3]
		};
		return self;
	}
	
	return self;
}