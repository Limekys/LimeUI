// Sprites https://wenrexa.itch.io/uilight

//Light theme
demo2_style = {
	//Fonts
	font_default : fntDemo2,
	font_buttons : fntDemo2,
	font_debug : fDebug,
	//Sprites
	sprite_panel : sPanelDemo2,
	sprite_textbox : sUI_textbox,
	sprite_button : sBtnDemo2,
	sprite_checkbox : sCheckboxDemo2,
	sprite_checkbox_pin : sCrossDemo2,
	sprite_progress_bar : sBarBackDemo2,
	sprite_progress_bar_value : sBarValueDemo2,
	sprite_slider_knob : sBarValueDemo2,
	sprite_scroll_slider : sUI_scroll_slider,
	sprite_scroll_slider_back : sUI_scroll_slider,
	sprite_dropdown : sUI_button,
	sprite_dropdown_item : sUI_button,
	sprite_tooltip : sUI_panel,
	sprite_dropdown_arrow : sUI_dropdown_arrow,
	sprite_tab : sUI_tab,
	sprite_tabgroup : sUI_tabgroup,
	//Colors
	color_font : c_white,
	color_font_hint : c_gray,
	color_main : #7BC0EA,
	color_button : #319DDD,
	color_hover : c_gray,
	color_checkbox : #319DDD,
	color_checkbox_pin : c_white,
	color_progress_bar : #319DDD,
	color_progress_bar_value : #45C952,
	color_textbox : #319DDD,
	color_scroll_slider : #319DDD,
	color_scroll_slider_back : c_gray,
	color_dropdown : #319DDD,
	color_dropdown_arrow : merge_colour(c_white, c_black, 0.5),
	color_tooltip : c_white,
	//Sounds
	sound_click : sndBasicClick,
	//Settings
	default_min_width : 48,
	default_min_height : 48,
	padding : 24,
	checkbox_pin_margin : 0,
	scroll_step : 32,
	render_region_offset : {left : 0, right : 0, top : 1, bottom : 3},
	textbox_cursor : "|",
	textbox_password : "•"
                                                                    }; // TEMP: Just for fix stupid feather >_<


// Create the main ui container
game_ui = new LuiMain().setStyle(demo2_style).centerContent();

// Create panels
panel_menu = new LuiPanel( , , 300, , "panelMainMenu");
panel_options = new LuiPanel( , , 300, , "panelOptions");

// Create elements
text_main_menu = new LuiText(, , , , "textMainMenu", "Main menu", true).setTextHalign(fa_center);
btn_play = new LuiButton(, , , , "buttonPlay", "Play");
btn_achievements = new LuiButton(, , , , "buttonAchievements", "Achievements");
btn_options = new LuiButton(, , , , "buttonOptions", "Options");
btn_exit = new LuiButton(, , , , "buttonExit", "Exit", function() { game_end(); });
text_options = new LuiText(, , , , "textOptions", "Options", true).setTextHalign(fa_center);
checkbox_fullscreen = new LuiCheckbox(, , 48, , "checkboxFullscreen", false);
text_fullscreen = new LuiText(, , , , "textFullscreen", "Fullscreen");
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
				checkbox_fullscreen, text_fullscreen,
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