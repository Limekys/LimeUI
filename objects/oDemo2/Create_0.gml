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
panel_menu = new LuiPanel({width: 300});
panel_options = new LuiPanel({width: 300});

// Create elements
text_main_menu = new LuiText({value: "Main menu"}).setTextHalign(fa_center);
btn_play = new LuiButton({text: "Play"});
btn_achievements = new LuiButton({text: "Achievements"});
btn_options = new LuiButton({text: "Options"}).addEvent(LUI_EV_CLICK, function() {
	if oDemo2.panel_options.visible {
		oDemo2.panel_options.hide();
	} else {
		oDemo2.panel_options.show();
	}
});
btn_exit = new LuiButton({text: "Exit"}).addEvent(LUI_EV_CLICK, function() {game_end()});
text_options = new LuiText({value: "Options"}).setTextHalign(fa_center);
checkbox_fullscreen = new LuiCheckbox({value: window_get_fullscreen(), text: "Fullscreen"}).addEvent(LUI_EV_CLICK, function (_element) {window_set_fullscreen(_element.get())});
slider_music = new LuiSlider({value: 75, rounding: 1});
slider_sounds = new LuiSlider({value: 25, rounding: 1});
text_music = new LuiText({value: "Music: "});
text_sounds = new LuiText({value: "Sounds: "});

// Add all content to main ui
game_ui.addContent([
	new LuiRow().centerContent().addContent([
		panel_menu.addContent([
			text_main_menu,
			btn_play,
			btn_achievements,
			btn_options,
			btn_exit
		]),
		panel_options.addContent([
			text_options,
			new LuiRow().addContent([
				checkbox_fullscreen,
			]),
			new LuiRow().addContent([
				text_music, slider_music, [0.2, 0.8]
			]),
			new LuiRow().addContent([
				text_sounds, slider_sounds, [0.2, 0.8]
			]),
		])
	])
]);

// Create buttons to go another demo room
button_prev_demo = new LuiButton({text: "<-- Previous demo", width: 256}).addEvent(LUI_EV_CLICK, function() {
	room_goto(rDemo);
});
button_next_demo = new LuiButton({text: "Next demo -->", width: 256}).addEvent(LUI_EV_CLICK, function() {
	room_goto(rDemo3);
});

game_ui.addContent([
	new LuiRow().centerContent().addContent([
		button_prev_demo, button_next_demo
	])
]);