my_style = new LuiStyle()
	.setPadding(16)	// Padding for all elements is 16
	.setFonts(fDemo, fDemo)	// Default font and font for interactive elements
	.setSprites(sUI_button, sUI_button)	// The same sprite for panels and for elements
	.setSounds(sndBasicClick); // Click sound

game_ui = new LuiMain().setStyle(my_style).centerContent();

hello_button = new LuiButton( , , 128, 32, "btnHelloWorld", "Hello world!");
second_button = new LuiButton( , , 128, 32, "btn2", "Second button", function() { room_goto(rDemo) });
third_button = new LuiButton( , , 128, 32, "btn3", "Third button", function() { room_goto(rDemo2) });

game_ui.addContent([
		hello_button
]);

//game_ui.addContent(hello_button);
//game_ui.addContent(second_button);
//game_ui.addContent(third_button);

//game_ui.addContent([
	//new LuiFlexRow().addContent([
		//hello_button, second_button, third_button, [0.3, 0.6, 0.1]
	//])
//]);

//game_ui.addContent(hello_button);

//game_ui.addContent([
	//hello_button,
	//second_button,
	//third_button
//]);

/*
game_ui.addContent([
	hello_button,
	new LuiPanel().addContent([
		second_button,
		new LuiPanel().addContent([
			third_button
		])
	])
]);
*/
 
/*
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

tabgroup = new LuiTabGroup(, , 512, 300, "testTabGroup", 32);
tab1 = new LuiTab(, "Tab1");
tab2 = new LuiTab(, "Tab2");
tab3 = new LuiTab(, "Tab3");
tabgroup.addTabs([tab1, tab2, tab3]);

game_ui.addContent([
	new LuiContainer().centerContent().addContent([
		tabgroup
	])
]);

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

tab3.addContent([
	new LuiText(, , , , , "Extra 33", true).setTextHalign(fa_center),
]);
*/