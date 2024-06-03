randomize();

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
	color_checkbox_pin : #45C952,
	color_slider : #45C952,
	color_textbox_border : merge_colour(c_white, c_dkgray, 0.5),
	color_scroll_slider : c_white,
	color_scroll_slider_back : c_gray,
	color_dropdown : c_white,
	color_dropdown_border : merge_colour(c_white, c_black, 0.5),
	//Sprites
	sprite_panel : sUI_panel,
	sprite_panel_border : sUI_panel_border,
	sprite_textbox : sUI_textbox,
	sprite_textbox_border : sUI_textbox_border,
	sprite_button : sUI_button,
	sprite_button_border : sUI_button_border,
	sprite_slider_knob : sUI_panel,
	sprite_slider_knob_border : sUI_panel_border,
	sprite_scroll_slider : sUI_scroll_slider,
	sprite_scroll_slider_back : sUI_scroll_slider,
	sprite_dropdown : sUI_dropdown,
	sprite_dropdown_border : sUI_dropdown_border,
	//Sounds
	sound_click : sndBasicClick,
	//Settings
	padding : 16,
	scroll_step : 32,
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
	color_border : #191a24,
	color_button : #393c4f,
	color_button_border : #191a24,
	color_hover : c_gray,
	color_checkbox_pin : #3a7d44,
	color_slider : #3a7d44,
	color_textbox_border : #191a24,
	color_scroll_slider : #393c4f,
	color_scroll_slider_back : #191a24,
	color_dropdown : #393c4f,
	color_dropdown_border : #191a24,
	//Sprites
	sprite_panel : sUI_panel,
	sprite_panel_border : sUI_panel_border,
	sprite_textbox : sUI_textbox,
	sprite_textbox_border : sUI_textbox_border,
	sprite_button : sUI_button,
	sprite_button_border : sUI_button_border,
	sprite_slider_knob : sUI_panel,
	sprite_slider_knob_border : sUI_panel_border,
	sprite_scroll_slider : sUI_scroll_slider,
	sprite_scroll_slider_back : sUI_scroll_slider,
	sprite_dropdown : sUI_dropdown,
	sprite_dropdown_border : sUI_dropdown_border,
	//Sounds
	sound_click : sndBasicClick,
	//Settings
	padding : 16,
	scroll_step : 32,
	textbox_cursor : "|",
	textbox_password : "•",
	//Render functions
	//sprite_render_function : function(_sprite, _subimg, _x, _y, _width, _height, _color, _alpha) {
	//	draw_sprite_stretched_ext(_sprite, _subimg, _x, _y, _width, _height, _color, _alpha);
	//}
}

//LUI_OVERLAY.style = new LuiStyle(global.demo_style_dark);

//Create the main ui container
my_ui = new LuiBase(global.demo_style_dark);

//Create main panels
my_panel = new LuiPanel( , , , 512, "LuiPanel_1");
my_panel_2 = new LuiPanel( , , , 512, "LuiPanel_2");
my_panel_3 = new LuiPanel( , , , 512, "LuiPanel_3");
my_panel_4 = new LuiPanel( , , 1000, 332, "LuiPanel_4");

//Add main panels to main ui container
my_ui.add_content([
	[my_panel, my_panel_2, my_panel_3, [0.4, 0.4, 0.2]],
	[my_panel_4]
]);

//Create some elements
//set_halign and set_valign allow you to set the alignment of elements in the panel
demo_loading = new LuiProgressBar( , , , , 0, 100, true, 0);
demo_loading_state = false;
btn_show_msg = new LuiButton(16, my_panel.height - 32 - 16, , , "Show message", function() {
	LuiShowMessage(oDemo.my_ui, 360, 140, "This is just a simple message!");
}).set_valign(fa_bottom).set_halign(fa_left);
btn_restart = new LuiButton(, , , , "Restart", function() {game_restart()}).set_valign(fa_bottom).set_halign(fa_right);

//Add elements to first panel and init some here
my_panel.add_content([
	new LuiText( , , , , "First panel").set_text_halign(fa_center),
	[new LuiText( , , , , "Panel X"), new LuiSlider( , , , , my_panel_4.pos_x, room_width - my_panel_4.width - my_panel_4.style.padding, my_panel_4.pos_x, function(){oDemo.my_panel_4.pos_x = self.value}), [0.2, 0.8]],
	[new LuiText( , , , , "Panel Y"), new LuiSlider( , , , , my_panel_4.pos_y, room_height - my_panel_4.height - my_panel_4.style.padding, my_panel_4.pos_y, function(){oDemo.my_panel_4.pos_y = self.value}), [0.2, 0.8]],
	[demo_loading],
	[new LuiText( , , , , "Progress loading"), new LuiCheckbox( , , 32, 32, false, function() {oDemo.demo_loading_state = self.value}), [0.3, 0.7]],
	[new LuiText( , , , , "Textbox"), new LuiTextbox( , , , ,"some text", , , ), [0.3, 0.7]],
	new LuiTextbox( , , , ,"", "login", , ),
	new LuiTextbox( , , , ,"", "password", true, ),
	[btn_show_msg, btn_restart]
]);

