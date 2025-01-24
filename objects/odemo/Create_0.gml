///@desc CREATE STYLES AND UI

#region Init debug variables

randomize();
debug_overlay = false;
debug_grid = false;

#endregion

#region Init demo variables

demo_login = "";
demo_password = "";
long_text = "This button with a really long text that probably won't fit in this element!";

#endregion

#region Create styles

//Light theme
demo_style_light = {
	//Fonts
	font_default : fDemo,
	font_buttons : fDemo,
	font_sliders : fDemo,
	font_debug : fDebug,
	//Sprites
	sprite_panel : sUI_panel,
	sprite_panel_border : sUI_panel_border,
	sprite_textbox : sUI_textbox,
	sprite_textbox_border : sUI_textbox_border,
	sprite_button : sUI_button,
	sprite_button_border : sUI_button_border,
	sprite_checkbox : sUI_button,
	sprite_checkbox_pin : sUI_checkbox_pin,
	sprite_checkbox_border : sUI_button_border,
	sprite_progress_bar : sUI_panel,
	sprite_progress_bar_value : sUI_panel,
	sprite_progress_bar_border : sUI_panel_border,
	sprite_slider_knob : sUI_panel,
	sprite_slider_knob_border : sUI_panel_border,
	sprite_scroll_slider : sUI_scroll_slider,
	sprite_scroll_slider_back : sUI_scroll_slider,
	sprite_dropdown : sUI_button,
	sprite_dropdown_border : sUI_button_border,
	sprite_dropdown_item : sUI_button,
	sprite_tooltip : sUI_panel,
	sprite_tooltip_border : sUI_panel_border,
	sprite_dropdown_arrow : sUI_dropdown_arrow,
	sprite_tab : sUI_tab,
	sprite_tab_border : sUI_tab_border,
	sprite_tabgroup : sUI_tabgroup,
	sprite_tabgroup_border : sUI_tabgroup_border,
	//Colors
	color_font : merge_colour(c_black, c_white, 0.2),
	color_font_hint : c_gray,
	color_main : c_white,
	color_border : merge_colour(c_white, c_black, 0.5),
	color_button : c_white,
	color_button_border : merge_colour(c_white, c_black, 0.5),
	color_hover : c_gray,
	color_checkbox : c_white,
	color_checkbox_pin : #45C952,
	color_checkbox_border : merge_colour(c_white, c_black, 0.5),
	color_progress_bar : c_white,
	color_progress_bar_value : #45C952,
	color_progress_bar_border : merge_colour(c_white, c_black, 0.5),
	color_textbox : c_white,
	color_textbox_border : merge_colour(c_white, c_dkgray, 0.5),
	color_scroll_slider : c_white,
	color_scroll_slider_back : c_gray,
	color_dropdown : c_white,
	color_dropdown_border : merge_colour(c_white, c_black, 0.5),
	color_dropdown_item : c_white,
	color_dropdown_arrow : merge_colour(c_white, c_black, 0.5),
	color_tooltip : c_white,
	color_tooltip_border : merge_colour(c_white, c_black, 0.5),
	//Sounds
	sound_click : sndBasicClick,
	//Settings
	default_min_width : 32,
	default_min_height : 32,
	padding : 16,
	checkbox_pin_margin : 0,
	scroll_step : 32,
	scroll_region_offset : [0,0,1,3],
	textbox_cursor : "|",
	textbox_password : "•"
                                                                    }; // TEMP: Just for fix stupid feather >_<

