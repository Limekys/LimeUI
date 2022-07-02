show_debug_overlay(true);
randomize();

my_ui = new LuiBase();

my_panel = new LuiPanel(LUI_AUTO, LUI_AUTO, 512, 512);
my_panel_2 = new LuiPanel(LUI_AUTO, LUI_AUTO, 512, 512);
my_panel_3 = new LuiPanel(LUI_AUTO, LUI_AUTO, LUI_STRETCH, 512);
my_panel_4 = new LuiPanel(LUI_AUTO, LUI_AUTO, LUI_STRETCH, LUI_STRETCH);
my_ui.add_content([
	my_panel,
	my_panel_2,
	my_panel_3,
	my_panel_4
]);


demo_loading = new LuiProgressBar( LUI_AUTO, LUI_AUTO, LUI_STRETCH, , 0, 100, true, 0);
demo_loading_state = false;

my_panel.add_content([
	new LuiText( LUI_AUTO, LUI_AUTO, LUI_STRETCH, , "First panel"),
	new LuiText( LUI_AUTO, LUI_AUTO, 128, 32, "BIG Slider"),
	new LuiSlider( LUI_AUTO, LUI_AUTO, LUI_STRETCH, 32, 0, 100, 25, function(){print("Slider value: ", self.value)}),
	new LuiText( LUI_AUTO, LUI_AUTO, 128, , "Second panel X"),
	new LuiSlider( LUI_AUTO, LUI_AUTO, LUI_STRETCH, , my_panel_2.pos_x, 800, my_panel_2.pos_x, function(){oDemo.my_panel_2.pos_x = self.value}),
	new LuiText( LUI_AUTO, LUI_AUTO, 128, , "Second panel Y"),
	new LuiSlider( LUI_AUTO, LUI_AUTO, LUI_STRETCH, , my_panel_2.pos_y, 200, 16, function(){oDemo.my_panel_2.pos_y = self.value}),
	demo_loading,
	new LuiCheckbox( LUI_AUTO, LUI_AUTO, , , , function() {oDemo.demo_loading_state = self.value}),
	new LuiText( LUI_AUTO, LUI_AUTO, LUI_STRETCH, 24, "Progress loading"),
	new LuiText( LUI_AUTO, LUI_AUTO, , 32, "Textbox"),
	new LuiTextbox(LUI_AUTO, LUI_AUTO, LUI_STRETCH,,"some text in textbox", , , ),
	new LuiTextbox(LUI_AUTO, LUI_AUTO, LUI_STRETCH,,"", "login", , ),
	new LuiTextbox(LUI_AUTO, LUI_AUTO, LUI_STRETCH,,"", "password", true, ),
	
	new LuiButton(16, my_panel.height - 32 - 16, , , "Show message", function() {
			var _msg = new LuiMessage( , , "Second panel x:" + string(oDemo.my_panel_2.pos_x) + " y:" + string(oDemo.my_panel_2.pos_y));
		}).set_blend_color(c_red),
	new LuiButton(my_panel.width - 128 - 16, my_panel.height - 32 - 16, , , "Exit", function() {game_end()})
]);

my_panel_in_second_1 = new LuiPanel(LUI_AUTO, LUI_AUTO, LUI_STRETCH, 200);
my_panel_in_second_2 = new LuiPanel(LUI_AUTO, LUI_AUTO, LUI_STRETCH, 220);

my_panel_2.add_content([
	new LuiText( LUI_AUTO, LUI_AUTO, LUI_STRETCH, , "Second panel"),
	my_panel_in_second_1,
	my_panel_in_second_2
]);

deactivated_button = new LuiButton(LUI_AUTO, LUI_AUTO, , , "DEACTIVATED", ).deactivate();

my_panel_in_second_1.add_content([
	new LuiText( LUI_AUTO, LUI_AUTO, LUI_STRETCH, , "Stretched panel"),
	new LuiButton(LUI_AUTO, LUI_AUTO, , , "DOG", function() {oDemo.deactivated_button.activate(); oDemo.deactivated_button.text = ":)"}),
	new LuiButton(LUI_AUTO, LUI_AUTO, LUI_STRETCH, , "Stretched button", ),
	new LuiButton(LUI_AUTO, LUI_AUTO, LUI_STRETCH, , "Stretched button 2", ),
	deactivated_button,
]);

my_panel_in_second_2.add_content(new LuiText( LUI_AUTO, LUI_AUTO, LUI_STRETCH, , "Panel with sprites buttons"));
for (var i = 0; i < 12; ++i) {
    my_panel_in_second_2.add_content(new LuiSpriteButton(LUI_AUTO, LUI_AUTO, sLogoDemo, 0, 1, choose(c_white, c_lime, c_aqua), ));
}

my_panel_3.add_content([
	new LuiTextbox(LUI_AUTO, LUI_AUTO, LUI_STRETCH, ,"example", "hint", , )
]);

scroll_panel = new LuiScrollPanel(LUI_AUTO, LUI_AUTO, , , );
simple_sprite = new LuiSprite(LUI_AUTO, LUI_AUTO, 256, , sCar, 0, 1, c_white, 1);
my_panel_4.add_content([
	scroll_panel,
	simple_sprite,
	new LuiSprite(LUI_AUTO, LUI_AUTO, 128, , sCarFlip, 0, 1, c_white, 1)
]);

scroll_panel.add_content([
	new LuiText( LUI_AUTO, LUI_AUTO, LUI_STRETCH, , "Scroll panel")
]);
for (var i = 0; i < 20; ++i) {
    scroll_panel.add_content(new LuiButton(LUI_AUTO, LUI_AUTO, LUI_STRETCH, , "Button_" + string(i), ));
}
