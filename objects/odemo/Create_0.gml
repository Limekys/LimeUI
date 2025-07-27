///@desc CREATE STYLES AND UI

LIME_RESOLUTION.init();

// Init debug variables
debug_overlay = false;
debug_grid = false;
enable_alpha_test = true; // true makes UI blinking if LUI_FORCE_ALPHA_1 setted to false

// Init demo variables
demo_login = "";
demo_password = "";
long_text = "This is a really long text that probably won't fit in this element!";
demo_loading_value = 0;
demo_loading_state = false;
demo_surface = -1;

// Create Light style theme
demo_style_light = new LuiStyle()
	.setMinSize(32, 32)
	.setPadding(16)
	.setRenderRegionOffset([0,0,1,3])
	.setFonts(fDemo, fDemo, fDebug)
	.setSprites(sUI_panel, sUI_button, sUI_panel_border, sUI_button_border)
	.setSpriteCheckbox(sUI_button, sUI_checkbox_pin, sUI_button_border)
	.setSpriteToggleSwitch(sToggleSwitch, sToggleSwitchSlider, sToggleSwitchBorder, sToggleSwitchSliderBorder)
	.setSpriteComboBoxArrow(sUI_ComboBoxArrow)
	.setSpriteRing(sRing, sRing)
	.setSpriteTabs(sUI_tabs, sUI_tab, sUI_tabs_border, sUI_tab_border)
	.setColors(c_white, c_white, merge_color(c_white, c_black, 0.05), #45C952, merge_color(c_white, c_black, 0.5)) //_primary, _secondary, _back, _accent, _border
	.setColorHover(c_gray)
	.setColorText(merge_color(c_black, c_white, 0.2), c_gray)
	.setSounds(sndBasicClick);

// Create Dark style theme
demo_style_dark = new LuiStyle()
	.setMinSize(32, 32)
	.setPadding(16)
	.setRenderRegionOffset([0,0,1,3])
	.setFonts(fDemo, fDemo, fDebug)
	.setSprites(sUI_panel, sUI_button, sUI_panel_border, sUI_button_border)
	.setSpriteCheckbox(sUI_button, sUI_checkbox_pin, sUI_button_border)
	.setSpriteToggleSwitch(sToggleSwitch, sToggleSwitchSlider, sToggleSwitchBorder, sToggleSwitchSliderBorder)
	.setSpriteComboBoxArrow(sUI_ComboBoxArrow)
	.setSpriteRing(sRing, sRing)
	.setSpriteTabs(sUI_tabs, sUI_tab, sUI_tabs_border, sUI_tab_border)
	.setColors(#393c4f, #393c4f, merge_color(#393c4f, c_black, 0.1), #3a7d44, merge_color(#393c4f, c_black, 0.5)) //_primary, _secondary, _back, _accent, _border
	.setColorHover(c_gray)
	.setColorText(merge_color(c_white, #393c4f, 0.2), #77726e)
	.setSounds(sndBasicClick);

// Create Modern style theme
demo_style_modern = new LuiStyle()
	.setMinSize(32, 32)
	.setPadding(16)
	.setSymbolPassword("*")
	.setFonts(fModern, fModern, fDebug)
	.setSprites(sUI_Square_21r, sUI_Square_6r)
	.setSpriteCheckbox(sUI_button, sUI_checkbox_pin)
	.setSpriteToggleSwitch(sToggleSwitch, sToggleSwitchSlider)
	.setSpriteComboBoxArrow(sUI_ComboBoxArrow)
	.setSpriteRing(sRing, sRing)
	.setSpriteScrollSlider(sUI_Square_6r, sUI_Square_6r)
	.setColors(#393a44, merge_color(#393a44, c_white, 0.1), merge_color(#393a44, c_black, 0.2), #64d0b9) //_primary, _secondary, _back, _accent, _border
	.setColorHover(c_gray)
	.setColorText(#ffffff, #9a9daf)
	.setSounds(sndBasicClick);

// Create the main ui container
my_ui = new LuiMain().setStyle(demo_style_dark);

//Create some panels
my_panel = new LuiPanel();
my_panel_2 = new LuiPanel();
my_panel_3 = new LuiPanel();

// Create Tabs with absolute position on the screen
tabs = new LuiTabs( , , 550, 350, "LuiTabs", 48).setPositionType(flexpanel_position_type.absolute);

// Add panels to main ui container
my_ui.addContent([
	new LuiRow().addContent([
		my_panel, my_panel_2, my_panel_3, [0.4, 0.4, 0.2] // Add panels with a width ratio of 40% 40% and 20%
	]),
	tabs //Adding tab group below these panels (it doesn't matter if we add it before or after, it has an absolute position)
]);

// Create tab's
tab_panels = new LuiTab("tabPanels", "Home").setIcon(sIconHome, 1);
tab_search = new LuiTab("tabSearch", "Search").setIcon(sIconSearch, 1);
tab_sprites = new LuiTab("tabSprites", "Sprites").setIcon(sIconPalette, 1);
tab_about = new LuiTab("tabAbout", "About").setIcon(sIconInfo, 1);

// Add tab's to Tabs
tabs.addTabs([tab_panels, tab_search, tab_sprites, tab_about]);

// Adjust Tabs position on the screen
tabs_min_x = 0;
tabs_max_x = room_width - tabs.width;
tabs_min_y = 540;
tabs_max_y = room_height - tabs.height;
tabs_target_x = 100;
tabs_target_y = 540;
tabs_anim_x = tabs_target_x;
tabs_anim_y = tabs_target_y;
tabs.setPosition(tabs_target_x, tabs_target_y);

// Create some elements
demo_loading = new LuiProgressBar( , , , , , 0, 100, true, demo_loading_value, 1).setBinding(self, "demo_loading_value");
btn_show_msg = new LuiButton(, , , 32, "btnMessage", "Show message", function() {
	luiShowMessage(oDemo.my_ui, , , "Login: " + oDemo.demo_login + "\n" + "Password: " + oDemo.demo_password, "Got it!");
});
btn_restart = new LuiButton( , , , 32, "btnRestart", "Restart", function() {
	game_restart();
});

// Function to create a draggable windows
createNewLoginWindow = function () {
	// Create draggable panel (window) with some content
	my_ui.addContent([
		new LuiWindow(500 + irandom(100), 340 + irandom(100), 300, 300, , " Secret database").centerContent().addContent([
			new LuiImage(, , 64, 64, , sIconKey),
			new LuiRow().addContent([
				new LuiInput(, , , , , "", "login")
			]),
			new LuiRow().addContent([
				new LuiInput(, , , , , "", "password", true)
			]),
			new LuiButton(, , 150, 32, , "Login", function() {
				luiShowMessage(oDemo.my_ui, , , "Wrong password!", "OK!");
			})
		])
	])
}

// Add elements to first panel and init some new here
my_panel.addContent([
	new LuiText( , , , , , "First panel", true).setTextHalign(fa_center),
	new LuiRow().addContent([
		new LuiText( , , , , , "Slider"), new LuiSlider( , , , , "sliderX", tabs_min_x, tabs_max_x, 0, 1).setBinding(self, "tabs_target_x"), [0.2, 0.8]
	]),
	new LuiRow().addContent([
		new LuiText(, , , , , "ProgressBar"), demo_loading, [0.2, 0.8]
	]),
	new LuiRow().addContent([
		new LuiText( , , , , , "Login: "), new LuiInput( , , , , , , "admin", false).setBinding(self, "demo_login"), [0.2, 0.8]
	]),
	new LuiRow().addContent([
		new LuiText( , , , , , "Password: "), new LuiInput( , , , , , , "password", true).setBinding(self, "demo_password"), [0.2, 0.8]
	]),	
	new LuiRow().addContent([
		new LuiText( , , , , , "Slider with rounding 10"), new LuiSlider( , , , , "SliderRounding", 0, 100, 20, 10)
	]),
	new LuiButton(, , , , , "Create login window", function () {
		oDemo.createNewLoginWindow();
	}),
	new LuiRow().addContent([
		new LuiCheckbox( , , , , , false, "Checkbox"), new LuiToggleSwitch(, , , , , , "ToggleSwitch").setBinding(self, "demo_loading_state"), new LuiToggleButton(, , , , , , "ToggleButton")
	]),
	new LuiRow().setFlexGrow(1).setFlexAlignItems(flexpanel_align.flex_end).addContent([
		btn_show_msg.setColor(merge_color(#FFFF77, c_black, 0.5)), btn_restart.setColor(merge_color(#FF7777, c_black, 0.5))
	]),
]);

// Create some panels
my_panel_in_second_2 = new LuiPanel();

// Create deactivated button
deactivated_button = new LuiButton( , , , , , "DEACTIVATED", function() {
	self.destroy();
	oDemo.deactivated_button = -1;
}).deactivate();

activate_button = new LuiButton( , , , , , "ACTIVATE", function() {
	if is_struct(oDemo.deactivated_button) {
		oDemo.deactivated_button.activate(); oDemo.deactivated_button.text = "DELETE";
	} 
});

// Create sprite buttons and function to change its color
changeButtonColor = function() {
	self.setColor(merge_color(make_color_hsv(random(255), 255, 255), c_white, 0.5));
}
var _sprite_buttons = [];
for (var i = 0; i < 7; ++i) {
    var _button = new LuiImageButton( , , 80, 56, $"sprGMSLogo_{i}", sLogoDemo, 0, c_white, 1, i mod 2 == 0 ? true : false, changeButtonColor);
	array_push(_sprite_buttons, _button);
}

// Add array with sprite buttons to second panel of second main panel
my_panel_in_second_2.addContent([
	new LuiText( , , , , , "Panel with sprites buttons"),
	new LuiRow().setFlexJustifyContent(flexpanel_justify.space_around).setFlexWrap(flexpanel_wrap.wrap).addContent(
		_sprite_buttons
	)
]);

// Then add all together to second panel
my_panel_2.addContent([
	new LuiText( , , , , , "Second panel", true).setTextHalign(fa_center),
	new LuiPanel().addContent([
		new LuiText( , , , , , "Panel in panel").setTextHalign(fa_center),
		new LuiRow().addContent([
			activate_button, deactivated_button
		]),	
		new LuiButton( , , , , "btnVisibility", "Visible", function() {
			oDemo.my_panel_in_second_2.setVisible(!oDemo.my_panel_in_second_2.visible);
		}),
		new LuiButton( , , , , , long_text, ).setTooltip(long_text),
	]),
	my_panel_in_second_2
]);

// Create drop down menu and some items in it

combobox_theme = new LuiComboBox(, , , , , "Select theme...").set("Dark").setTooltip("Change UI theme\nWIP");
combobox_item_1 = new LuiComboBoxItem( , "Dark", function() {
	with(oDemo) {
		my_ui.setStyle(demo_style_dark);
		var _b = layer_background_get_id("bgColor");
		layer_background_blend(_b, #191919);
		_b = layer_background_get_id("bgSprites");
		layer_background_blend(_b, #333333);
		layer_background_visible(_b, true);
		//Set colors to buttons 
		btn_show_msg.setColor(merge_color(#ffff77, c_black, 0.5));
		btn_restart.setColor(merge_color(#ff7777, c_black, 0.5));
	}
});
combobox_item_2 = new LuiComboBoxItem( , "Light", function() {
	with(oDemo) {
		my_ui.setStyle(demo_style_light);
		var _b = layer_background_get_id("bgColor");
		layer_background_blend(_b, c_ltgray);
		_b = layer_background_get_id("bgSprites");
		layer_background_blend(_b, c_white);
		layer_background_visible(_b, true);
		//Set colors to buttons
		btn_show_msg.setColor(merge_color(#ffff77, c_black, 0.1));
		btn_restart.setColor(merge_color(#ff7777, c_black, 0.1));
	}
});
combobox_item_3 = new LuiComboBoxItem( , "Modern", function() { 
	with(oDemo) {
		my_ui.setStyle(demo_style_modern);
		var _b = layer_background_get_id("bgColor");
		layer_background_blend(_b, #32333d);
		_b = layer_background_get_id("bgSprites");
		layer_background_visible(_b, false);
		//Set colors to buttons 
		btn_show_msg.setColor(merge_color(#fa9a31, c_white, 0.25));
		btn_restart.setColor(merge_color(#e5538d, c_white, 0.25));
	}
});
combobox_theme.addItems([combobox_item_1, combobox_item_2, combobox_item_3]);

// Create big buttons with sprite and text
// In each button we adding sprite and text with ignore mouse hovering
// And we get big buttons with icon and text
changeRingValue = function() {
	oDemo.my_ui.getElement("luiRing").set(irandom(100));
}
big_button_1 = new LuiButton().setCallback(changeRingValue).addContent([
	new LuiRow().setMouseIgnore().addContent([
		new LuiImage(, , 32, 32, , sHamburger).setMouseIgnore(), new LuiText(, , , , , "Hamburger!").setMouseIgnore()
	])
]);
big_button_2 = new LuiButton().setCallback(changeRingValue).addContent([
	new LuiRow().setMouseIgnore().addContent([
		new LuiImage(, , 32, 32, , sBoxDemo).setMouseIgnore(), new LuiText(, , , , , "A box!").setMouseIgnore()
	])
]);
big_button_3 = new LuiButton().setCallback(changeRingValue).addContent([
	new LuiRow().setMouseIgnore().addContent([
		new LuiImage(, , 32, 32, , sLogoDemo).setMouseIgnore(), new LuiText(, , , , , "Game Maker!").setMouseIgnore()
	])
]);

// Add elements to third main panel
my_panel_3.addContent([
	new LuiText( , , , , , "Third panel", true).setTextHalign(fa_center),
	combobox_theme,
	new LuiText(, , , , , long_text).setTooltip(long_text),
	big_button_1,
	big_button_2,
	big_button_3,
	new LuiProgressRing( , , , , "luiRing", 0, 100, true, 65, 1).setFlexGrow(1)
]);

#region Fill all tab's in Tabs

	#region Add scroll panel in tab_panels

		// Create scroll panel with different elements
		tab_panels.addContent([
			new LuiText( , , , , , "Scroll panel with different elements", true).setTextHalign(fa_center),
			new LuiScrollPanel( , , , , "firstScrollPanel").addContent([
				
				new LuiInput(, , , , "input_typeinme", , "Type in me!"),
				new LuiPanel().addContent([
					new LuiText(, , , , , "Nested panel 1.1"),
					new LuiCheckbox( , , , , "checkboxTest", false, "Check me!", function() {
						luiShowMessage(oDemo.my_ui, , , get() ? "Checkbox in nested panel of scroll panel!" : ":(");
					}),
					new LuiPanel().addContent([
						new LuiText(, , , , , "Nested panel 2.1"),
						new LuiRow().addContent([
							new LuiSlider( , , , , , 0, 100, 25, 1),
							new LuiText(, , , , , "Slide me!"),
						]),
						new LuiPanel().addContent([
							new LuiText(, , , , , "Nested panel 3.1"),
							new LuiText(, , , , , "Updateble text with binding variable below").setTooltip("Try to change login in first panel"),
							new LuiText(, , , , , ).setBinding(self, "demo_login")
						])
					]),
					new LuiPanel().addContent([
						new LuiText(, , , , , "Nested panel 2.2"),
						new LuiButton( , , , , , "Press me!"),
						new LuiPanel().addContent([
							new LuiText(, , , , , "Nested panel 3.2"),
							new LuiRow().addContent([
								new LuiImageButton( , , 56, 56, , sLogoDemo, 0, c_white, 1, true, changeButtonColor),
								new LuiText(, , , , , "Press me!"),
							]),
							new LuiSurface(, , , 100, "LuiSurface", , , 0.5, false).addContent([
								new LuiText().set("LuiSurface example")
							])
						])
					])
				])
			])
		]);
		
	#endregion

	#region Add elements in tab_search
		
		// Function for buttons
		deleteSelf = function() {
			oDemo.filterElements(); self.destroy();
		};
		// Function for search system
		filterElements = function() {
			with(oDemo) {
				// Hide all
				array_foreach(search_panel.getContainer().content, function(_elm) {
					_elm.hide();
				});
				// Filter
				var _filtered_elements = array_filter(search_panel.getContainer().content, function(_elm) {
					var _elm_name = _elm.get();
					var _search_string = input_search.get();
					var _founded = string_pos(string_lower(_search_string), string_lower(_elm_name));
					if _founded != 0 return true;
					return false;
				});
				// Show filtered elements
				for (var i = 0, n = array_length(_filtered_elements); i < n; ++i) {
				    var _element = _filtered_elements[i];
					_element.show();
				}
				// Apply scrolling to correct its position //???// should this happen automatically?
				search_panel.scroll_target_offset_y = 0;
				search_panel._applyScroll();
			}
		}
		// Other elements
		search_panel = new LuiScrollPanel(, , , , "SearchPanel").addContent([
			new LuiButton(, , , , , "Aboba", oDemo.deleteSelf),
			new LuiButton(, , , , , "Microba", oDemo.deleteSelf),
			new LuiButton(, , , , , "Foo", oDemo.deleteSelf),
			new LuiButton(, , , , , "Bar", oDemo.deleteSelf),
			new LuiButton(, , , , , "Game maker!", oDemo.deleteSelf),
			new LuiButton(, , , , , "777", oDemo.deleteSelf),
		]);
		input_search = new LuiInput(, , , , "inputSearch", , "Search...", , 256, filterElements);
		panel_control = new LuiPanel(, , , , "ControlPanel");
		input_control = new LuiInput(, , , , , , "new element name", false, 32);
		control_btn_add = new LuiButton(, , , , , "Add element", function() {
			var _button_name = oDemo.input_control.get();
			oDemo.input_control.set("");
			oDemo.search_panel.addContent(new LuiButton(, , , , , _button_name, oDemo.deleteSelf));
		});
		control_btn_clear = new LuiButton(, , , , , "Clear list", function() {oDemo.search_panel.cleanScrollPanel()});
		panel_control.addContent([
			input_control,
			control_btn_add,
			control_btn_clear
		]);
		tab_search.addContent([
			new LuiRow(,,,,"panel_control_row").setFlexGrow(1).addContent([
				new LuiColumn().addContent([
					input_search,
					search_panel,
				]),
				panel_control
			])
		]);

	#endregion

	#region Add some sprites in tab_sprites
	
		sprite_car_1 = new LuiImage( , , , , , sCar).addEventListener(LUI_EV_CLICK, function() {print("click on image!")});
		sprite_car_2 = new LuiImage( , , , , , sCar, , , , false);
		sprite_car_3 = new LuiImage( , , , , , sHamburger);
		sprite_car_4 = new LuiImage( , , , , , sHamburger, , , , false);
		tab_sprites.addContent([
			new LuiRow( , , , 500).addContent([
				sprite_car_1, sprite_car_2, sprite_car_3, sprite_car_4
			])
		]);
	
	#endregion

	#region Add info about me in tab_about
	
		sprite_limekys = new LuiImage(, , 64, , "sprLimekys", sLimekysAvatar);
		text_about = new LuiText(, , , , "textAbout", "Hi, i am Limekys, and this is my UI system!");
		sprite_discord = new LuiImageButton(, , 64, 64, "sprDiscord", sDiscord_64px, , , , , function() {url_open("https://discord.gg/3bfQdhDVkC")}).setTooltip("My Discord server");
		sprite_telegram = new LuiImageButton(, , 64, 64, "sprTelegram", sTelegram_64px, , , , , function() {url_open("https://t.me/+iOeTrZOG8QhiZTQ6")}).setTooltip("My Telegram channel");
		sprite_twitch = new LuiImageButton(, , 64, 64, "sprTwitch", sTwitch_64px, , , , , function() {url_open("https://www.twitch.tv/limekys")}).setTooltip("My Twitch channel");
		sprite_twitter = new LuiImageButton(, , 64, 64, "sprTwitter", sTwitter_64px, , , , , function() {url_open("https://x.com/Limekys")}).setTooltip("My X (Twitter)");
		sprite_vk = new LuiImageButton(, , 64, 64, "sprVK", sVkontakte_64px, , , , , function() {url_open("https://vk.com/limekys_games")}).setTooltip("My VK group");
		sprite_youtube = new LuiImageButton(, , 64, 64, "sprYT", sYoutube_64px, , , , , function() {url_open("https://www.youtube.com/@Limekys")}).setTooltip("My Youtube channel");
		sprite_donate = new LuiImageButton(, , 64, 64, "sprDonate", sDonate, , , , , function() {url_open("https://www.donationalerts.com/r/limekys")}).setTooltip("Donate!");
		text_version = new LuiText(, , , , "textLimeUIVersion", "LimeUI version: " + LIMEUI_VERSION).setFlexGrow(1).setTextValign(fa_bottom).setTextHalign(fa_right);
		
		tab_about.addContent([
			new LuiRow( , , , 64).addContent([
				sprite_limekys, text_about
			]),
			new LuiRow().setFlexJustifyContent(flexpanel_justify.space_around).setFlexWrap(1).addContent([
				sprite_discord, sprite_telegram, sprite_twitch, sprite_twitter, sprite_vk, sprite_youtube, sprite_donate
			]),
			text_version
		]);
	
	#endregion

#endregion

// Create buttons to go another demo room
my_ui.addContent([
	new LuiButton(, , 256, 32, "buttonNextDemo", "Next demo -->", function() {
		room_goto(rDemo2);
		//with(oDemo) instance_destroy();
	}).setPositionType(flexpanel_position_type.absolute).setPosition(, , 16, 16),
]);

// Stress test
/*
numb = 0;
_random_element = function(_number) {
	var _rnd = irandom(5);
	switch (_rnd) {
		case 0:	return new LuiButton(, , , irandom_range(32, 128), , "button_" + string(_number)).setColor(make_color_hsv(irandom(255), irandom_range(128,255), 128));
		case 1:	return new LuiImageButton(, , , irandom_range(32, 128), , sLogoDemo, 0, make_color_hsv(irandom(255), irandom_range(128,255), 255), 1, choose(true, false), changeButtonColor);
		case 2:	return new LuiSlider(, , , , , 0, _number, irandom(_number), choose(25,10,5,2,1,0.5,0.1,0.01));
		case 3:	return new LuiInput(, , , , , , "aboba_" + string(_number));
		case 4:	return new LuiProgressRing(, , , , , 0, _number, choose(true, false), irandom(_number), choose(25,10,5,2,1,0.5,0.1,0.01));
		case 5:	return new LuiCheckbox(, , , , , choose(true, false));
	}
}
repeat (250) {
	my_ui.getElement("firstScrollPanel").addContent([
		new LuiRow().addContent([
			_random_element(numb++), _random_element(numb++), _random_element(numb++), _random_element(numb++), [random_range(0.1, 0.4), random_range(0.1, 0.4), random_range(0.1, 0.4), random_range(0.1, 0.4)]
		])
	])
}