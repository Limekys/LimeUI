show_debug_overlay(true);

my_ui = new LuiBase();

my_panel = new LuiPanel(LUI_AUTO, LUI_AUTO, 400, 512);
my_panel_2 = new LuiPanel(LUI_AUTO, LUI_AUTO, 400, 512);
my_ui.add_content([
	my_panel,
	my_panel_2
]);


demo_loading = new LuiProgressBar( , , my_panel.width-32, , 0, 100, false, 0, function(){});

my_panel.add_content([
	//new LuiButton( , , , ,"Нажми меня", function() {print("*КАКОЕ-ТО ДЕЙСТВИЕ ПРИ НАЖАТИИ*")}),
	new LuiText( , , , , "Общий звук: "),
	new LuiProgressBar( , , 200, , 0, 100, true, 25, function(){print("Dragging: ", self.value)}),
	new LuiText( , , , , "X Второй панели "),
	new LuiProgressBar( , , 200, , 432, 900, true, 432, function(){oDemo.my_panel_2.pos_x = self.value}),
	new LuiText( , , , , "Y Второй панели "),
	new LuiProgressBar( , , 200, , 16, 256, true, 16, function(){oDemo.my_panel_2.pos_y = self.value}),
	
	demo_loading,
	
	
	new LuiButton(my_panel.pos_x + 16, my_panel.height - 32, , , "Показать", function() {
			var _msg = new LuiMessage( , , "TEST TEST TEST TEST");
		}),
	new LuiButton(my_panel.pos_x + my_panel.width - 128 - 16, my_panel.height - 32, , , "Выход", function() {game_end()})
]);
my_panel_3 = new LuiPanel(LUI_AUTO, LUI_AUTO, 256, 256);

my_panel_2.add_content([
	new LuiText( , , , , "ТЕСТ"),
	my_panel_3
]);

my_panel_3.add_content([
	new LuiButton( , , , , "PRIKOL", ),
	new LuiButton( , , , , "PRIKOL", ),
	new LuiButton( , , , , "PRIKOL", ),
	new LuiButton( , , , , "PRIKOL", ),
])