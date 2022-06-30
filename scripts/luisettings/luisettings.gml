//Info
#macro LIMEUI_VERSION "2022.06.30"

//Fonts
#macro LUI_FONT_DEFAULT					fArial
#macro LUI_FONT_BUTTONS					fArial
//Colors
#macro LUI_COLOR_FONT					c_black
#macro LUI_COLOR_FONT_HINT				c_gray
#macro LUI_COLOR_MAIN					c_white
#macro LUI_COLOR_BORDER					merge_colour(self.blend_color, c_black, 0.5)
#macro LUI_COLOR_CHECKBOX_PIN			#45C952 //lite green
#macro LUI_COLOR_SLIDER					#45C952 //lite green
#macro LUI_COLOR_TEXTBOXBORDER			merge_colour(self.blend_color, c_dkgray, 0.5)
//Sprites (set undefined if you do not want to draw it)
#macro LUI_SPRITE_PANEL					sUI_panel
#macro LUI_SPRITE_PANEL_BORDER			sUI_panel_border
#macro LUI_SPRITE_BUTTON				sUI_button
#macro LUI_SPRITE_BUTTON_BORDER			sUI_button_border
#macro LUI_SPRITE_SLIDER_KNOB			sUI_slider_knob
#macro LUI_SPRITE_SLIDER_KNOB_BORDER	sUI_slider_knob_border
//Sounds (set undefined if you do not want to play sound)
#macro LUI_CLICK_SOUND					sndBasicClick
//Settings
#macro LUI_PADDING						16
#macro LUI_SCROLL_SIZE					32
#macro LUI_TEXTBOX_CURSOR				"|"
#macro LUI_TEXTBOX_PASSWORD				"•"

//System (Dont touch)
#macro LUI_AUTO							ptr(0)
#macro LUI_AUTO_NO_PADDING				ptr(1)
#macro LUI_STRETCH						ptr(2)

#macro LUI_OVERLAY						_LuiGetOverlay()

//Globals
global.LUI_DEBUG_MODE =	0;

//Overlay
function _LuiGetOverlay() {
	static LuiOverlay = function() : LuiBase() constructor {
		self.baseRender = self.render;
		self.render = function() {
			if array_length(self.contents) > 0 {
				self.width = window_get_width();
	            self.height = window_get_height();
				draw_set_alpha(0.5);
				draw_set_color(c_black);
				draw_rectangle(0, 0, self.width, self.height, false);
				self.baseRender();
			}
		}
	}
	static inst = new LuiOverlay();
    return inst;
}