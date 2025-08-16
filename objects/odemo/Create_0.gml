///@desc CREATE STYLES AND UI

LIME_RESOLUTION.init();

// Init debug variables
debug_overlay = false;
debug_grid = false;
enable_alpha_test = true; // true makes UI blinking if LUI_FORCE_ALPHA_1 setted to false

// Init demo variables
demo_login = "";
demo_password = "";
long_text = "This is a really long text that probably won't fit in this component!";
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
	.setColorAccent(#45C952)
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
	.setColorAccent(#3a7d44)
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
	.setColorAccent(#64d0b9)
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
tabs = new LuiTabs({width: 550, height: 350, name: "LuiTabs", tab_height: 32}).setPositionAbsolute();

// Add panels to main ui container
my_ui.addContent([
	new LuiRow().addContent([
		my_panel, my_panel_2, my_panel_3, [0.4, 0.4, 0.2] // Add panels with a width ratio of 40% 40% and 20%
	]),
	tabs //Adding tab group below these panels (it doesn't matter if we add it before or after, it has an absolute position)
]);

// Create tab's
tab_panels = new LuiTab({text: "Home"});
tab_search = new LuiTab({text: "Search"});
tab_sprites = new LuiTab({text: "Sprites"});
tab_about = new LuiTab({text: "About"});

// Add tab's to Tabs
tabs.addTabs([tab_panels, tab_search, tab_sprites, tab_about]);

// Adjust Tabs position on the screen
tabs_min_x = 0;
tabs_max_x = room_width - tabs.width;
tabs_min_y = 540;
tabs_max_y = room_height - tabs.height;
tabs_target_x = 470;
tabs_target_y = 540;
tabs_anim_x = tabs_target_x;
tabs_anim_y = tabs_target_y;
tabs.setPosition(tabs_target_x, tabs_target_y);

// Create some elements
demo_loading = new LuiProgressBar({value: demo_loading_value, rounding: 1}).bindVariable(self, "demo_loading_value");
btn_show_msg = new LuiButton({text: "Show message"}).setColor(merge_color(#FFFF77, c_black, 0.5)).setIcon(sIconInfo, 1).addEvent(LUI_EV_CLICK, function() {
	luiShowMessage(oDemo.my_ui, , , "Login: " + oDemo.demo_login + "\n" + "Password: " + oDemo.demo_password, "Got it!");
});
btn_restart = new LuiButton({text: "Restart"}).setColor(merge_color(#FF7777, c_black, 0.5)).addEvent(LUI_EV_CLICK, function() {
	game_restart();
});

// Function to create a draggable windows
createNewLoginWindow = function () {
	// Create draggable panel (window) with some content
	my_ui.addContent([
		new LuiWindow({x: 500 + irandom(100), y: 340 + irandom(100), width: 300, height: 300, title: "Secret database"}).centerContent().addContent([
			new LuiImage({value: sIconKey, width: 64, height: 64}),
			new LuiRow().addContent([
				new LuiInput({placeholder: "login"})
			]),
			new LuiRow().addContent([
				new LuiInput({placeholder: "password", is_masked: true, input_mode: LUI_INPUT_MODE.password})
			]),
			new LuiButton({text: "Login", width: 150}).addEvent(LUI_EV_CLICK, function() {
				luiShowMessage(oDemo.my_ui, , , "Wrong password!", "OK!");
			})
		])
	])
}

// Add elements to first panel and init some new here
my_panel.addContent([
	new LuiText({value: "First panel", scale_to_fit: true}).setTextHalign(fa_center),
	new LuiRow().addContent([
		new LuiText({value: "Slider"}), new LuiSlider({name: "sliderX", value: 0, min_value: tabs_min_x, max_value: tabs_max_x, rounding: 1}).bindVariable(self, "tabs_target_x"), [0.3, 0.7]
	]),
	new LuiRow().addContent([
		new LuiText({value: "ProgressBar"}), demo_loading, [0.3, 0.7]
	]),
	new LuiRow().addContent([
		new LuiText({value: "Login: "}), new LuiInput({placeholder: "admin", max_length: 32}).bindVariable(self, "demo_login"), [0.3, 0.7]
	]),
	new LuiRow().addContent([
		new LuiText({value: "Password: "}), new LuiInput({placeholder: "password", max_length: 32, is_masked: true, input_mode: LUI_INPUT_MODE.password}).bindVariable(self, "demo_password"), [0.3, 0.7]
	]),	
	new LuiRow().addContent([
		new LuiText({value: "Slider with rounding 10"}), new LuiSlider({name: "SliderRounding", value: 20, rounding: 10, bar_height: 16}), [0.3, 0.7]
	]),
	new LuiButton({text: "Create login window"}).addEvent(LUI_EV_CLICK, function () {
		oDemo.createNewLoginWindow();
	}),
	new LuiRow().addContent([
		new LuiCheckbox({text: "Checkbox"}), new LuiToggleSwitch({text: "ToggleSwitch"}).bindVariable(self, "demo_loading_state"), new LuiToggleButton({text: "ToggleButton"})
	]),
	new LuiRow().setFlexGrow(1).setFlexAlignItems(flexpanel_align.flex_end).addContent([
		btn_show_msg, btn_restart
	])
]);

// Create deactivated button
deactivated_button = new LuiButton({text: "DEACTIVATED"}).deactivate().addEvent(LUI_EV_CLICK, function(_e) {
	_e.destroy();
	oDemo.deactivated_button = -1;
});

activate_button = new LuiButton({text: "ACTIVATE"}).addEvent(LUI_EV_CLICK, function() {
	if oDemo.deactivated_button != -1 {
		oDemo.deactivated_button.activate();
		oDemo.deactivated_button.setText("DELETE");
	}
});

// Create sprite buttons and function to change its color
changeImageButtonColor = function(_e) {
	_e.setColor(merge_color(make_color_hsv(random(255), 255, 255), c_white, 0.5));
}
var _sprite_buttons = [];
for (var i = 0; i < 7; ++i) {
    var _button = new LuiImageButton({width: 80, height: 56, value: sLogoDemo, maintain_aspect: i mod 2 == 0 ? true : false});
	_button.addEvent(LUI_EV_CLICK, function(_e) {oDemo.changeImageButtonColor(_e);});
	array_push(_sprite_buttons, _button);
}

// Add array with sprite buttons to panel with sprites
panel_with_sprites = new LuiPanel().addContent([
	new LuiText({value: "Panel with sprites buttons"}),
	new LuiRow().setFlexJustifyContent(flexpanel_justify.space_around).setFlexWrap(flexpanel_wrap.wrap).addContent(
		_sprite_buttons
	)
]);

// Then add all together to second panel
my_panel_2.addContent([
	new LuiText({value: "Second panel", scale_to_fit: true}).setTextHalign(fa_center),
	new LuiPanel().addContent([
		new LuiText({value: "Panel in panel"}).setTextHalign(fa_center),
		new LuiRow().addContent([
			activate_button, deactivated_button
		]),	
		new LuiButton({text: "Visible"}).addEvent(LUI_EV_CLICK, function() {
			oDemo.panel_with_sprites.setVisible(!oDemo.panel_with_sprites.visible);
		}),
		new LuiButton().setText(long_text).setTooltip(long_text),
	]),
	panel_with_sprites
]);

// Create drop down menu and some items in it
combobox_theme = new LuiComboBox({placeholder: "Select theme..."}).setTooltip("Change UI theme\nWIP");
combobox_item_1 = new LuiComboBoxItem({text: "Dark"}).addEvent(LUI_EV_CLICK, function() {
	with(oDemo) {
		// Change ui style
		my_ui.setStyle(demo_style_dark);
		// Change background
		var _b = layer_background_get_id("bgColor");
		layer_background_blend(_b, #191919);
		// Set colors to buttons 
		btn_show_msg.setColor(merge_color(#ffff77, c_black, 0.5));
		btn_restart.setColor(merge_color(#ff7777, c_black, 0.5));
		// Tabs settings
		tabs.setTabHeight(32).setTabIndent(0);
		tab_panels.setIcon(-1);
		tab_search.setIcon(-1);
		tab_sprites.setIcon(-1);
		tab_about.setIcon(-1);
	}
});
combobox_item_2 = new LuiComboBoxItem({text: "Light"}).addEvent(LUI_EV_CLICK, function() {
	with(oDemo) {
		// Change ui style
		my_ui.setStyle(demo_style_light);
		// Change background
		var _b = layer_background_get_id("bgColor");
		layer_background_blend(_b, c_ltgray);
		// Set colors to buttons
		btn_show_msg.setColor(merge_color(#ffff77, c_black, 0.1));
		btn_restart.setColor(merge_color(#ff7777, c_black, 0.1));
		// Tabs settings
		tabs.setTabHeight(32).setTabIndent(0);
		tab_panels.setIcon(-1);
		tab_search.setIcon(-1);
		tab_sprites.setIcon(-1);
		tab_about.setIcon(-1);
	}
});
combobox_item_3 = new LuiComboBoxItem({text: "Modern"}).addEvent(LUI_EV_CLICK, function() { 
	with(oDemo) {
		// Change ui style
		my_ui.setStyle(demo_style_modern);
		// Change background
		var _b = layer_background_get_id("bgColor");
		layer_background_blend(_b, #32333d);
		// Set colors to buttons 
		btn_show_msg.setColor(merge_color(#fa9a31, c_white, 0.25));
		btn_restart.setColor(merge_color(#e5538d, c_white, 0.25));
		// Tabs settings
		tabs.setTabHeight(48).setTabIndent(16);
		tab_panels.setIcon(sIconHome, 1);
		tab_search.setIcon(sIconSearch, 1);
		tab_sprites.setIcon(sIconPalette, 1);
		tab_about.setIcon(sIconInfo, 1);
	}
});
combobox_theme.addItems([combobox_item_1, combobox_item_2, combobox_item_3]);

// Create big buttons with sprite and text
// In each button we adding sprite and text with ignore mouse hovering
// And we get big buttons with icon and text
changeRingValue = function() {
	oDemo.my_ui.getElement("luiRing").set(irandom(100));
}
big_button_1 = new LuiButton().addEvent(LUI_EV_CLICK, function() {oDemo.changeRingValue();}).addContent([
	new LuiRow().setMouseIgnore().addContent([
		new LuiImage({value: sHamburger, width: 32, height: 32}).setMouseIgnore(), new LuiText({value: "Hamburger!"}).setMouseIgnore()
	])
]);
big_button_2 = new LuiButton().addEvent(LUI_EV_CLICK, function() {oDemo.changeRingValue();}).addContent([
	new LuiRow().setMouseIgnore().addContent([
		new LuiImage({value: sBoxDemo, width: 32, height: 32}).setMouseIgnore(), new LuiText({value: "A box!"}).setMouseIgnore()
	])
]);
big_button_3 = new LuiButton().addEvent(LUI_EV_CLICK, function() {oDemo.changeRingValue();}).addContent([
	new LuiRow().setMouseIgnore().addContent([
		new LuiImage({value: sLogoDemo, width: 32, height: 32}).setMouseIgnore(), new LuiText({value: "Game Maker!"}).setMouseIgnore()
	])
]);

// Add elements to third main panel
my_panel_3.addContent([
	new LuiText({value: "Third panel", scale_to_fit: true}).setTextHalign(fa_center),
	combobox_theme,
	new LuiText({value: long_text}).setTooltip(long_text),
	big_button_1,
	big_button_2,
	big_button_3,
	new LuiProgressRing({name: "luiRing", value: 65, rounding: 1}).setFlexGrow(1)
]);

#region Fill all tab's in Tabs

	#region Add scroll panel in tab_panels

		// Create scroll panel with different elements
		tab_panels.addContent([
			new LuiText({value: "Scroll panel with different elements", scale_to_fit: true}).setTextHalign(fa_center),
			new LuiScrollPanel({name: "firstScrollPanel"}).addContent([
				
				new LuiInput({placeholder: "only numbers allowed", input_mode: LUI_INPUT_MODE.numbers, allowed_chars: "-."}).addEvent(LUI_EV_VALUE_UPDATE, function(_e) {
					if _e.get() == "" _e.setIncorrect(true) else _e.setIncorrect(false);
				}),
				new LuiPanel().addContent([
					new LuiText({value: "Nested panel 1.1"}),
					new LuiCheckbox({text: "Check me!"}).addEvent(LUI_EV_CLICK, function(_e) {
						luiShowMessage(oDemo.my_ui, , , _e.get() ? "Checkbox in nested panel of scroll panel!" : ":(");
					}),
					new LuiPanel().addContent([
						new LuiText({value: "Nested panel 2.1"}),
						new LuiRow().addContent([
							new LuiSlider({value: 25, rounding: 1}),
							new LuiText({value: "Slide me!"}),
						]),
						new LuiPanel().addContent([
							new LuiText({value: "Nested panel 3.1"}),
							new LuiText({value: "Updateble text with binded variable below"}).setTooltip("Try to change login in first panel"),
							new LuiText().bindVariable(self, "demo_login")
						])
					]),
					new LuiPanel().addContent([
						new LuiText({value: "Nested panel 2.2"}),
						new LuiButton({text: "Press me!"}),
						new LuiPanel().addContent([
							new LuiText({value: "Nested panel 3.2"}),
							new LuiRow().addContent([
								new LuiImageButton({value: sLogoDemo, width: 56, height: 56}).addEvent(LUI_EV_CLICK, function(_e) {oDemo.changeImageButtonColor(_e)}),
								new LuiText({value: "Press me!"}),
							]),
							new LuiSurface({height: 100, name: "LuiSurface", alpha: 0.5, maintain_aspect: false}).addContent([
								new LuiText().set("LuiSurface example")
							])
						])
					])
				])
			])
		]);
		
	#endregion

	#region Add elements in tab_search
		
		// Function for search system
		filterElements = function() {
			with(oDemo) {
				// Hide all
				array_foreach(search_panel.getContent(), function(_elm) {
					_elm.hide();
				});
				// Filter
				var _filtered_elements = array_filter(search_panel.getContent(), function(_elm, _ind) {
					var _elm_name = _elm.text;
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
		// Create search panel
		search_panel = new LuiScrollPanel();
		// Add random buttons to search panel
		for (var i = 1; i <= 10; i++) {
			var _btn_text = string(i) + ". " + choose("Aboba", "Microba", "Foo", "Bar", "Game maker!", "777", "123");
			search_panel.addContent([
				new LuiButton().setText(_btn_text).addEvent(LUI_EV_CLICK, function(_e) {
					oDemo.filterElements(); _e.destroy();
				})
			]);
		}
		// Add other control elements
		input_search = new LuiInput({placeholder: "Search..."}).addEvent(LUI_EV_VALUE_UPDATE, function() {
			oDemo.filterElements();
		});
		panel_control = new LuiPanel();
		input_control = new LuiInput({placeholder: "new element name"});
		control_btn_add = new LuiButton({text: "Add element"}).addEvent(LUI_EV_CLICK, function() {
			var _button_name = oDemo.input_control.get();
			oDemo.input_control.set("");
			oDemo.search_panel.addContent([
				new LuiButton().setText(_button_name).addEvent(LUI_EV_CLICK, function(_e) {
					oDemo.filterElements(); _e.destroy();
				})
			]);
		});
		control_btn_clear = new LuiButton().setText("Clear list").addEvent(LUI_EV_CLICK, function() {oDemo.search_panel.cleanScrollPanel()});
		panel_control.addContent([
			input_control,
			control_btn_add,
			control_btn_clear
		]);
		tab_search.addContent([
			new LuiRow().setFlexGrow(1).addContent([
				new LuiColumn().addContent([
					input_search,
					search_panel,
				]),
				panel_control
			])
		]);

	#endregion

	#region Add some sprites in tab_sprites
	
		spr_car_1 = new LuiImage({value: sCar, name: "sCar"}).addEvent(LUI_EV_CLICK, function(_e) {print($"Clicked on image {_e.name}!")});
		spr_car_2 = new LuiImage({value: sCar, maintain_aspect: false, name: "sCar_stretched"}).addEvent(LUI_EV_CLICK, function(_e) {print($"Clicked on image {_e.name}!")});
		spr_car_3 = new LuiImage({value: sHamburger, name: "sHamburger"}).addEvent(LUI_EV_CLICK, function(_e) {print($"Clicked on image {_e.name}!")});
		spr_car_4 = new LuiImage({value: sHamburger, maintain_aspect: false, name: "sHamburger_stretched"}).addEvent(LUI_EV_CLICK, function(_e) {print($"Clicked on image {_e.name}!")});
		tab_sprites.addContent([
			new LuiRow({height: 500}).addContent([
				spr_car_1, spr_car_2, spr_car_3, spr_car_4
			])
		]);
	
	#endregion

	#region Add info about me in tab_about
	
		sprite_limekys = new LuiImage({value: sLimekysAvatar, width: 64});
		text_about = new LuiText({value: "Hi, i am Limekys, and this is my UI system!"});
		sprite_discord = new LuiImageButton({value: sDiscord_64px, width: 64, height: 64}).setTooltip("My Discord server").addEvent(LUI_EV_CLICK, function() { url_open("https://discord.gg/3bfQdhDVkC"); });
		sprite_telegram = new LuiImageButton({value: sTelegram_64px, width: 64, height: 64}).setTooltip("My Telegram channel").addEvent(LUI_EV_CLICK, function() { url_open("https://t.me/+iOeTrZOG8QhiZTQ6"); });
		sprite_twitch = new LuiImageButton({value: sTwitch_64px, width: 64, height: 64}).setTooltip("My Twitch channel").addEvent(LUI_EV_CLICK, function() { url_open("https://www.twitch.tv/limekys"); });
		sprite_twitter = new LuiImageButton({value: sTwitter_64px, width: 64, height: 64}).setTooltip("My X (Twitter)").addEvent(LUI_EV_CLICK, function() { url_open("https://x.com/Limekys"); });
		sprite_vk = new LuiImageButton({value: sVkontakte_64px, width: 64, height: 64}).setTooltip("My VK group").addEvent(LUI_EV_CLICK, function() { url_open("https://vk.com/limekys_games"); });
		sprite_youtube = new LuiImageButton({value: sYoutube_64px, width: 64, height: 64}).setTooltip("My Youtube channel").addEvent(LUI_EV_CLICK, function() { url_open("https://www.youtube.com/@Limekys"); });
		sprite_donate = new LuiImageButton({value: sDonate, width: 64, height: 64}).setTooltip("Donate!").addEvent(LUI_EV_CLICK, function() { url_open("https://www.donationalerts.com/r/limekys"); });
		text_version = new LuiText({value: "LimeUI version: " + LIMEUI_VERSION}).setFlexGrow(1).setTextValign(fa_bottom).setTextHalign(fa_right);
		
		tab_about.addContent([
			new LuiRow({height: 64}).addContent([
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
	new LuiButton({text: "Next demo -->", width: 256}).setPositionAbsolute().setPosition(, , 16, 16).addEvent(LUI_EV_CLICK, function() {
		room_goto(rDemo2);
	})
]);

// Stress test
/*
numb = 0;
_random_element = function(_number) {
	var _rnd = irandom(7);
	switch (_rnd) {
		case 0:	return new LuiButton(, , , irandom_range(32, 128), , "button_" + string(_number)).setColor(make_color_hsv(irandom(255), irandom_range(128,255), 128));
		case 1:	return new LuiImageButton(, , , irandom_range(32, 128), , sLogoDemo, 0, make_color_hsv(irandom(255), irandom_range(128,255), 255), 1, choose(true, false)).addEvent(LUI_EV_CLICK, function(_element) {oDemo.changeImageButtonColor(_element)});;
		case 2:	return new LuiSlider(, , , irandom_range(32, 128), , 0, _number, irandom(_number), choose(25,10,5,2,1,0.5,0.1,0.01));
		case 3:	return new LuiInput(, , , irandom_range(32, 128), , , "input_" + string(_number));
		case 4:	return new LuiProgressRing(, , , irandom_range(32, 128), , 0, _number, choose(true, false), irandom(_number), choose(25,10,5,2,1,0.5,0.1,0.01));
		case 5:	return new LuiCheckbox(, , , irandom_range(32, 128), , choose(true, false), choose("checkbox_" + string(_number), ""));
		case 6:	return new LuiToggleSwitch(, , , irandom_range(32, 128), , choose(true, false), choose("switch_" + string(_number), ""));
		case 7:	return new LuiToggleButton(, , , irandom_range(32, 128), , choose(true, false), "toggleButton_" + string(_number));
	}
}
repeat (250) {
	my_ui.getElement("firstScrollPanel").addContent([
		new LuiRow().addContent([
			_random_element(numb++), _random_element(numb++), _random_element(numb++), _random_element(numb++), [random_range(0.1, 0.3), random_range(0.1, 0.3), random_range(0.1, 0.3)]
		])
	])
}