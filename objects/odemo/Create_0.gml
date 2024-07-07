randomize();
debug_overlay = false;
debug_grid = false;

//Light theme
global.demo_style_light = {
	//Fonts
	font_default : fArial,
	font_buttons : fArial,
	font_sliders : fArial,
	font_debug : fDebug,
	//Colors
	color_font : c_black,
	color_font_hint : c_gray,
	color_main : c_white,
	color_border : merge_colour(c_white, c_black, 0.5),
	color_button : c_white,
	color_button_border : merge_colour(c_white, c_black, 0.5),
	color_hover : c_ltgray,
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
	color_dropdown_arrow : merge_colour(c_white, c_black, 0.5),
	//Sprites
	sprite_panel : sUI_panel,
	sprite_panel_border : sUI_panel_border,
	sprite_textbox : sUI_textbox,
	sprite_textbox_border : sUI_textbox_border,
	sprite_button : sUI_button,
	sprite_button_border : sUI_button_border,
	sprite_checkbox : sUI_button,
	sprite_checkbox_pin : sUI_button,
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
	//sprite_dropdown_item_border : sUI_button_border,
	sprite_dropdown_arrow : sUI_dropdown_arrow,
	sprite_tab : sUI_tab,
	sprite_tab_border : sUI_tab_border,
	sprite_tabgroup : sUI_tabgroup,
	sprite_tabgroup_border : sUI_tabgroup_border,
	//Sounds
	sound_click : sndBasicClick,
	//Settings
	default_min_width : 32,
	default_min_height : 32,
	padding : 16,
	checkbox_pin_margin : 6,
	scroll_step : 32,
	scroll_surface_offset : [0,0,1,3],
	textbox_cursor : "|",
	textbox_password : "•"
}

