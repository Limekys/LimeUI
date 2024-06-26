//Info
#macro LIMEUI_VERSION "2024.07.02"

//System (Dont touch)
#macro LUI_AUTO							-1
#macro LUI_AUTO_NO_PADDING				-2
#macro LUI_STRETCH						-3

#macro LUI_OVERLAY						_LuiGetOverlay()

//Globals
global.LUI_DEBUG_MODE =	0;

//Overlay //???//
///@ignore
function _LuiGetOverlay() {
	static LuiOverlay = function() : LuiBase() constructor {
		global.lui_main_ui = undefined;
		self.name = "LUI_OVERLAY";
		self.baseRender = self.render;
		self.render = function() {
			if array_length(self.content) > 0 {
				self.width = window_get_width();
	            self.height = window_get_height();
				draw_set_alpha(0.5);
				draw_set_color(c_black);
				draw_rectangle(0, 0, self.width, self.height, false);
				self.baseRender();
			}
		}
		self.close = function() {
			contents = [];
			return self;
		}
	}
	static inst = new LuiOverlay();
    return inst;
}