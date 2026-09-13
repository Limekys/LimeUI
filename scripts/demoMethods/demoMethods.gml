function demoStressTest() {
	makeRandomColor = function() {
		return make_color_hsv(irandom(255), irandom_range(128,255), 255);
	}
	numb = 0;
	_random_element = function(_number) {
		var _rnd = irandom(7);
		switch (_rnd) {
			case 0:	return new LuiButton({height: irandom_range(32, 128), text: "button_" + string(_number)}).setColor(makeRandomColor());
			case 1:	return new LuiImageButton({height: irandom_range(32, 128), value: sLogoDemo, color: makeRandomColor(), alpha: choose(0.5, 1), maintain_spect: choose(true, false)}).addEvent(LUI_EV_CLICK, function(_e) {oDemo.changeImageButtonColor(_e)});
			case 2:	return new LuiSlider({height: irandom_range(32, 128), max_value: _number, value: random(_number), rounding: choose(25,10,5,2,1,0.5,0.1,0.01)});
			case 3:	return new LuiInput({height: irandom_range(32, 128), placeholder: choose("", "input_" + string(_number))}).setIncorrect(choose(true, false));
			case 4:	return new LuiProgressRing({height: irandom_range(32, 128), max_value: _number, value: random(_number), rounding: choose(25,10,5,2,1,0.5,0.1,0.01), display_value: choose(true, false), color: makeRandomColor()});
			case 5:	return new LuiCheckbox({height: irandom_range(32, 128), value: choose(true, false), text: choose("checkbox_" + string(_number), "")});
			case 6:	return new LuiToggleSwitch({height: irandom_range(32, 128), value: choose(true, false), text: choose("switch_" + string(_number), "")});
			case 7:	return new LuiToggleButton({height: irandom_range(32, 128), value: choose(true, false), text: "toggleButton_" + string(_number)}).setColor(makeRandomColor());
		}
	}
	repeat (250) {
		my_ui.getElement("firstScrollPanel").addContent([
			new LuiRow().addContent([
				_random_element(numb++), _random_element(numb++), _random_element(numb++), _random_element(numb++), [random_range(0.1, 0.3), random_range(0.1, 0.3), random_range(0.1, 0.3)]
			])
		])
	}
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