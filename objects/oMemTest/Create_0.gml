global.debug_counter = 0;

repeat (10000) {
	flex_node = flexpanel_create_node({
		name: "test", 
		data: new LuiWindow()
	});
	
	var _data = flexpanel_node_get_data(flex_node);
	
	_data.destroy();
	
	flexpanel_delete_node(flex_node, true);
}

print(string(global.debug_counter));