show_debug_overlay(true);
randomize();

my_ui = new LuiBase();

my_panel = new LuiPanel(LUI_AUTO, LUI_AUTO, 512, 512);
my_panel_2 = new LuiPanel(LUI_AUTO, LUI_AUTO, 512, 512);
my_panel_3 = new LuiPanel(LUI_AUTO, LUI_AUTO, LUI_STRETCH, 512);
my_panel_4 = new LuiPanel(LUI_AUTO, LUI_AUTO, LUI_STRETCH, 208);
my_ui.add_content([
	my_panel,
	my_panel_2,
	my_panel_3,
	my_panel_4
]);


demo_loading = new LuiProgressBar( , , LUI_STRETCH, , 0, 100, false, 0, function(){});
demo_loading_state = false;

my_panel.add_content([
	new LuiText( , , LUI_STRETCH, , "First panel"),
	new LuiText( , , 128, 32, "Slider"),
	new LuiProgressBar( , , LUI_STRETCH, 32, 0, 100, true, 25, function(){print("Slider value: ", self.value)}),
	new LuiText( , , 128, , "Second panel X"),
	new LuiProgressBar( , , LUI_STRETCH, , my_panel_2.pos_x, 800, true, my_panel_2.pos_x, function(){oDemo.my_panel_2.pos_x = self.value}),
	new LuiText( , , 128, , "Second panel Y"),
	new LuiProgressBar( , , LUI_STRETCH, , my_panel_2.pos_y, 200, true, 16, function(){oDemo.my_panel_2.pos_y = self.value}),
	demo_loading,
	new LuiCheckbox( , , , , , function() {oDemo.demo_loading_state = self.value}),
	new LuiText( , , , 32, "Progress loading"),
	
	new LuiButton(16, my_panel.height - 32 - 16, , , "Show message", function() {
			var _msg = new LuiMessage( , , "Second panel x:" + string(oDemo.my_panel_2.pos_x) + " y:" + string(oDemo.my_panel_2.pos_y));
		}),
	new LuiButton(my_panel.width - 128 - 16, my_panel.height - 32 - 16, , , "Exit", function() {game_end()})
]);
my_panel_in_second_1 = new LuiPanel(LUI_AUTO, LUI_AUTO, LUI_STRETCH, 200);
my_panel_in_second_2 = new LuiPanel(LUI_AUTO, LUI_AUTO, LUI_STRETCH, 200);

my_panel_2.add_content([
	new LuiText( , , LUI_STRETCH, , "Second panel"),
	my_panel_in_second_1,
	my_panel_in_second_2
]);

my_panel_in_second_1.add_content([
	new LuiText( , , LUI_STRETCH, , "Stretched panel"),
	new LuiButton(LUI_AUTO, LUI_AUTO, , , "DOG", ),
	new LuiButton(LUI_AUTO, LUI_AUTO, LUI_STRETCH, , "Stretched button", ),
	new LuiButton(LUI_AUTO, LUI_AUTO, LUI_STRETCH, , "Stretched button 2", ),
	new LuiButton(LUI_AUTO, LUI_AUTO, , , "CAT", ),
]);

my_panel_in_second_2.add_content(new LuiText( , , LUI_STRETCH, , "Panel with sprites buttons"));
for (var i = 0; i < 12; ++i) {
    my_panel_in_second_2.add_content(new LuiSpriteButton(LUI_AUTO, LUI_AUTO, sLogoDemo, 0, 1, choose(c_white, c_blue, c_red, c_green), ));
}