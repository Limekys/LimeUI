// Sprites https://wenrexa.itch.io/uilight

//Light theme
demo2_style = {
	//Fonts
	font_default : fntDemo2,
	font_buttons : fntDemo2,
	font_sliders : fntDemo2,
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
	padding : 16,
	checkbox_pin_margin : 0,
	scroll_step : 32,
	scroll_surface_offset : [0,0,1,3],
	textbox_cursor : "|",
	textbox_password : "•"
                                                                    }; // TEMP: Just for fix stupid feather >_<


// Create the main ui container
game_ui = new LuiMain().setStyle(demo2_style);

// Create panels
panel_menu = new LuiPanel( , , 300, , "panelMainMenu").setHalign(fa_center).setValign(fa_middle);
panel_options = new LuiPanel( , , 300, , "panelOptions").setHalign(fa_right).setValign(fa_middle);

// Create elements
text_main_menu = new LuiText(, , , 64, "textMainMenu", "Main menu", true).setTextHalign(fa_center);
btn_play = new LuiButton(, , , 64, "buttonPlay", "Play");
btn_achievements = new LuiButton(, , , 64, "buttonAchievements", "Achievements");
btn_options = new LuiButton(, , , 64, "buttonOptions", "Options");
btn_exit = new LuiButton(, , , 64, "buttonExit", "Exit", function() { game_end(); });
text_options = new LuiText(, , , 64, "textOptions", "Options", true).setTextHalign(fa_center);
checkbox_fullscreen = new LuiCheckbox(, , 48, 48, "checkboxFullscreen", false);
text_fullscreen = new LuiText(, , , , "textFullscreen", "Fullscreen");
slider_music = new LuiSlider(, , , , "sliderMusic", 0, 100, 75, 1);
slider_sounds = new LuiSlider(, , , , "sliderSounds", 0, 100, 25, 1);
text_music = new LuiText(, , , , "textMusic", "Music: ");
text_sounds = new LuiText(, , , , "textSounds", "Sounds: ");

// Add all content to main ui
game_ui.addContent([
	panel_menu.addContent([
		text_main_menu,
		btn_play,
		btn_achievements,
		btn_options,
		btn_exit
	]),
	panel_options.addContent([
		text_options,
		[text_fullscreen, checkbox_fullscreen],
		[text_music, slider_music],
		[text_sounds, slider_sounds]
	])
])

// Create buttons to go another demo room
button_prev_demo = new LuiButton(, , 256, , "buttonPrevDemo", "<-- Previous demo", function() {
	room_goto(rDemo);
}).setHalign(fa_left).setValign(fa_bottom);
button_next_demo = new LuiButton(, , 256, , "buttonNextDemo", "Next demo -->", function() {
	room_goto(rDemo3);
}).setHalign(fa_right).setValign(fa_bottom);

game_ui.addContent([button_prev_demo, button_next_demo]);