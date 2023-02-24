show_debug_overlay(true);
randomize();

global.demo_style = {
	//Fonts
	font_default : fArial,
	font_buttons : fArial,
	font_sliders : fArial,
	//Colors
	color_font : c_black,
	color_font_hint : c_gray,
	color_main : c_white,
	color_border : merge_colour(c_white, c_black, 0.5),
	color_checkbox_pin : #45C952,
	color_slider : #45C952,
	color_textbox_border : merge_colour(c_white, c_dkgray, 0.5),
	//Sprites
	sprite_panel : sUI_panel,
	sprite_panel_border : sUI_panel_border,
	sprite_button : sUI_button,
	sprite_button_border : sUI_button_border,
	sprite_slider_knob : sUI_slider_knob,
	sprite_slider_knob_border : sUI_slider_knob_border,
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

my_panel = new LuiPanel(, , 512, 512);
my_panel_2 = new LuiPanel(, , 512, 512);
my_panel_3 = new LuiPanel(, , , 512);
my_panel_4 = new LuiPanel(, , , 432);
my_ui.add_content([
	[my_panel, my_panel_2, my_panel_3],
	my_panel_4
]);


demo_loading = new LuiProgressBar( , , , , 0, 100, true, 0);
demo_loading_state = false;
show_msg_btn = new LuiButton(16, my_panel.height - 32 - 16, , , "Show message", function() {
	var _msg = new LuiMessage( , , "Second panel x:" + string(oDemo.my_panel_2.pos_x) + " y:" + string(oDemo.my_panel_2.pos_y));
})

my_panel.add_content([
	new LuiText( , , , , "First panel").set_halign(fa_center),
	[new LuiText( , , 128, , "Second panel X"), new LuiSlider( , , , , my_panel_2.pos_x, 800, my_panel_2.pos_x, function(){oDemo.my_panel_2.pos_x = self.value})],
	[new LuiText( , , 128, , "Second panel Y"), new LuiSlider( , , , , my_panel_2.pos_y, 200, 16, function(){oDemo.my_panel_2.pos_y = self.value})],
	[demo_loading],
	[new LuiText( , , , 24, "Progress loading"),new LuiCheckbox( , , , , , function() {oDemo.demo_loading_state = self.value})],
	[new LuiText( , , , 32, "Textbox"), new LuiTextbox(, , , ,"some text", , , )],
	new LuiTextbox(, , , ,"", "login", , ),
	new LuiTextbox(, , , ,"", "password", true, ),
	[show_msg_btn, new LuiButton(my_panel.width - 128 - 16, my_panel.height - 32 - 16, 128, , "Restart", function() {game_restart()})]
]);

show_msg_btn.set_color(merge_color(c_red, c_white, 0.5));

my_panel_in_second_1 = new LuiPanel(, , , 200);
my_panel_in_second_2 = new LuiPanel(, , , 220);

my_panel_2.add_content([
	new LuiText( , , , , "Second panel").set_halign(fa_center),
	my_panel_in_second_1,
	my_panel_in_second_2
]);

deactivated_button = new LuiButton(, , , , "DEACTIVATED", function() {
	destroy();
}).deactivate();

my_panel_in_second_1.add_content([
	new LuiText( , , , , "Stretched panel").set_halign(fa_center),
	[new LuiButton(, , , , "ACTIVATE", function() {oDemo.deactivated_button.activate(); oDemo.deactivated_button.text = "DELETE"}),
	new LuiButton(, , , , "Stretched button", )],
	new LuiButton(, , , , "Stretched button 2", ),
	deactivated_button,
]);

var _buttons1 = []
var _buttons2 = []
for (var i = 0; i < 6; ++i) {
    var _button = new LuiSpriteButton( , , sLogoDemo, 0, 1, function() {self.set_color(choose(c_red, c_lime, c_aqua))});
	if i < 3 array_push(_buttons1, _button);
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
	new LuiTextbox(, , , ,"example", "hint", , )
]);

scroll_panel = new LuiScrollPanel( , , , , );
simple_sprite = new LuiSprite(, , 200, 400, sCar, 0, 1, 1);
my_panel_4.add_content([
	[scroll_panel,
	simple_sprite,
	new LuiSprite(, , 600, 100, sCarFlip, 0, 1, 1)]
]);

var _elements = []
for (var i = 0; i < 3; ++i) {
    var _btn = new LuiButton(, , , , "Button_" + string(i), );
	array_push(_elements, _btn);
}

var _panel_in_scroll = new LuiPanel( , , , 100, "Panel in scroll panel");

scroll_panel.add_content([
	new LuiText( , , , , "Scroll panel"),
	_elements, 
	_panel_in_scroll,
	new LuiSprite(, , 600, 100, sCarFlip, 0, 1, 1)
]);

_panel_in_scroll.add_content([
	new LuiText( , , , , "TEST TEST TEST")
]);