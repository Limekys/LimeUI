///@desc CREATE STYLES AND UI

// Init debug variables
debug_overlay = false;
debug_grid = false;

// Init demo variables
demo_login = "";
demo_password = "";
long_text = "This is a really long text that probably won't fit in this element!";

// Create Light style theme
demo_style_light = new LuiStyle()
	.setSettings(32, 32, 16, 0, 32, {left : 0, right : 0, top : 1, bottom : 3}, "|", "•")
	.setFonts(fDemo, fDemo, fDebug)
	.setSprites(sUI_panel, sUI_panel_border,  sUI_button, sUI_button_border, sUI_checkbox_pin, sUI_dropdown_arrow, sRing)
	.setSpriteTabGroup(sUI_tabgroup, sUI_tabgroup_border, sUI_tab, sUI_tab_border)
	.setColors(c_white, merge_colour(c_white, c_black, 0.5), c_white, merge_colour(c_white, c_black, 0.5), #45C952, merge_colour(c_black, c_white, 0.2), c_gray, c_gray)
	.setSounds(sndBasicClick);

// Create Dark style theme
demo_style_dark = new LuiStyle()
	.setSettings(32, 32, 16, 0, 32, {left : 0, right : 0, top : 1, bottom : 3}, "|", "•")
	.setFonts(fDemo, fDemo, fDebug)
	.setSprites(sUI_panel, sUI_panel_border,  sUI_button, sUI_button_border, sUI_checkbox_pin, sUI_dropdown_arrow, sRing)
	.setSpriteTabGroup(sUI_tabgroup, sUI_tabgroup_border, sUI_tab, sUI_tab_border)
	.setColors(#393c4f, merge_color(#393c4f, c_black, 0.5), #393c4f, merge_color(#393c4f, c_black, 0.5), #3a7d44, merge_color(c_white, #393c4f, 0.2), #77726e, c_gray)
	.setSounds(sndBasicClick);

// Create Modern style theme
demo_style_modern = new LuiStyle()
	.setSettings(32, 32, 16, 0, 32, {left : 0, right : 0, top : 0, bottom : 0}, "|", "*")
	.setFonts(fModern, fModern, fDebug)
	.setSprites(sUI_Square_21r, ,  sUI_Square_6r, , sUI_checkbox_pin, sUI_dropdown_arrow, sRing)
	.setColors(#393a44, , merge_color(#393a44, c_white, 0.1), , #64d0b9, #ffffff, #9a9daf, c_gray)
	.setSounds(sndBasicClick);

// Create the main ui container
my_ui = new LuiMain().setStyle(demo_style_dark);

//Create some panels
my_panel = new LuiPanel( , , , 512, "LuiPanel_1");
my_panel_2 = new LuiPanel( , , , 512, "LuiPanel_2");
my_panel_3 = new LuiPanel( , , , 512, "LuiPanel_3");

// Create TabGroup with absolute position on the screen
tab_group = new LuiTabGroup( , , 550, 332, "LuiTabGroup", 46).setPositionType(flexpanel_position_type.absolute);

// Add panels to main ui container
my_ui.addContent([
	new LuiFlexRow().addContent([
		my_panel, my_panel_2, my_panel_3, [0.4, 0.4, 0.2] // Add panels with a width ratio of 40% 40% and 20%
	]),
	tab_group //Adding tab group below these panels (it doesn't matter if we add it before or after, it has an absolute position)
]);

// Create tabs for tabGroup
tab_panels = new LuiTab("tabPanels", "Panels").setIcon(sIconMenu, 0.5);
tab_search = new LuiTab("tabSearch", "Search").setIcon(sIconSearch, 0.5);
tab_sprites = new LuiTab("tabSprites", "Sprites").setIcon(sIconPalette, 0.5);
tab_about = new LuiTab("tabAbout", "About").setIcon(sIconInfo, 0.5);

// Add tabs to tabgroup
tab_group.addTabs([tab_panels, tab_search, tab_sprites, tab_about]);

// Adjust TabGroup position on the screen
tab_group_min_x = 16;
tab_group_max_x = room_width - tab_group.width;
tab_group_min_y = 200;
tab_group_max_y = room_height - tab_group.height;
tab_group_target_x = tab_group_min_x;
tab_group_target_y = my_panel.y + my_panel.height + my_ui.style.padding*2;

// Create some elements
demo_loading = new LuiProgressBar( , , , , , 0, 100, true, 0, 1);
demo_loading_state = false;
btn_show_msg = new LuiButton(, , , , "btnMessage", "Show message", function() {
	showLuiMessage(oDemo.my_ui, , , "Login: " + oDemo.demo_login + "\n" + "Password: " + oDemo.demo_password, "Got it!");
});
btn_restart = new LuiButton( , , , , "btnRestart", "Restart", function() {
	game_restart();
});

// Add elements to first panel and init some new here
my_panel.addContent([
	new LuiText( , , , , , "First panel", true).setTextHalign(fa_center),
	new LuiFlexRow().addContent([
		new LuiText( , , , , , "Panel X"), new LuiSlider( , , , , "sliderX", tab_group_min_x, tab_group_max_x, 0, 1).setBinding(oDemo, "tab_group_target_x"), [0.2, 0.8]
	]),
	new LuiFlexRow().addContent([
		new LuiText( , , , , , "Panel Y"), new LuiSlider( , , , , "sliderY", tab_group_min_y, tab_group_max_y, 0, 1).setBinding(oDemo, "tab_group_target_y"), [0.2, 0.8]
	]),
	new LuiFlexRow().addContent([
		new LuiCheckbox( , , 32, , , false).setBinding(oDemo, "demo_loading_state").setTooltip("Start a demo progressbar"), demo_loading
	]),
	new LuiFlexRow().addContent([
		new LuiText( , , , , , "Login: "), new LuiTextbox( , , , , , , "admin", false).setBinding(oDemo, "demo_login"), [0.2, 0.8]
	]),
	new LuiFlexRow().addContent([
		new LuiText( , , , , , "Password: "), new LuiTextbox( , , , , , , "qwerty12345", true).setBinding(oDemo, "demo_password"), [0.2, 0.8]
	]),	
	new LuiFlexRow().addContent([
		new LuiText( , , , , , "Slider with rounding 10"), new LuiSlider( , , , , "SliderRounding", 0, 100, 20, 10)
	]),
	new LuiFlexRow().addContent([
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
	self.setColorBlend(merge_color(make_color_hsv(random(255), 255, 255), c_white, 0.5));
}
var _sprite_buttons = [];
for (var i = 0; i < 8; ++i) {
    var _button = new LuiSpriteButton( , , 70, 56, $"sprGMSLogo_{i}", sLogoDemo, 0, c_white, 1, i mod 2 == 0 ? true : false, changeButtonColor);
	array_push(_sprite_buttons, _button);
}

// Add array with sprite buttons to second panel of second main panel
my_panel_in_second_2.addContent([
	new LuiText( , , , , , "Panel with sprites buttons"),
	new LuiFlexRow().setFlexJustifyContent(flexpanel_justify.space_around).setFlexWrap(flexpanel_wrap.wrap).addContent(
		_sprite_buttons
	)
]);

// Then add all together to second panel
my_panel_2.addContent([
	new LuiText( , , , , , "Second panel", true).setTextHalign(fa_center),
	new LuiPanel().addContent([
		new LuiText( , , , , , "Panel in panel").setTextHalign(fa_center),
		new LuiFlexRow().addContent([
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
dropdown_menu = new LuiDropDown(, , , , , "Select theme...").set("Dark").setTooltip("Change UI theme\nWIP");
drop_item1 = new LuiDropDownItem( , "Dark", function() {
	with(oDemo) {
		my_ui.setStyle(demo_style_dark);
		var _b = layer_background_get_id("bgColor");
		layer_background_blend(_b, #191919);
		var _b = layer_background_get_id("bgSprites");
		layer_background_blend(_b, #333333);
		layer_background_visible(_b, true);
		//Set colors to buttons 
		btn_show_msg.setColor(merge_color(#ffff77, c_black, 0.5));
		btn_restart.setColor(merge_color(#ff7777, c_black, 0.5));
	}
});
drop_item2 = new LuiDropDownItem( , "Light", function() {
	with(oDemo) {
		my_ui.setStyle(demo_style_light);
		var _b = layer_background_get_id("bgColor");
		layer_background_blend(_b, c_ltgray);
		var _b = layer_background_get_id("bgSprites");
		layer_background_blend(_b, c_white);
		layer_background_visible(_b, true);
		//Set colors to buttons
		btn_show_msg.setColor(merge_color(#ffff77, c_black, 0.1));
		btn_restart.setColor(merge_color(#ff7777, c_black, 0.1));
	}
});
drop_item3 = new LuiDropDownItem( , "Modern", function() { 
	with(oDemo) {
		my_ui.setStyle(demo_style_modern);
		var _b = layer_background_get_id("bgColor");
		layer_background_blend(_b, #32333d);
		var _b = layer_background_get_id("bgSprites");
		layer_background_visible(_b, false);
		//Set colors to buttons 
		btn_show_msg.setColor(merge_color(#fa9a31, c_white, 0.25));
		btn_restart.setColor(merge_color(#e5538d, c_white, 0.25));
	}
});
dropdown_menu.addItems([drop_item1, drop_item2, drop_item3]);

// Create big buttons with sprite and text
// In each button we adding sprite and text with ignore mouse hovering
// And we get big buttons with icon and text
changeRingValue = function() {
	oDemo.my_ui.getElement("luiRing").set(irandom(100));
}
big_button_1 = new LuiButton().setCallback(changeRingValue).addContent([
	new LuiFlexRow().setMouseIgnore().addContent([
		new LuiSprite(, , 32, 32, , sHamburger).setMouseIgnore(), new LuiText(, , , , , "Hamburger!").setMouseIgnore()
	])
]);
big_button_2 = new LuiButton().setCallback(changeRingValue).addContent([
	new LuiFlexRow().setMouseIgnore().addContent([
		new LuiSprite(, , 32, 32, , sBoxDemo).setMouseIgnore(), new LuiText(, , , , , "A box!").setMouseIgnore()
	])
]);
big_button_3 = new LuiButton().setCallback(changeRingValue).addContent([
	new LuiFlexRow().setMouseIgnore().addContent([
		new LuiSprite(, , 32, 32, , sLogoDemo).setMouseIgnore(), new LuiText(, , , , , "Game Maker!").setMouseIgnore()
	])
]);

// Add elements to third main panel
my_panel_3.addContent([
	new LuiText( , , , , , "Third panel", true).setTextHalign(fa_center),
	dropdown_menu,
	new LuiText(, , , , , long_text).setTooltip(long_text),
	big_button_1,
	big_button_2,
	big_button_3,
	new LuiProgressRing( , , , , "luiRing", 0, 100, true, 65, 1).setFlexGrow(1)
]);

#region Fill all tabs in tabGroup

	#region Add scroll panel in tab_panels

		// Create scroll panel with different elements
		tab_panels.addContent([
			new LuiScrollPanel(, , , , "firstScrollPanel").addContent([
				new LuiText( , , , , , "Scroll panel with different elements", true).setTextHalign(fa_center),
				new LuiTextbox(, , , , , , "textbox in scroll panel"),
				new LuiPanel( , , , , "Panel in scroll panel").addContent([
					new LuiText(, , , , , "Nested panel x1"),
					new LuiButton( , , , , , "Nested button"),
					new LuiFlexRow().addContent([
						new LuiCheckbox( , , 32, , , false, function() {
							showLuiMessage(oDemo.my_ui, , , get() ? "Checkbox in nested panel of scroll panel!" : ":(");
						}),
						new LuiText(, , , , , "Check me!"),
					]),
					new LuiPanel(, , , , "Nested panel x2").addContent([
						new LuiText(, , , , , "Nested panel x2"),
						new LuiFlexRow().addContent([
							new LuiSlider( , , , , , 0, 100, 25, 1),
							new LuiText(, , , , "txtSlideMe", "Slide me!"),
						]),
						new LuiPanel(, , , , "Nested panel x3").addContent([
							new LuiText(, , , , , "Updateble text with binding variable below").setTooltip("Try to change login in first panel"),
							new LuiText(, , , , , ).setBinding(oDemo, "demo_login")
						])
					])
				]),
				new LuiSprite( , , , 100, , sCarFlip),
				new LuiSprite( , , , 256, , sHamburger),
				new LuiSprite( , , , 200, , sCar),
				new LuiSprite( , , , 128, , sHamburger, , , , false),
			])
		]);
		
	#endregion

// Stress test
//numb = 0;
//repeat (1000) {
	//numb++;
	//my_ui.getElement("firstScrollPanel").addContent([
		//choose(
			//new LuiButton(, , , , , string(numb)), 
			//new LuiSprite(, , , , , sLogoDemo, , make_color_hsv(irandom(255), 255, 255), , choose(true, false)),
			//new LuiSlider(, , , , , 0, 100, numb, 1),
			//new LuiTextbox(, , , , , choose("", "aboba", string(numb)), choose("", "aboba", string(numb))),
		//)
	//])
//}

	#region Add elements in tab_search
		
		// Function for buttons
		deleteSelf = function() {
			self.destroy(); oDemo.filterElements()
		};
		// Function for search system
		filterElements = function() {
			with(oDemo) {
				// Hide all
				array_foreach(search_panel.scroll_container.content, function(_elm) {
					_elm.setVisible(false);
					flexpanel_node_style_set_display(_elm.flex_node, flexpanel_display.none);
				});
				// Filter
				var _filtered_elements = array_filter(search_panel.scroll_container.content, function(_elm) {
					var _elm_name = _elm.get();
					var _search_string = textbox_search.get();
					var _founded = string_pos(string_lower(_search_string), string_lower(_elm_name));
					if _founded != 0 return true;
					return false;
				});
				// Show filtered elements
				for (var i = 0, n = array_length(_filtered_elements); i < n; ++i) {
				    var _element = _filtered_elements[i];
					_element.setVisible(true);
					flexpanel_node_style_set_display(_element.flex_node, flexpanel_display.flex);
				}
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
		textbox_search = new LuiTextbox(, , , , "textboxSearch", , "Search...", , 256, filterElements);
		control_panel = new LuiPanel(, , , , "ControlPanel");
		control_textbox = new LuiTextbox(, , , , , , "new element name", false, 32);
		control_btn_add = new LuiButton(, , , , , "Add element", function() {
			var _button_name = oDemo.control_textbox.get();
			oDemo.control_textbox.set("");
			oDemo.search_panel.addContent(new LuiButton(, , , , , _button_name, oDemo.deleteSelf));
		});
		control_btn_clear = new LuiButton(, , , , , "Clear list", function() {oDemo.search_panel.cleanScrollPanel()});
		control_panel.addContent([
			control_textbox,
			control_btn_add,
			control_btn_clear
		]);
		tab_search.addContent([
			new LuiFlexRow().setFlexGrow(1).addContent([
				new LuiFlexColumn().addContent([
					textbox_search,
					search_panel,
				]),
				control_panel
			])
		]);
	
	#endregion

	#region Add some sprites in tab_sprites
	
		sprite_car_1 = new LuiSprite( , , , , , sCar);
		sprite_car_2 = new LuiSprite( , , , , , sCar, , , , false);
		sprite_car_3 = new LuiSprite( , , , , , sCarFlip);
		sprite_car_4 = new LuiSprite( , , , , , sCarFlip, , , , false);
		tab_sprites.addContent([
			new LuiFlexRow( , , , 500).addContent([
				sprite_car_1, sprite_car_2, sprite_car_3, sprite_car_4
			])
		]);
	
	#endregion

	#region Add info about me in tab_about
	
		sprite_limekys = new LuiSprite(, , 64, 64, "sprLimekys", sLimekysAvatar);
		text_about = new LuiText(, , , 64, "textAbout", "Hi, i am Limekys, and this is my UI system!");
		sprite_discord = new LuiSpriteButton(, , , 64, "sprDiscord", sDiscord_64px, , , , , function() {url_open("https://discord.gg/3bfQdhDVkC")}).setTooltip("My Discord server");
		sprite_telegram = new LuiSpriteButton(, , , 64, "sprTelegram", sTelegram_64px, , , , , function() {url_open("https://t.me/+iOeTrZOG8QhiZTQ6")}).setTooltip("My Telegram channel");
		sprite_twitch = new LuiSpriteButton(, , , 64, "sprTwitch", sTwitch_64px, , , , , function() {url_open("https://www.twitch.tv/limekys")}).setTooltip("My Twitch channel");
		sprite_twitter = new LuiSpriteButton(, , , 64, "sprTwitter", sTwitter_64px, , , , , function() {url_open("https://x.com/Limekys")}).setTooltip("My X (Twitter)");
		sprite_vk = new LuiSpriteButton(, , , 64, "sprVK", sVkontakte_64px, , , , , function() {url_open("https://vk.com/limekys_games")}).setTooltip("My VK group");
		sprite_youtube = new LuiSpriteButton(, , , 64, "sprYT", sYoutube_64px, , , , , function() {url_open("https://www.youtube.com/@Limekys")}).setTooltip("My Youtube channel");
		text_version = new LuiText(, , , , "textLimeUIVersion", "LimeUI version: " + LIMEUI_VERSION).setValign(fa_bottom);
		
		tab_about.addContent([
			new LuiFlexRow().addContent([
				sprite_limekys, text_about
			]),
			new LuiFlexRow().addContent([
				sprite_discord, sprite_telegram, sprite_twitch, sprite_twitter, sprite_vk, sprite_youtube
			]),
			text_version
		]);
	
	#endregion

#endregion

// Create buttons to go another demo room
my_ui.addContent([
	new LuiButton(room_width - 256 - my_ui.style.padding, room_height - 32 - my_ui.style.padding, 256, , "buttonNextDemo", "Next demo -->", function() {
		room_goto(rDemo2);
	}).setPositionType(flexpanel_position_type.absolute),
]);