//Dark theme
demo_style_dark = {
	//Fonts
	font_default : fDemo,
	font_buttons : fDemo,
	font_sliders : fDemo,
	font_debug : fDebug,
	//Sprites
	sprite_panel : sUI_panel,
	sprite_panel_border : sUI_panel_border,
	sprite_textbox : sUI_textbox,
	sprite_textbox_border : sUI_textbox_border,
	sprite_button : sUI_button,
	sprite_button_border : sUI_button_border,
	sprite_checkbox : sUI_button,
	sprite_checkbox_pin : sUI_checkbox_pin,
	sprite_checkbox_border : sUI_button_border,
	sprite_progress_bar : sUI_panel,
	sprite_progress_bar_value : sUI_panel,
	sprite_progress_bar_border : sUI_panel_border,
	sprite_slider_knob : sUI_panel,
	sprite_slider_knob_border : sUI_panel_border,
	sprite_scroll_slider : sUI_scroll_slider,
	sprite_scroll_slider_back : sUI_scroll_slider,
	sprite_dropdown : sUI_button,
	sprite_dropdown_border : sUI_button_border,
	sprite_dropdown_item : sUI_button,
	sprite_tooltip : sUI_panel,
	sprite_tooltip_border : sUI_panel_border,
	sprite_dropdown_arrow : sUI_dropdown_arrow,
	sprite_tab : sUI_tab,
	sprite_tab_border : sUI_tab_border,
	sprite_tabgroup : sUI_tabgroup,
	sprite_tabgroup_border : sUI_tabgroup_border,
	//Colors
	color_font : merge_color(c_white, #393c4f, 0.2),
	color_font_hint : #77726e,
	color_main : #393c4f,
	color_border : merge_color(#393c4f, c_black, 0.5),
	color_button : #393c4f,
	color_button_border : merge_color(#393c4f, c_black, 0.5),
	color_hover : c_gray,
	color_checkbox : #393c4f,
	color_checkbox_pin : #3a7d44,
	color_checkbox_border : merge_color(#393c4f, c_black, 0.5),
	color_progress_bar : #393c4f,
	color_progress_bar_value : #3a7d44,
	color_progress_bar_border : merge_color(#393c4f, c_black, 0.5),
	color_textbox : #393c4f,
	color_textbox_border : merge_color(#393c4f, c_black, 0.5),
	color_scroll_slider : #393c4f,
	color_scroll_slider_back : merge_color(#393c4f, c_black, 0.5),
	color_dropdown : #393c4f,
	color_dropdown_border : merge_color(#393c4f, c_black, 0.5),
	color_dropdown_item : #393c4f,
	color_dropdown_arrow : merge_color(#393c4f, c_black, 0.5),
	color_tooltip : c_black,
	color_tooltip_border : c_black,
	//Sounds
	sound_click : sndBasicClick,
	//Settings
	default_min_width : 32,
	default_min_height : 32,
	padding : 16,
	checkbox_pin_margin : 0,
	scroll_step : 32,
	scroll_region_offset : [0,0,1,3],
	textbox_cursor : "|",
	textbox_password : "•",
	//Render functions
	//sprite_render_function : function(_sprite, _subimg, _x, _y, _width, _height, _color, _alpha) {
	//	draw_sprite_stretched_ext(_sprite, _subimg, _x, _y, _width, _height, _color, _alpha);
	//}
                                                                    }; // TEMP: Just for fix stupid feather >_<

//Modern theme
demo_style_modern = {
	//Fonts
	font_default : fModern,
	font_buttons : fModern,
	font_sliders : fModern,
	font_debug : fDebug,
	//Sprites
	sprite_panel : sUI_Square_21r,
	sprite_textbox : sUI_Square_6r,
	sprite_button : sUI_Square_6r,
	sprite_checkbox : sUI_Square_6r,
	sprite_checkbox_pin : sUI_checkbox_pin,
	sprite_progress_bar : sUI_Square_6r,
	sprite_progress_bar_value : sUI_Square_6r,
	sprite_slider_knob : sUI_Square_6r,
	sprite_scroll_slider : sUI_scroll_slider,
	sprite_scroll_slider_back : sUI_scroll_slider,
	sprite_dropdown : sUI_Square_6r,
	sprite_dropdown_item : sUI_Square_6r,
	sprite_dropdown_item_border : sUI_Square_6r_dropdown_item_border,
	sprite_dropdown_arrow : sUI_dropdown_arrow,
	sprite_tab : sUI_Square_21r,
	sprite_tabgroup : sUI_Square_21r,
	sprite_tooltip : sUI_Square_6r,
	//Colors
	color_font : #ffffff,
	color_font_hint : #9a9daf,
	color_main : #393a44,
	color_button : #4d515e,
	color_hover : c_gray,
	color_checkbox : #4d515e,
	color_checkbox_pin : #64d0b9,
	color_progress_bar : #4d515e,
	color_progress_bar_value : #64d0b9,
	color_textbox : #4d515e,
	color_scroll_slider : #4d515e,
	color_scroll_slider_back : merge_color(#4d515e, c_black, 0.5),
	color_dropdown : #4d515e,
	color_dropdown_item : #4d515e,
	color_dropdown_item_border : merge_color(#4d515e, c_black, 0.5),
	color_dropdown_arrow : merge_color(#4d515e, c_black, 0.5),
	//Sounds
	sound_click : sndBasicClick,
	//Settings
	default_min_width : 32,
	default_min_height : 32,
	padding : 16,
	checkbox_pin_margin : 0,
	scroll_step : 32,
	scroll_region_offset : [0,0,0,0],
	textbox_cursor : "|",
	textbox_password : "*"
                                                                    }; // TEMP: Just for fix stupid feather >_<

#endregion

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
	tab_group //Adding tab group below these panels
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
		new LuiText( , , , , , "Panel X"), new LuiSlider( , , , , "sliderX", tab_group_min_x, tab_group_max_x, 0, 0).setBinding(oDemo, "tab_group_target_x"), [0.2, 0.8]
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

// Create two arrays with sprite buttons and function to change its color
changeButtonColor = function() {
	self.setColorBlend(merge_color(make_color_hsv(random(255), 255, 255), c_white, 0.5));
}
var _buttons1 = [], _buttons2 = [];
for (var i = 0; i < 8; ++i) {
    var _button = new LuiSpriteButton( , , , 56, $"sprGMSLogo_{i}", sLogoDemo, 0, c_white, 1, i < 4 ? true : false, changeButtonColor);
	if i < 4 array_push(_buttons1, _button);
	else
	array_push(_buttons2, _button);
}

// Add these two arrays to second panel of second main panel
// Since these are arrays with buttons, they will be added each in a row
my_panel_in_second_2.addContent([
	new LuiText( , , , , , "Panel with sprites buttons"),
	new LuiFlexRow().addContent(_buttons1),
	new LuiFlexRow().addContent(_buttons2)
]).setVisible(false)

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
big_button_1 = new LuiButton().addContent([
	new LuiFlexRow().setMouseIgnore().addContent([
		new LuiSprite(, , 32, 32, , sHamburger).setMouseIgnore(), new LuiText(, , , , , "Hamburger!").setMouseIgnore()
	])
]);
big_button_2 = new LuiButton().addContent([
	new LuiFlexRow().setMouseIgnore().addContent([
		new LuiSprite(, , 32, 32, , sBoxDemo).setMouseIgnore(), new LuiText(, , , , , "A box!").setMouseIgnore()
	])
]);
big_button_3 = new LuiButton().addContent([
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
	big_button_3
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
							new LuiText(, , , , , "Slide me!"),
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
				new LuiSprite( , , , 128, , sHamburger),
			])
		]);
		
	#endregion

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
			new LuiFlexRow().addContent([
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