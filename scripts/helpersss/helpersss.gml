global.lui_prof = {};
global.lui_prof_frame = {};        // фазы текущего кадра
global.lui_bakes_frame = 0;        // сколько кешей пересобрано в этом кадре
global.lui_spike_log = "";         // накопленный текст
global.lui_spike_threshold_us = 11000;   // кадр дольше 6 мс (~166 FPS) считаем медленным

function luiProf(_name, _t0) {
	var _ms = (get_timer() - _t0) / 1000;
	var _e = global.lui_prof[$ _name] ?? { cur: 0, max: 0 };
	_e.cur = _ms;
	_e.max = max(_e.max, _ms);
	global.lui_prof[$ _name] = _e;
	global.lui_prof_frame[$ _name] = _ms;
}

global.lui_prev = { phases: {}, bakes: 0, hover: "-" };   // данные предыдущего кадра

/// Вызывать в самом конце LuiMain.render (как и раньше)
function luiProfFrameEnd(_hovered_name) {
	// delta_time = длительность ПРЕДЫДУЩЕГО кадра, поэтому при спайке логируем сохранённые данные того кадра
	if (delta_time > global.lui_spike_threshold_us) {
		var _p = global.lui_prev;
		var _names = struct_get_names(_p.phases);
		array_sort(_names, true);
		var _sum = 0;
		var _line = $"SPIKE frame={string_format(delta_time / 1000, 1, 2)}ms bakes={_p.bakes} hover={_p.hover} |";
		for (var i = 0; i < array_length(_names); i++) {
			var _v = _p.phases[$ _names[i]];
			_sum += _v;
			_line += $" {_names[i]}={string_format(_v, 1, 2)}";
		}
		_line += $" | lui_sum={string_format(_sum, 1, 2)} other={string_format(delta_time / 1000 - _sum, 1, 2)}";
		_line += $" gc={json_stringify(gc_get_stats())}";
		global.lui_spike_log += _line + "\n";
		show_debug_message(_line);
	}
	global.lui_prev = { phases: global.lui_prof_frame, bakes: global.lui_bakes_frame, hover: _hovered_name };
	global.lui_prof_frame = {};
	global.lui_bakes_frame = 0;
}