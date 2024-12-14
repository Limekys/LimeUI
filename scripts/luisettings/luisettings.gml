//Info
#macro LIMEUI_VERSION "2024.12.14"

//Globals
global.lui_debug_mode =	0;
global.lui_screen_grid_size = 96;
global.lui_screen_grid_accuracy = 8; // 8 - good but for low size pixel styles ui would be good 1

//System
#macro LUI_AUTO							-1
#macro LUI_AUTO_NO_PADDING				-2
#macro LUI_STRETCH						-3
#macro LUI_GRID_SIZE					global.lui_screen_grid_size
#macro LUI_LOG_ERROR_MODE				1	// 0 - do not log, 1 - errors only, 2 - errors and warnings