//Set colors to buttons 
//Important after adding to panel!
//Because when we add an element to another element, we assign it the style of the element we are adding it to
btn_show_msg.set_color(merge_color(#ffff77, c_black, 0.5));
btn_restart.set_color(merge_color(#ff7777, c_black, 0.5));

//Create some panels
my_panel_in_second_1 = new LuiPanel( , , , 200);
my_panel_in_second_2 = new LuiPanel( , , , 200);

//Then add its to second panel
my_panel_2.add_content([
	new LuiText( , , , , "Second panel").set_text_halign(fa_center),
	my_panel_in_second_1,
	my_panel_in_second_2
]);

//Create deactivated button
deactivated_button = new LuiButton( , , , , "DEACTIVATED", function() {
	destroy();
}).deactivate();

//Add elements and init some in first panel of second main panel
my_panel_in_second_1.add_content([
	new LuiText( , , , , "Panel in panel").set_text_halign(fa_center),
	[new LuiButton( , , , , "ACTIVATE", function() {oDemo.deactivated_button.activate(); oDemo.deactivated_button.text = "DELETE"}),
	new LuiButton( , , , , "Visible", function() {
		oDemo.my_panel_in_second_2.set_visible(!oDemo.my_panel_in_second_2.visible);
	})],
	new LuiButton( , , , , "This button with really long text that probably won't fit in this button!", ),
	deactivated_button,
]);

//Create to arrays with sprite buttons
var _buttons1 = []
var _buttons2 = []
for (var i = 0; i < 10; ++i) {
    var _button = new LuiSpriteButton( , , , 56, sLogoDemo, 0, c_white, 1, true, function() {self.set_color_blend(choose(#231b2a, #4e2640, #52466c))});
	if i < 5 array_push(_buttons1, _button);
	else
	array_push(_buttons2, _button);
}

//Add these to arrays to second panel of second main panel
//Since these are arrays with buttons, they will be added each in a row
my_panel_in_second_2.add_content(
	[
		new LuiText( , , , , "Panel with sprites buttons"), 
		_buttons1, 
		_buttons2
	]
);

//Create drop down menu and some items in it
var dropdown = new LuiDropDown(, , , , "Select item...");
dropdown.add_item("Item 1", function() { show_debug_message("Item 1 selected"); });
dropdown.add_item("Item 2", function() { show_debug_message("Item 2 selected"); });
dropdown.add_item("Item 3", function() { show_debug_message("Item 3 selected"); });

//Create big empty buttons (see forward why)
big_button = new LuiButton(, , , 64, "", function() {});
big_button_2 = new LuiButton(, , , 64, "", function() {});
big_button_3 = new LuiButton(, , , 64, "", function() {});

//Add elements to third main panel
my_panel_3.add_content([
	new LuiText( , , , , "Third panel").set_text_halign(fa_center),
	dropdown,
	new LuiText(, , , , "This is a really long text that probably won't fit in this window!"),
	big_button,
	big_button_2,
	big_button_3
]);

//In each big button we adding sprite and text with ignore mouse hovering
//And we get big buttons with icon and text
big_button.add_content([
	[new LuiSprite(, , 32, 32, sHamburger).ignore_mouse_hover(), new LuiText(, , , , "Hamburger!").ignore_mouse_hover(), [0.1, 0.8]]
])
big_button_2.add_content([
	[new LuiSprite(, , 32, 32, sBoxDemo).ignore_mouse_hover(), new LuiText(, , , , "A box!").ignore_mouse_hover(), [0.1, 0.8]]
])
big_button_3.add_content([
	[new LuiSprite(, , 32, 32, sLogoDemo).ignore_mouse_hover(), new LuiText(, , , , "Game Maker!").ignore_mouse_hover(), [0.1, 0.8]]
])

//Create scroll panel
scroll_panel = new LuiScrollPanel( , , , 300, "Scroll panel");

//Add this scroll panel and some new elements to fourth main panel
my_panel_4.add_content([
	[scroll_panel,
	new LuiSprite( , , , 300, sCar),
	new LuiSprite( , , , 100, sCarFlip)]
]);

//Create some panel that will be added to the scroll panel
var _nested_panel = new LuiPanel( , , , 160, "Panel in scroll panel");

//Add text to scroll panel
scroll_panel.add_content([
	new LuiText( , , , , "Scroll panel")
]);

//Add 3 new buttons to scroll panel
for (var i = 0; i < 3; ++i) {
    var _btn = new LuiButton( , , , , "Button_" + string(i), );
	scroll_panel.add_content(_btn);
}

//Add moew elements to scroll panel
scroll_panel.add_content([
	new LuiTextbox(, , , , , "textbox in scroll panel"),
	_nested_panel,
	new LuiSprite( , , , 100, sCarFlip),
	new LuiSprite( , , , 256, sHamburger),
	new LuiSprite( , , , 200, sCar),
	new LuiSprite( , , , 128, sHamburger),
]);

//And add some elements to panel that is inside of scroll panel
_nested_panel.add_content([
	new LuiText(, , , , "Nested panel"),
	new LuiButton( , , , , "Nested button"),
	[new LuiCheckbox( , , , , false, function() {
		if get() == true {
			LuiShowMessage(oDemo.my_ui, 360, 140, "Checkbox in nested panel of scroll panel!");
		} else {
			LuiShowMessage(oDemo.my_ui, 360, 140, ":(");
		}
	}),
	new LuiText(, , , , "Check me!")]
]);