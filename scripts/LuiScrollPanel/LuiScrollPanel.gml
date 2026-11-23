///@desc A panel with vertical scrolling enabled by default.
/// Available parameters: allow_resize, scroll_x, scroll_y.
///@arg {Struct} [_params] Panel parameters
function LuiScrollPanel(_params = {}) : LuiPanel(struct_merge({scroll_y: true}, _params)) constructor {
	///@desc Destroys the contents of the scroll panel.
	///@deprecated
	static cleanScrollPanel = function() {
		self.destroyContent();
	}
}
