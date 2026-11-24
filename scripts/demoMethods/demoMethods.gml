///@desc Builds the inventory screen in the supplied demo tab.
///@arg {Struct} _tab Inventory tab
function demoBuildInventory(_tab) {
	var _catalog = [
		{name: "Wayfarer Key", sprite: sIconKey, description: "Opens supply lockers along the old trade road."},
		{name: "Supply Crate", sprite: sBoxDemo, description: "Holds spare tools and rations for a long expedition."},
		{name: "Trail Rations", sprite: sHamburger, description: "A packed meal for the next stop on the route."},
		{name: "Scout Rover", sprite: sCar, description: "A compact vehicle for scouting unmarked routes."},
		{name: "Survey Dial", sprite: sIconPalette, description: "A navigation aid calibrated for rough terrain."},
		{name: "Field Notes", sprite: sIconInfo, description: "A set of observations from earlier expeditions."},
		{name: "Route Marker", sprite: sIconHome, description: "Marks a safe place to regroup after sundown."},
		{name: "Signal Lens", sprite: sIconSearch, description: "Focuses light for long-distance signals."}
	];
	var _tiers = [
		{name: "Common", color: #90A7B5},
		{name: "Uncommon", color: #60C9B0},
		{name: "Rare", color: #77A4EB},
		{name: "Epic", color: #C29AE8}
	];
	var _locked_material = undefined;
	if shader_is_compiled(shd_lui_grayscale) {
		var _amount_uniform = shader_get_uniform(shd_lui_grayscale, "u_amount");
		if _amount_uniform >= 0 {
			_locked_material = luiMaterial(shd_lui_grayscale, function(_element, _material) {
				shader_set_uniform_f(_material.amount_uniform, 1);
			}, true);
			_locked_material.amount_uniform = _amount_uniform;
		}
	}

	var _portrait = new LuiBox({width: 72, height: 72, color: #47637D, alpha: 1})
		.setPadding(8).setFlexShrink(0).setMouseIgnore();
	var _portrait_material = luiMaskMaterial(shd_lui_mask, spr_mask_circle);
	_portrait.setMaterial(_portrait_material);

	var _grid = new LuiScrollPanel().setGap(8);
	var _details_panel = new LuiPanel().setPadding(12).setGap(6).setCacheAsSurface(true);
	var _details = {
		selected: undefined,
		icon: new LuiImage({height: 56}).setMouseIgnore(),
		title: new LuiText({height: 28, overflow: LUI_TEXT_OVERFLOW.Scale}).setMouseIgnore(),
		summary: new LuiText({height: 24}).setMouseIgnore(),
		description: new LuiText({height: 56, text_valign: fa_top, overflow: LUI_TEXT_OVERFLOW.WrapScale}).setMouseIgnore()
	};
	_portrait.addContent(_details.icon);
	var _portrait_row = new LuiRow({height: 72}).setFlexJustifyContent(flexpanel_justify.center).addContent(_portrait);
	var _inspect = new LuiButton({text: "Inspect", height: 40}).setData("details", _details);
	_inspect.addEvent(LUI_EV_CLICK, function(_e) {
		var _selected = _e.getData("details").selected;
		if is_undefined(_selected) return;

		var _item = _selected.getData("item");
		var _status = _item.locked ? "Locked" : $"Qty {_item.quantity}";
		var _slots = [];
		for (var i = 1; i <= 24; i++) {
			array_push(_slots, new LuiComboBoxItem({text: $"Slot {i}"}));
		}
		var _slot_picker = new LuiComboBox({placeholder: "Preview storage slot...", height: 36})
			.setCacheAsSurface(true).addItems(_slots);
		oDemo.inventory_inspect_message = _e.main_ui.alert({
			width: 360,
			alpha: 0.65,
			button_text: "Close",
			content: [
				new LuiText({value: _item.name, height: 36, text_halign: fa_center, overflow: LUI_TEXT_OVERFLOW.Scale}).setMouseIgnore(),
				new LuiImage({value: _item.sprite, height: 120}).setMouseIgnore(),
				new LuiText({value: $"{_item.tier}  |  {_status}", height: 28, text_halign: fa_center})
					.setLocalStyle({color_text: _item.color}).setMouseIgnore(),
				new LuiText({value: _item.description, height: 56, text_halign: fa_center, overflow: LUI_TEXT_OVERFLOW.WrapScale}).setMouseIgnore(),
				_slot_picker,
				new LuiButton({text: "About rarity", height: 36}).addEvent(LUI_EV_CLICK, function(_button) {
					_button.main_ui.alert({
						text: "A colored border indicates item rarity. Locked items can still be inspected.",
						width: 360,
						button_text: "Back"
					});
				})
			]
		});
	});
	_details_panel.addContent([_details.title, _details.summary, _inspect, _portrait_row, _details.description]);

	var _card_height = 116;
	for (var i = 0; i < array_length(_tiers); i++) {
		var _tier = _tiers[i];
		for (var _start = 0; _start < array_length(_catalog); _start += 4) {
			var _cards = [];
			for (var _column = 0; _column < 4; _column++) {
				var _entry = _catalog[_start + _column];
				var _item = {
					name: _entry.name,
					sprite: _entry.sprite,
					description: _entry.description,
					tier: _tier.name,
					color: _tier.color,
					locked: _column == 3,
					quantity: 1 + ((_start + _column + i * 3) mod 9)
				};
				var _card_status = _item.locked ? "Locked" : $"x{_item.quantity}";
				var _card = new LuiPanel({height: _card_height}).setPadding(5).setGap(3).setFlexGrow(1)
					.setLocalStyle({color_primary: #24374A, color_border: _item.color, color_text: #E6EFF8, sprite_panel_border: sUI_panel_border})
					.setData("item", _item).setData("details", _details)
					.addContent([
						new LuiImage({value: _item.sprite, height: 42}).setMouseIgnore(),
						new LuiText({value: _item.name, height: 18, text_halign: fa_center, overflow: LUI_TEXT_OVERFLOW.Scale}).setMouseIgnore(),
						new LuiText({value: _card_status, height: 30, text_halign: fa_center, overflow: LUI_TEXT_OVERFLOW.Scale}).setMouseIgnore()
							.setLocalStyle({color_text: _item.color})
					])
					.addEvent(LUI_EV_CLICK, function(_e) {
						demoSelectInventoryItem(_e);
					});
				if _item.locked && !is_undefined(_locked_material) {
					_card.setMaterial(_locked_material);
				}
				if is_undefined(_details.selected) {
					demoSelectInventoryItem(_card);
				}
				array_push(_cards, _card);
			}
			_grid.addContent(new LuiRow({height: _card_height}).setGap(8).setFlexShrink(0).addContent(_cards));
		}
	}

	var _sidebar = new LuiScrollPanel().addContent(_details_panel);
	var _layout = new LuiRow().setGap(10).setFlexGrow(1).addContent([_grid, _sidebar, [0.68, 0.32]]);
	_tab.addContent(_layout);
	_layout.addEvent(LUI_EV_SHOW, function(_e) {
		_e.visual_alpha = 0;
		_e.visual_y = 10;
		_e.main_ui.animate(_e, "visual_alpha", 1, 0.24);
		_e.main_ui.animate(_e, "visual_y", 0, 0.24);
	});
}

///@desc Highlights the selected card and updates the inventory details.
///@arg {Struct} _card Inventory card
function demoSelectInventoryItem(_card) {
	var _details = _card.getData("details");
	if _details.selected == _card return;

	if !is_undefined(_details.selected) {
		var _previous = _details.selected;
		_previous.setLocalStyle({color_primary: #24374A, color_border: _previous.getData("item").color});
	}

	var _item = _card.getData("item");
	_details.selected = _card;
	_card.setLocalStyle({color_primary: #47637D, color_border: #F5D594});
	_details.icon.setSprite(_item.sprite);
	_details.title.setText(_item.name);
	var _status = _item.locked ? "Locked" : $"Qty {_item.quantity}";
	_details.summary.setText($"{_item.tier}  |  {_status}").setLocalStyle({color_text: _item.color});
	_details.description.setText(_item.description);
}

///@desc Adds a fixed workload to the benchmark tab and returns its scroll panel.
///@arg {Struct} _tab Benchmark tab
///@return {Struct} Panel containing the benchmark rows
function demoBuildListBenchmark(_tab) {
	var _rows = array_create(1000);
	for (var i = 0; i < array_length(_rows); i++) {
		_rows[i] = new LuiButton({text: "Benchmark row", height: 32}).setFlexShrink(0);
	}
	var _panel = new LuiPanel({scroll_y: true}).setGap(0).addContent(_rows);
	_tab.addContent(_panel);
	return _panel;
}

///@desc Checks content routing and destruction for composite widgets.
///@arg {Struct} _ui Demo UI root
function demoCheckContentContracts(_ui) {
	var _tab = new LuiTab({text: "Contract check"});
	var _tabs = new LuiTabs({scroll_y: true}).addTab(_tab);
	var _window = new LuiWindow({width: 300, height: 300, scroll_x: true, scroll_y: true, allow_resize: true});
	var _plain_area = new LuiScrollArea();
	var _scroll_area = new LuiScrollArea({scroll_x: true, scroll_y: true});
	var _fixtures = [new LuiPanel(), new LuiPanel({scroll_y: true}), _window, _tab, _plain_area, _scroll_area];
	var _passed = true;

	for (var i = 0, n = array_length(_fixtures); i < n; i++) {
		var _widget = _fixtures[i];
		var _first = new LuiBox();
		var _last = new LuiBox();
		var _direct = new LuiBox();
		_widget.addContent(_first).addContentDirect(_direct);
		_ui.addContent(_widget == _tab ? _tabs : _widget);
		_widget.addContent(_last);

		var _container = _widget.getContainer();
		var _direct_is_content = _container == _widget;
		var _content = _widget.getContent();
		var _valid = _first.parent == _container && _last.parent == _container && _direct.parent == _widget
			&& _widget.getFirst() == _first && _widget.getLast() == _last
			&& array_contains(_content, _direct) == _direct_is_content;
		_widget.destroyContent();
		_valid = _valid && _first.is_destroyed && _last.is_destroyed
			&& _direct.is_destroyed == _direct_is_content && array_length(_widget.getContent()) == 0;
		if _widget == _window {
			var _handle = _window.resizer;
			_valid = _valid && !_window.window_header.is_destroyed && !_window.window_container.is_destroyed
				&& is_instanceof(_window.window_container, LuiScrollArea)
				&& !is_undefined(_handle) && _handle.parent == _window && _handle.z > _window.window_container.z;
			_window.setAllowResize(false);
			_valid = _valid && !is_undefined(_handle) && _handle.is_destroyed && is_undefined(_window.resizer);
			_window.setAllowResize(true);
			_valid = _valid && !is_undefined(_window.resizer) && _window.resizer != _handle;
		}
		if _widget == _plain_area {
			_valid = _valid && _direct_is_content && _plain_area.ignore_mouse && is_undefined(_plain_area.step);
		}
		if _widget == _scroll_area {
			_valid = _valid && !_direct_is_content && !_scroll_area.ignore_mouse
				&& _container._scroll_owner == _scroll_area && _scroll_area._scroll_bar_x.parent == _scroll_area
				&& _scroll_area._scroll_bar_y.parent == _scroll_area
				&& is_instanceof(_scroll_area._scroll_bar_x.getFirst(), LuiScrollThumb)
				&& is_instanceof(_scroll_area._scroll_bar_y.getFirst(), LuiScrollThumb);
		}
		if _widget == _tab {
			_tabs.destroyContent();
			_valid = _valid && _tab.is_destroyed && !_tabs.tabs_header.is_destroyed
				&& is_instanceof(_tabs._pages_host, LuiScrollArea) && !_tabs._pages_host.is_destroyed
				&& array_length(_tabs.tabs) == 0 && is_undefined(_tabs.active_tab);
			_tabs.destroy();
		} else {
			_widget.destroy();
		}
		show_debug_message($"LimeUI content check {i + 1}: " + (_valid ? "PASS" : "FAIL"));
		_passed = _passed && _valid;
	}
	show_debug_message("LimeUI content contracts: " + (_passed ? "PASS" : "FAIL"));
}

///@desc Creates the mixed-widget stress test in its own scroll panel.
///@arg {Struct} _tab Tab that hosts the stress test
///@return {Struct} The stress test panel
function demoStressTest(_tab) {
	makeRandomColor = function() {
		return make_color_hsv(irandom(255), irandom_range(128,255), 255);
	}
	numb = 0;
	_random_element = function(_number) {
		var _rnd = irandom(7);
		switch (_rnd) {
			case 0:	return new LuiButton({height: irandom_range(32, 128), text: "button_" + string(_number)}).setColor(makeRandomColor());
			case 1:	return new LuiImageButton({height: irandom_range(32, 128), value: sLogoDemo, color: makeRandomColor(), alpha: choose(0.5, 1), maintain_aspect: choose(true, false)}).addEvent(LUI_EV_CLICK, function(_e) {oDemo.changeImageButtonColor(_e)});
			case 2:	return new LuiSlider({height: irandom_range(32, 128), max_value: _number, value: random(_number), rounding: choose(25,10,5,2,1,0.5,0.1,0.01)});
			case 3:	return new LuiInput({height: irandom_range(32, 128), placeholder: choose("", "input_" + string(_number))}).setIncorrect(choose(true, false));
			case 4:	return new LuiProgressRing({height: irandom_range(32, 128), max_value: _number, value: random(_number), rounding: choose(25,10,5,2,1,0.5,0.1,0.01), display_value: choose(true, false), color: makeRandomColor()});
			case 5:	return new LuiCheckbox({height: irandom_range(32, 128), value: choose(true, false), text: choose("checkbox_" + string(_number), "")});
			case 6:	return new LuiToggleSwitch({height: irandom_range(32, 128), value: choose(true, false), text: choose("switch_" + string(_number), "")});
			case 7:	return new LuiToggleButton({height: irandom_range(32, 128), value: choose(true, false), text: "toggleButton_" + string(_number)}).setColor(makeRandomColor());
		}
	}
	var _rows = array_create(250);
	for (var i = 0, n = array_length(_rows); i < n; i++) {
		var _a = random_range(0.1, 0.3);
		var _b = random_range(0.1, 0.3);
		var _c = random_range(0.1, 0.3);
		_rows[i] = new LuiRow().setFlexShrink(0).addContent([
			_random_element(numb++), _random_element(numb++), _random_element(numb++), _random_element(numb++),
			[_a, _b, _c, 1 - _a - _b - _c]
		]);
	}
	var _panel = new LuiPanel({scroll_y: true}).addContent(_rows);
	_tab.addContent(_panel);
	return _panel;
}

function demoTestAnim1() {
	var _panel = my_panel;
	_panel.setCacheAsSurface(true);
	
	// Reset visual state before animation
	_panel.visual_alpha = 0;
	_panel.visual_scale_x = 0;
	_panel.visual_scale_y = 0;
	_panel.visual_angle = -90;
	_panel.visual_x = 0;
	_panel.visual_y = 0;
	
	// Pop-in animation
	my_ui.animate(_panel, "visual_alpha", 1, 1);
	my_ui.animate(_panel, "visual_scale_x", 1, 1, global.Ease.OutBack);
	my_ui.animate(_panel, "visual_scale_y", 1, 1, global.Ease.OutBack);
	my_ui.animate(_panel, "visual_angle", 0, 1, global.Ease.OutBack);
}

function demoTestAnim2() {
	var _panel = my_panel;
	_panel.setCacheAsSurface(true);
	
	// Reset visual state before animation
	_panel.visual_alpha = 1;
	_panel.visual_scale_x = 1;
	_panel.visual_scale_y = 1;
	_panel.visual_angle = 0;
	_panel.visual_x = 0;
	_panel.visual_y = 0;
	
	// Pop-out animation
	my_ui.animate(_panel, "visual_alpha", 0, 0.35);
	my_ui.animate(_panel, "visual_scale_x", 0.5, 0.35, global.Ease.InBack);
	my_ui.animate(_panel, "visual_scale_y", 0.5, 0.35, global.Ease.InBack);
}

function demoTestAnim3() {
	var _panel = my_panel;
	_panel.setCacheAsSurface(true);
	
	// Reset visual state before animation
	_panel.visual_alpha = 0;
	_panel.visual_scale_x = 0;
	_panel.visual_scale_y = 1;
	_panel.visual_angle = 0;
	_panel.visual_x = 0;
	_panel.visual_y = 0;
	
	// Card flip animation
	my_ui.animate(_panel, "visual_alpha", 1, 0.3);
	my_ui.animate(_panel, "visual_scale_x", 1, 0.6, global.Ease.OutBack);
}

function demoTestAnim4() {
	var _panel = my_panel;
	_panel.setCacheAsSurface(true);
	
	// Reset visual state before animation
	_panel.visual_alpha = 1;
	_panel.visual_scale_x = 1;
	_panel.visual_scale_y = 1;
	_panel.visual_angle = 0;
	_panel.visual_y = 0;
	
	// Shake: offset to the right, then spring back
	_panel.visual_x = 25;
	my_ui.animate(_panel, "visual_x", 0, 1.0, global.Ease.OutElastic);
}

function demoTestAnim5() {
	var _panel = my_panel;
	
	// IMPORTANT: Disable surface caching so children animate independently
	_panel.setCacheAsSurface(false);
	
	// Reset panel visual state
	_panel.visual_alpha = 1;
	_panel.visual_scale_x = 1;
	_panel.visual_scale_y = 1;
	_panel.visual_angle = 0;
	_panel.visual_x = 0;
	_panel.visual_y = 0;
	
	// Animate each child element with increasing duration (creates stagger effect)
	var _children = _panel.content;
	for (var i = 0; i < array_length(_children); i++) {
		var _child = _children[i];
	    
		// Initial state: hidden and shifted to the left
		_child.visual_alpha = 0;
		_child.visual_x = -30;
	    
		// Each next child has a longer duration, creating a cascade delay
		var _duration = 0.3 + i * 0.1;
	    
		my_ui.animate(_child, "visual_alpha", 1, _duration, global.Ease.OutQuad);
		my_ui.animate(_child, "visual_x", 0, _duration, global.Ease.OutBack);
	}
}
