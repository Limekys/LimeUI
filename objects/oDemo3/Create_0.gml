my_style = {
	//Fonts
	font_default : fDemo,
	font_buttons : fDemo,
	//Sprites
	sprite_button : sUI_button,
	sprite_tabgroup : sUI_button,
	sprite_tab : sUI_button,
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

hello_button = new LuiButton( , , , , "btnHelloWorld", "Hello world!");
second_button = new LuiButton( , , , , "btn2", "Demo 1", function() { room_goto(rDemo) });
third_button = new LuiButton( , , , , "btn3", "Demo 2", function() { room_goto(rDemo2) });
game_ui.addContent([
	new LuiText(, , , , , "ABOBA", true).setTextHalign(fa_center),
	hello_button, 
	new LuiFlexRow().addContent([
		second_button, third_button, new LuiFlexColumn().addContent([
			new LuiText(, , , , , "SUGOMA", true).setTextHalign(fa_center),
			new LuiText(, , , , , "Amogus", true).setTextHalign(fa_center),
			new LuiText(, , , , , "Super!", true).setTextHalign(fa_center),
		])
	])
]);

tabgroup = new LuiTabGroup(, , , 300, "testTabGroup", 32);
tab1 = new LuiTab(, "Tab1");
tab2 = new LuiTab(, "Tab2");

game_ui.addContent([
	tabgroup
])

tabgroup.addTabs([tab1, tab2]);

tab1.addContent([
	new LuiText(, , , , , "Some content in tab1", true).setTextHalign(fa_center),
	new LuiText(, , , , , "More content in tab1", true).setTextHalign(fa_center),
	new LuiFlexRow().addContent([
		new LuiText(, , , , , "Content in row 1", true).setTextHalign(fa_center), new LuiText(, , , , , "Content in row 2", true).setTextHalign(fa_center),
	])
]);

tab2.addContent([
	new LuiText(, , , , , "Content in tab2", true).setTextHalign(fa_center),
	new LuiText(, , , , , "More content in tab2", true).setTextHalign(fa_center),
	new LuiFlexRow().addContent([
		new LuiText(, , , , , "Text in row 1", true).setTextHalign(fa_center), new LuiText(, , , , , "Text in row 2", true).setTextHalign(fa_center),
	])
]);