//Dark theme
global.demo_style_dark = {
	//Fonts
	font_default : fArial,
	font_buttons : fArial,
	font_sliders : fArial,
	font_debug : fDebug,
	//Colors
	color_font : merge_color(c_white, #393c4f, 0.1),
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
	color_dropdown_arrow : merge_color(#393c4f, c_black, 0.5),
	//Sprites
	sprite_panel : sUI_panel,
	sprite_panel_border : sUI_panel_border,
	sprite_textbox : sUI_textbox,
	sprite_textbox_border : sUI_textbox_border,
	sprite_button : sUI_button,
	sprite_button_border : sUI_button_border,
	sprite_checkbox : sUI_button,
	sprite_checkbox_pin : sUI_button,
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
	//sprite_dropdown_item_border : sUI_button_border,
	sprite_dropdown_arrow : sUI_dropdown_arrow,
	sprite_tab : sUI_tab,
	sprite_tab_border : sUI_tab_border,
	sprite_tabgroup : sUI_tabgroup,
	sprite_tabgroup_border : sUI_tabgroup_border,
	//Sounds
	sound_click : sndBasicClick,
	//Settings
	default_min_width : 32,
	default_min_height : 32,
	padding : 16,
	checkbox_pin_margin : 6,
	scroll_step : 32,
	scroll_surface_offset : [0,0,1,3],
	textbox_cursor : "|",
	textbox_password : "•",
	//Render functions
	//sprite_render_function : function(_sprite, _subimg, _x, _y, _width, _height, _color, _alpha) {
	//	draw_sprite_stretched_ext(_sprite, _subimg, _x, _y, _width, _height, _color, _alpha);
	//}
}

//Create the main ui container
my_ui = new LuiMain().setStyle(global.demo_style_dark);

//Create some panels
my_panel = new LuiPanel( , , , 512, "LuiPanel_1");
my_panel_2 = new LuiPanel( , , , 512, "LuiPanel_2");
my_panel_3 = new LuiPanel( , , , 512, "LuiPanel_3");
tab_group = new LuiTabGroup( , , 550, 332, "LuiTabGroup", 32);

//Add main panels to main ui container
my_ui.addContent([
	[my_panel, my_panel_2, my_panel_3, [0.4, 0.4, 0.2]],	//Adding panels in one row with automatic width with proportions 40% 40% 20%
	tab_group												//Adding tab group below these panels
]);

//Add content to tabgroup
tab_1 = new LuiTab("tabPanels", "Panels");
tab_2 = new LuiTab("tabSprites", "Sprites");
tab_3 = new LuiTab("tabAbout", "About");
tab_group.addTabs([tab_1, tab_2, tab_3]).centerHorizontally();

//Create some elements
//setHalign and setValign allow you to set the alignment of elements in the panel
demo_loading = new LuiProgressBar( , , , , , 0, 100, true, 0);
demo_loading_state = false;
btn_show_msg = new LuiButton(16, my_panel.height - 32 - 16, , , , "Show message", function() {
	LuiShowMessage(oDemo.my_ui, 360, 140, "This is just a simple message!");
}).setValign(fa_bottom).setHalign(fa_left);
btn_restart = new LuiButton(, , , , , "Restart", function() {game_restart()}).setValign(fa_bottom).setHalign(fa_right);

//Add elements to first panel and init some here
my_panel.addContent([
	new LuiText( , , , , , "First panel").setTextHalign(fa_center),
	[new LuiText( , , , , , "Panel X"), new LuiSlider( , , , , , tab_group.start_x, room_width - tab_group.width - tab_group.style.padding, tab_group.pos_x, function(){oDemo.tab_group.pos_x = self.value}), [0.2, 0.8]],
	[new LuiText( , , , , , "Panel Y"), new LuiSlider( , , , , , tab_group.start_y, room_height - tab_group.height - tab_group.style.padding, tab_group.pos_y, function(){oDemo.tab_group.pos_y = self.value}), [0.2, 0.8]],
	[demo_loading],
	[new LuiCheckbox( , , 32, 32, , false, function() {oDemo.demo_loading_state = self.value}), new LuiText( , , , , , "Progress loading")],
	[new LuiText( , , , , , "Textbox"), new LuiTextbox( , , , , , "some text"), [0.2, 0.8]],
	new LuiTextbox( , , , , , , "login"),
	new LuiTextbox( , , , , , , "password", true),
	[btn_show_msg, btn_restart]
]);

//Set colors to buttons 
btn_show_msg.setColor(merge_color(#ffff77, c_black, 0.5));
btn_restart.setColor(merge_color(#ff7777, c_black, 0.5));

//Create some panels
my_panel_in_second_1 = new LuiPanel( , , , );
//Create deactivated button
deactivated_button = new LuiButton( , , , , , "DEACTIVATED", function() {
	destroy();
}).deactivate();
my_panel_in_second_1.addContent([
	new LuiText( , , , , , "Panel in panel").setTextHalign(fa_center),
	[new LuiButton( , , , , , "ACTIVATE", function() {oDemo.deactivated_button.activate(); oDemo.deactivated_button.text = "DELETE"}),
	new LuiButton( , , , , , "Visible", function() {
		oDemo.my_panel_in_second_2.setVisible(!oDemo.my_panel_in_second_2.visible);
	})],
	new LuiButton( , , , , , "This button with really long text that probably won't fit in this button!", ),
	deactivated_button,
]);
my_panel_in_second_2 = new LuiPanel( , , , );
//Create to arrays with sprite buttons
var _buttons1 = []
var _buttons2 = []
for (var i = 0; i < 10; ++i) {
    var _button = new LuiSpriteButton( , , , 56, $"sprGMSLogo_{i}", sLogoDemo, 0, c_white, 1, i < 5 ? true : false, function() {self.setColorBlend(choose(#231b2a, #4e2640, #52466c))});
	if i < 5 array_push(_buttons1, _button);
	else
	array_push(_buttons2, _button);
}
//Add these to arrays to second panel of second main panel
//Since these are arrays with buttons, they will be added each in a row
my_panel_in_second_2.addContent(
	[
		new LuiText( , , , , , "Panel with sprites buttons"),
		_buttons1,
		_buttons2
	]
);
//my_panel_in_second_2.addContent([_buttons1, _buttons2]);
//my_panel_in_second_2.addContent([_buttons1]);
//my_panel_in_second_2.addContent([_buttons2]);

//Then add its to second panel
my_panel_2.addContent([
	new LuiText( , , , , , "Second panel").setTextHalign(fa_center),
	my_panel_in_second_1,
	my_panel_in_second_2
]);

//Create drop down menu and some items in it
dropdown_menu = new LuiDropDown(, , , , , "Select item...");
drop_item1 = new LuiDropDownItem( , "Item 1", function() { show_debug_message("Item 1 selected"); });
drop_item2 = new LuiDropDownItem( , "Item 2", function() { show_debug_message("Item 2 selected"); });
drop_item3 = new LuiDropDownItem( , "Item 3 with super cool description", function() { show_debug_message("Item 3 selected"); });
dropdown_menu.addItems([drop_item1, drop_item2, drop_item3]);

//Create big empty buttons (see forward why)
big_button = new LuiButton(, , , 64, , "", function() {});
big_button_2 = new LuiButton(, , , 64, , "", function() {});
big_button_3 = new LuiButton(, , , 64, , "", function() {});

//In each big button we adding sprite and text with ignore mouse hovering
//And we get big buttons with icon and text
big_button.addContent([
	[new LuiSprite(, , 32, 32, , sHamburger).ignoreMouseHover(), new LuiText(, , , , , "Hamburger!").ignoreMouseHover()]
]);
big_button_2.addContent([
	[new LuiSprite(, , 32, 32, , sBoxDemo).ignoreMouseHover(), new LuiText(, , , , , "A box!").ignoreMouseHover()]
]);
big_button_3.addContent([
	[new LuiSprite(, , 32, 32, , sLogoDemo).ignoreMouseHover(), new LuiText(, , , , , "Game Maker!").ignoreMouseHover()]
]);

//Add elements to third main panel
my_panel_3.addContent([
	new LuiText( , , , , , "Third panel").setTextHalign(fa_center),
	dropdown_menu,
	new LuiText(, , , , , "This is a really long text that probably won't fit in this window!"),
	big_button,
	big_button_2,
	big_button_3
]);

//Create scroll panel and some sprites
scroll_panel = new LuiScrollPanel(, , 300, 256, "Scroll panel");

//Add text to scroll panel
scroll_panel.addContent([
	new LuiText( , , , , , "Scroll panel")
]);

//Add some new buttons to scroll panel
var delete_self = function() {self.destroy();}
for (var i = 0; i < 5; ++i) {
    var _btn = new LuiButton( , , , , , "Button " + string(i+1), delete_self);
    var _btn2 = new LuiButton( , , , , , "Button " + string(i+1) + "_2", delete_self);
	scroll_panel.addContent([
		[_btn, _btn2]
	]);
}

//Create some panel that will be added to the scroll panel
nested_panel = new LuiPanel( , , , 330, "Panel in scroll panel");

//And add some elements to panel that is inside of scroll panel
nested_panel.addContent([
	new LuiText(, , , , , "Nested panel x1"),
	new LuiButton( , , , , , "Nested button"),
	[new LuiCheckbox( , , , , , false, function() {
		if get() == true {
			LuiShowMessage(oDemo.my_ui, 360, 140, "Checkbox in nested panel of scroll panel!");
		} else {
			LuiShowMessage(oDemo.my_ui, 360, 140, ":(");
		}
	}),
	new LuiText(, , , , , "Check me!")],
	new LuiPanel(, , , 150, "Nested panel x2").addContent([
		new LuiText(, , , , , "Nested panel x2"),
		new LuiPanel(, , , 75, "Nested panel x3").addContent([
			new LuiText(, , , , , "Nested panel x3")
		])
	])
]);

//Add moew elements to scroll panel
scroll_panel.addContent([
	new LuiTextbox(, , , , , , "textbox in scroll panel"),
	nested_panel,
	new LuiSprite( , , , 100, , sCarFlip),
	new LuiSprite( , , , 256, , sHamburger),
	new LuiSprite( , , , 200, , sCar),
	new LuiSprite( , , , 128, , sHamburger),
]);

#region Fill all tabs in tabGroup

//Add scroll panel in Tab1
control_panel = new LuiPanel(, , , 256, "ControlPanel");
control_textbox = new LuiTextbox(, , , , , , "new element name", false, 32);
control_btn_add = new LuiButton(, , , , , "Add element", function() {
	var _button_name = oDemo.control_textbox.get();
	oDemo.control_textbox.set("");
	oDemo.scroll_panel.addContent(new LuiButton(, , , , , _button_name, function(){self.destroy();}))
});
control_btn_clear = new LuiButton(, , , , , "Clear list", function() {oDemo.scroll_panel.cleanScrollPanel()});
control_panel.addContent([
	control_textbox,
	control_btn_add,
	control_btn_clear
]);
tab_1.addContent([
	[scroll_panel, control_panel]
]);

//Add some sprites in Tab 2
sprite_car_1 = new LuiSprite( , , , 256, , sCar);
sprite_car_2 = new LuiSprite( , , , 256, , sCar, , , , false);
sprite_car_3 = new LuiSprite( , , , 256, , sCarFlip);
sprite_car_4 = new LuiSprite( , , , 256, , sCarFlip, , , , false);
tab_2.addContent([[sprite_car_1, sprite_car_2, sprite_car_3, sprite_car_4]]);

//Add info about me in Tab 3
sprite_limekys = new LuiSprite(, , 64, 64, "sprLimekys", sLimekysAvatar);
text_about = new LuiText(, , , 64, "textAbout", "Hi, i am Limekys, and this is my UI system!");
sprite_discord = new LuiSpriteButton(, , , 64, "sprDiscord", sDiscord_64px, , , , , function() {url_open("https://discord.gg/3bfQdhDVkC")});
sprite_telegram = new LuiSpriteButton(, , , 64, "sprTelegram", sTelegram_64px, , , , , function() {url_open("https://t.me/+iOeTrZOG8QhiZTQ6")});
sprite_twitch = new LuiSpriteButton(, , , 64, "sprTwitch", sTwitch_64px, , , , , function() {url_open("https://www.twitch.tv/limekys")});
sprite_twitter = new LuiSpriteButton(, , , 64, "sprTwitter", sTwitter_64px, , , , , function() {url_open("https://x.com/Limekys")});
sprite_vk = new LuiSpriteButton(, , , 64, "sprVK", sVkontakte_64px, , , , , function() {url_open("https://vk.com/limekys_games")});
sprite_youtube = new LuiSpriteButton(, , , 64, , sYoutube_64px, , , , , function() {url_open("https://www.youtube.com/@Limekys")});
text_version = new LuiText(, , , , "textLimeUIVersion", "LimeUI version: " + LIMEUI_VERSION).setValign(fa_bottom);
tab_3.addContent([
	[sprite_limekys, text_about],
	[sprite_discord, sprite_telegram, sprite_twitch, sprite_twitter, sprite_vk, sprite_youtube],
	text_version
]);

#endregion