show_debug_overlay(true)

my_ui = new LUI_Base();

my_panel = new LUI_Panel(LUI_AUTO, LUI_AUTO, 220, 400);
my_ui.add_content(my_panel);
my_panel.add_content([
	new LUI_Panel(LUI_AUTO, LUI_AUTO, 64, 64),
	new LUI_Panel(LUI_AUTO, LUI_AUTO, 64, 64),
	new LUI_Panel(LUI_AUTO, LUI_AUTO, 64, 64),
	new LUI_Panel(LUI_AUTO, LUI_AUTO, 64, 64),
	new LUI_Panel(LUI_AUTO, LUI_AUTO, 64, 64),
	new LUI_Panel(LUI_AUTO, LUI_AUTO, 64, 64),
	new LUI_Panel(LUI_AUTO, LUI_AUTO, 64, 64)
]);

my_panel2 = new LUI_Panel(LUI_AUTO, LUI_AUTO, 420, 256);
my_ui.add_content(my_panel2);
my_panel2.add_content([
	new LUI_Panel(LUI_AUTO_NO_SPACING, LUI_AUTO_NO_SPACING, 64, 64),
	new LUI_Panel(LUI_AUTO_NO_SPACING, LUI_AUTO_NO_SPACING, 128, 64),
	new LUI_Panel(LUI_AUTO_NO_SPACING, LUI_AUTO_NO_SPACING, 64, 64),
	new LUI_Panel(LUI_AUTO_NO_SPACING, LUI_AUTO_NO_SPACING, 64, 64),
	new LUI_Panel(LUI_AUTO_NO_SPACING, LUI_AUTO_NO_SPACING, 64, 64),
	new LUI_Panel(LUI_AUTO_NO_SPACING, LUI_AUTO_NO_SPACING, 200, 64),
	new LUI_Panel(LUI_AUTO_NO_SPACING, LUI_AUTO_NO_SPACING, 64, 128)
]);

my_panel3 = new LUI_Panel(LUI_AUTO, LUI_AUTO, 512, 512);
my_ui.add_content(my_panel3);
panel_in_panel = new LUI_Panel(LUI_AUTO, LUI_AUTO, 256, 256);

my_panel3.add_content([
	panel_in_panel,
	new LUI_Button(,,,,"Нажми меня", function() {print("Нажал меня! :3")}),
	new LUI_Button(,my_panel3.height - 32,,,"Принять"),
	new LUI_Button(my_panel3.x + my_panel3.width - 128 - 32, my_panel3.height - 32,,,"Отмена")
]);

panel_in_panel.add_content(
	new LUI_Button(,,,,"В панеле")
);