///@desc An empty, invisible container for elements with padding on the sides for elements with column stacking
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
function LuiContainer(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = LUI_AUTO_NAME) : LuiBase() constructor {
	
	self.name = name;
	self.pos_x = x;
	self.pos_y = y;
	self.width = width;
	self.height = height;
	_initElement();
	
	self.ignore_mouse = true;
}

///@desc An empty, invisible container with no padding on the sides for elements with row stacking
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
function LuiRow(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = LUI_AUTO_NAME) : LuiContainer(x, y, width, height, name) constructor {
	
	self.addEvent(LUI_EV_CREATE, function(_element) {
		_element.setPadding(0).setFlexDirection(flexpanel_flex_direction.row);
	});
}

///@desc An empty, invisible container with no padding on the sides for elements with column stacking
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
function LuiColumn(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = LUI_AUTO_NAME) : LuiContainer(x, y, width, height, name) constructor {
	
	self.addEvent(LUI_EV_CREATE, function(_element) {
		_element.setPadding(0).setFlexDirection(flexpanel_flex_direction.column);
	});
}

///@desc An empty, invisible container with absolute position on the screen for elements
///@arg {Real} x
///@arg {Real} y
///@arg {Real} width
///@arg {Real} height
///@arg {String} name
function LuiAbsoluteContainer(x = LUI_AUTO, y = LUI_AUTO, width = LUI_AUTO, height = LUI_AUTO, name = LUI_AUTO_NAME) : LuiContainer(x, y, width, height, name) constructor {
	
	self.addEvent(LUI_EV_CREATE, function(_element) {
		_element.setPositionAbsolute();
	});
}