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
	initElement();
	
	self.render_content_enabled = false;
	self.panel_surface = -1;
	self.scroll_offset_y = 0;
	self.scroll_target_offset_y = 0;
	self.surface_offset = undefined;
	self.update_scroll_surface = true;
	
	///@desc setSurfaceOffset(array:[left,right,top,bottom])
	static setSurfaceOffset = function(array) {
		self.surface_offset = {
			left : array[0],
			right : array[1],
			top : array[2],
			bottom : array[3]
		};
		return self;
	}
	
	static cleanScrollPanel = function() {
		self.destroyContent();
		self.scroll_offset_y = 0;
		self.scroll_target_offset_y = 0;
	}
	
	///@ignore
	static _rearrangeElements = function() {
		for (var i = 0, n = array_length(self.content); i < n; ++i) {
		    var _element = self.content[i];
			if i == 0 {
				_element.pos_y = self.style.padding;
			} else {
				var _prev_element = self.content[i-1];
				if _prev_element.start_y == _element.start_y {
					_element.pos_y = _prev_element.start_y;
				} else {
					_element.pos_y = _prev_element.pos_y + _prev_element.height + self.style.padding;
				}
			}
			_element.start_y = _element.pos_y;
		}
		self._applyScroll();
	}
	
	///@ignore
	static _applyScroll = function() {
		array_foreach(self.content, function(_elm) {
			_elm.pos_y = _elm.start_y + self.scroll_offset_y;
		});
		_updateScrollSurface();
	}
	
	static _updateScrollSurface = function() {
		self.update_scroll_surface = true;
		self.updateMainUiSurface();
	}
	
	self.create = function() {
		if is_undefined(self.surface_offset) {
			self.setSurfaceOffset(self.style.scroll_surface_offset);
		}
		array_push(self.main_ui.main_ui_pre_draw_list, self);
	}
	
	self.onContentUpdate = function() {
		self.setDrawRelative(true);
		self._rearrangeElements();
	}
	
	self.preDraw = function() {
		//Create surface
		if !surface_exists(self.panel_surface) {
			self.panel_surface = surface_create(self.width, self.height - self.surface_offset.top - self.surface_offset.bottom);
			_updateScrollSurface();
		}
		//if self.update_scroll_surface {
			//Draw on surface
			surface_set_target(self.panel_surface);
			gpu_set_blendequation_sepalpha(bm_eq_add, bm_eq_max);
			draw_clear_alpha(self.style.color_main, 0); //???//
			self.render();
			gpu_set_blendequation(bm_eq_add);
			surface_reset_target();
			//self.update_scroll_surface = false;
		//}
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
		if !is_undefined(self.style.sprite_scroll_slider) && array_length(self.content) > 0 {
			var _scroll_slider_y = Range(self.scroll_offset_y, 0, -(self.getLast().start_y + self.getLast().height + self.style.padding - self.height), 0, self.height - self.style.padding - _scroll_slider_offset);
			draw_sprite_stretched_ext(self.style.sprite_scroll_slider, 0, _scroll_slider_x, draw_y + _scroll_slider_offset + _scroll_slider_y, _scroll_slider_offset, _scroll_slider_offset, self.style.color_scroll_slider, 1);
		}
		//Panel border
		if !is_undefined(self.style.sprite_panel_border) {
			draw_sprite_stretched_ext(self.style.sprite_panel_border, 0, draw_x, draw_y, self.width, self.height, self.style.color_border, 1);
		}
	}
	
	self.step = function() {
		if mouseHoverAny() && array_length(self.content) > 0 {
			var _wheel_up = mouse_wheel_up() ? 1 : 0;
			var _wheel_down = mouse_wheel_down() ? 1 : 0;
			var _wheel = _wheel_up - _wheel_down;
			if _wheel != 0 {
				self.scroll_target_offset_y += self.style.scroll_step * _wheel;
				self.scroll_target_offset_y = clamp(self.scroll_target_offset_y, -(self.getLast().start_y + self.getLast().height + self.style.padding - self.height), 0);
			}
		}
		if self.scroll_offset_y != self.scroll_target_offset_y {
			self.scroll_offset_y = SmoothApproachDelta(self.scroll_offset_y, self.scroll_target_offset_y, 2, 1);
			self._applyScroll();
		}
	}
	
	self.cleanUp = function() {
		if surface_exists(self.panel_surface) {
			surface_free(self.panel_surface);
		}
	}
	
	return self;
}