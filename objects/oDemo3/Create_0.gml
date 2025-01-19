my_style = {
	//Fonts
	font_default : fDemo,
	font_buttons : fDemo,
	//Sprites
	sprite_button : sUI_button,
	//Colors
	color_font : merge_colour(c_black, c_white, 0.2),
	color_button : c_white,
	color_hover : c_gray,
	//Sounds
	sound_click : sndBasicClick,
	//Settings
	padding : 16
};

game_ui = new LuiMain().setStyle(my_style);

hello_button = new LuiButton( , , , , "btnHelloWorld", "Hello world!")//.setHalign(fa_center).setValign(fa_middle);
second_button = new LuiButton( , , , , "btn2", "Demo 1", function() { room_goto(rDemo) })//.setHalign(fa_center).setValign(fa_middle);
third_button = new LuiButton( , , , , "btn3", "Demo 2", function() { room_goto(rDemo2) })//.setHalign(fa_center).setValign(fa_middle);

game_ui.addContent([
	new LuiText(, , , , , "ABOBA", true).setTextHalign(fa_center),
	hello_button, 
	new LuiFlexRow().addContent([
		second_button, third_button, new LuiFlexColumn().addContent([
			new LuiText(, , , , , "SUGOMA", true).setTextHalign(fa_center),
			new LuiText(, , , , , "Amogus", true).setTextHalign(fa_center),
			new LuiText(, , , , , "Super!", true).setTextHalign(fa_center),
		])
	], 0)
]);