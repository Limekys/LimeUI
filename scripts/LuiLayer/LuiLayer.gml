///@desc A cached layer: an invisible absolute container whose content is flattened into a texture.
/// Put HUD / windows / popups into separate layers so a change in one doesn't redraw the others.
function LuiLayer(_params = {}) : LuiAbsoluteContainer(_params) constructor {
	self.addEvent(LUI_EV_CREATE, function(_e) {
		_e.setCacheAsSurface(true);
	});
}