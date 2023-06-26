show_debug_overlay(true);
randomize();

/*
//Light theme
global.demo_style = {
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
	//Sprites
	sprite_panel : sUI_panel,
	sprite_panel_border : sUI_panel_border,
	sprite_button : sUI_button,
	sprite_button_border : sUI_button_border,
	sprite_slider_knob : sUI_panel,
	sprite_slider_knob_border : sUI_panel_border,
	sprite_scroll_slider : sUI_scroll_slider,
	sprite_scroll_slider_back : sUI_scroll_slider,
	//Sounds
	sound_click : sndBasicClick,
	//Settings
	padding : 16,
	scroll_step : 32,
	textbox_cursor : "|",
	textbox_password : "•"
}
*/

//Dark theme
global.demo_style = {
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
	//Sprites
	sprite_panel : sUI_panel,
	sprite_panel_border : sUI_panel_border,
	sprite_button : sUI_button,
	sprite_button_border : sUI_button_border,
	sprite_slider_knob : sUI_panel,
	sprite_slider_knob_border : sUI_panel_border,
	sprite_scroll_slider : sUI_scroll_slider,
	sprite_scroll_slider_back : sUI_scroll_slider,
	//Sounds
	sound_click : sndBasicClick,
	//Settings
	padding : 16,
	scroll_step : 32,
	textbox_cursor : "|",
	textbox_password : "•"
}

LUI_OVERLAY.style = new LuiStyle(global.demo_style);

my_ui = new LuiBase(global.demo_style);

my_panel = new LuiPanel( , , , 512, );
my_panel_2 = new LuiPanel( , , , 512);
my_panel_3 = new LuiPanel( , , , 512);
my_panel_4 = new LuiPanel( , , , 332).set_halign(fa_center);
my_ui.add_content([
	[my_panel, my_panel_2, my_panel_3, [0.4, 0.4, 0.2]],
	[my_panel_4, [0.75]]
]);

demo_loading = new LuiProgressBar( , , , , 0, 100, true, 0);
demo_loading_state = false;
btn_show_msg = new LuiButton(16, my_panel.height - 32 - 16, , , "Show message", function() {
	var _msg = new LuiMessage( , , "This is just a simple message!");
}).set_valign(fa_bottom)
btn_restart = new LuiButton(my_panel.width - 128 - 16, my_panel.height - 32 - 16, , , "Restart", function() {game_restart()}).set_valign(fa_bottom);

my_panel.add_content([
	new LuiText( , , , , "First panel").set_text_halign(fa_center),
	[new LuiText( , , , , "Panel X"), new LuiSlider( , , , , my_panel_4.pos_x - 128, my_panel_4.pos_x + 128, my_panel_4.pos_x, function(){oDemo.my_panel_4.pos_x = self.value}), [0.3, 0.7]],
	[new LuiText( , , , , "Panel Y"), new LuiSlider( , , , , my_panel_4.pos_y, my_panel_4.pos_y + 96, my_panel_4.pos_y, function(){oDemo.my_panel_4.pos_y = self.value}), [0.3, 0.7]],
	[demo_loading],
	[new LuiText( , , , , "Progress loading"), new LuiCheckbox( , , , , , function() {oDemo.demo_loading_state = self.value}), [0.3, 0.7]],
	[new LuiText( , , , , "Textbox"), new LuiTextbox( , , , ,"some text", , , ), [0.3, 0.7]],
	new LuiTextbox( , , , ,"", "login", , ),
	new LuiTextbox( , , , ,"", "password", true, ),
	[btn_show_msg, btn_restart]
]);

btn_show_msg.set_color(merge_color(#ffff77, c_black, 0.5));
btn_restart.set_color(merge_color(#ff7777, c_black, 0.5));

my_panel_in_second_1 = new LuiPanel( , , , 200);
my_panel_in_second_2 = new LuiPanel( , , , 220);

my_panel_2.add_content([
	new LuiText( , , , , "Second panel").set_text_halign(fa_center),
	my_panel_in_second_1,
	my_panel_in_second_2
]);

deactivated_button = new LuiButton( , , , , "DEACTIVATED", function() {
	destroy();
}).deactivate();

my_panel_in_second_1.add_content([
	new LuiText( , , , , "Panel in panel").set_text_halign(fa_center),
	[new LuiButton( , , , , "ACTIVATE", function() {oDemo.deactivated_button.activate(); oDemo.deactivated_button.text = "DELETE"}),
	new LuiButton( , , , , "Button", )],
	new LuiButton( , , , , "Button 2", ),
	deactivated_button,
]);

var _buttons1 = []
var _buttons2 = []
for (var i = 0; i < 12; ++i) {
    var _button = new LuiSpriteButton( , , sLogoDemo, 0, 1, function() {self.set_color_blend(choose(#231b2a, #4e2640, #52466c))});
	if i < 6 array_push(_buttons1, _button);
	else
	array_push(_buttons2, _button);
}
my_panel_in_second_2.add_content(
	[
		new LuiText( , , , , "Panel with sprites buttons"), 
		_buttons1, 
		_buttons2
	]
);

my_panel_3.add_content([
	new LuiText( , , , , "Third panel").set_text_halign(fa_center),
	new LuiDropDown( , , , , ["first", "second", "third"], "select element", )
]);

scroll_panel = new LuiScrollPanel( , , , 256, );
simple_sprite = new LuiSprite( , , , 300, sCar, 0, 1, 1, 1);
my_panel_4.add_content([
	[scroll_panel,
	simple_sprite,
	new LuiSprite( , , , 100, sCarFlip, 0, 1, 1, 1)]
]);


var _panel_in_scroll = new LuiPanel( , , , 128, "Panel in scroll panel");

scroll_panel.add_content([
	new LuiText( , , , , "Scroll panel")
]);
for (var i = 0; i < 3; ++i) {
    var _btn = new LuiButton( , , , , "Button_" + string(i), );
	scroll_panel.add_content(_btn);
}

scroll_panel.add_content([
	_panel_in_scroll,
	new LuiSprite( , , , 100, sCarFlip, 0, 1, 1, 1),
	new LuiSprite( , , , 100, sCar, 0, 1, 1, 1),
	new LuiSprite( , , , 100, sCarFlip, 0, 1, 1, 1),
	new LuiSprite( , , , 100, sCar, 0, 1, 1, 1),
]);

_panel_in_scroll.add_content([
	new LuiText( 16, 16, , , "Nested panel"),
	new LuiButton( , , , , "Nested button")
]);