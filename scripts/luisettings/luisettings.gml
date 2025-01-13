//Info
#macro LIMEUI_VERSION "2025.01.13_1"

//Globals
global.lui_debug_mode =	0;												// Enable/Disable debug mode
global.lui_screen_grid_size = 96;										// UI grid size for elements
global.lui_screen_grid_accuracy = 8; 									// UI grid accuracy 8 - good, but for low size pixel styles ui would be good 1

//System
#macro LUI_AUTO							-1								// Auto position/size of an element
#macro LUI_AUTO_NO_PADDING				-2								// (WIP)//???//
#macro LUI_STRETCH						-3								// (WIP)//???//
#macro LUI_GRID_SIZE					global.lui_screen_grid_size		// lui_screen_grid_size macro for better readability
#macro LUI_LOG_ERROR_MODE				1								// 0 - do not log, 1 - errors only, 2 - errors and warnings
#macro LUI_DEBUG_CALLBACK				false 							// Turn on/off debug default callback for all elements