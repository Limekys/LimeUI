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

hello_button = new LuiButton( , , 128, 32, "btnHelloWorld", "Hello world!").setHalign(fa_center).setValign(fa_middle);

game_ui.addContent(hello_button);