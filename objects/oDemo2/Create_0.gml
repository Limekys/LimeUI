LIME_RESOLUTION.init();

// Sprites https://wenrexa.itch.io/uilight

//Light theme
demo2_style = new LuiStyle()
	.setMinSize(48, 48)
	.setPadding(24)
	.setRenderRegionOffset([0,0,1,3])
	.setFonts(fntDemo2, fntDemo2, fDebug)
	.setSprites(sPanelDemo2, sBtnDemo2)
	.setSpriteProgressBar(sBarBackDemo2, sBarValueDemo2)
	.setSpriteSliderKnob(sBarBackDemo2)
	.setSpriteCheckbox(sCheckboxDemo2, sCrossDemo2)
	.setColors(#7BC0EA, #319DDD, #319DDD)
	.setColorAccent(merge_color(c_fuchsia, c_white, 0.5))
	.setColorHover(c_gray)
	.setColorText(c_white, c_gray)
	.setSounds(sndBasicClick);


// Create the main ui container
game_ui = new LuiMain().setStyle(demo2_style).centerContent();

// Create panels
panel_menu = new LuiPanel( , , 300, , "panelMainMenu");
panel_options = new LuiPanel( , , 300, , "panelOptions");

// Create elements
text_main_menu = new LuiText(, , , , "textMainMenu", "Main menu", true).setTextHalign(fa_center);
btn_play = new LuiButton(, , , , "buttonPlay", "Play");
btn_achievements = new LuiButton(, , , , "buttonAchievements", "Achievements");
btn_options = new LuiButton(, , , , "buttonOptions", "Options", function() {
	if oDemo2.panel_options.visible {
		oDemo2.panel_options.hide();
	} else {
		oDemo2.panel_options.show();
	}
});
btn_exit = new LuiButton(, , , , "buttonExit", "Exit", function() { game_end(); });
text_options = new LuiText(, , , , "textOptions", "Options", true).setTextHalign(fa_center);
checkbox_fullscreen = new LuiCheckbox(, , , , "checkboxFullscreen", window_get_fullscreen(), "Fullscreen", function () {window_set_fullscreen(get())});
slider_music = new LuiSlider(, , , , "sliderMusic", 0, 100, 75, 1);
slider_sounds = new LuiSlider(, , , , "sliderSounds", 0, 100, 25, 1);
text_music = new LuiText(, , , , "textMusic", "Music: ");
text_sounds = new LuiText(, , , , "textSounds", "Sounds: ");

// Add all content to main ui
game_ui.addContent([
	new LuiFlexRow().centerContent().addContent([
		panel_menu.addContent([
			text_main_menu,
			btn_play,
			btn_achievements,
			btn_options,
			btn_exit
		]),
		panel_options.addContent([
			text_options,
			new LuiFlexRow().addContent([
				checkbox_fullscreen,
			]),
			new LuiFlexRow().addContent([
				text_music, slider_music, [0.2, 0.8]
			]),
			new LuiFlexRow().addContent([
				text_sounds, slider_sounds, [0.2, 0.8]
			]),
		])
	])
]);

// Create buttons to go another demo room
button_prev_demo = new LuiButton(, , 256, , "buttonPrevDemo", "<-- Previous demo", function() {
	room_goto(rDemo);
});
button_next_demo = new LuiButton(, , 256, , "buttonNextDemo", "Next demo -->", function() {
	room_goto(rDemo3);
});

game_ui.addContent([
	new LuiFlexRow().centerContent().addContent([
		button_prev_demo, button_next_demo
	])
]);