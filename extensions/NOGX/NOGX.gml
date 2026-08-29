#define _NOGX_init

global.__NOGX_enabled = extension_get_option_value("NOGX", "Enable");
global.__NOGX_canvas_size_update_ticker = undefined;
global.__NOGX_canvas_w = -1;
global.__NOGX_canvas_h = -1;
global.__NOGX_limit_asp_ratio = false;
global.__NOGX_min_asp = 16/9;
global.__NOGX_max_asp = 16/9;
global.__NOGX_resize_app_surf = extension_get_option_value("NOGX", "ResizeApplicationSurface");

if(!global.__NOGX_enabled) {
	return;
}

var limit_asp_ratio = extension_get_option_value("NOGX", "LimitAspectRatio");
var use_custom_asp_ratio = extension_get_option_value("NOGX", "UseCustomAspectRatio");
var min_asp = 16/9;
var max_asp = 16/9;

if(limit_asp_ratio) {
	if(use_custom_asp_ratio) {
		var custom_asp = extension_get_option_value("NOGX", "CustomAspectRatio");
		var custom_asp_fix = string_replace_all(custom_asp, ",", ".");
		var custom_asp_split = string_split(custom_asp_fix, ":");
		var parts_num = array_length(custom_asp_split);
		if(parts_num==1) {
			min_asp =  real(custom_asp_split[0]);
			max_asp = min_asp;
		} else if(parts_num==2) {
			var value1 = real(custom_asp_split[0]);
			var value2 = real(custom_asp_split[1]);
			min_asp =  value1 / value2;
			max_asp = min_asp;
		} else {
			show_error("NOGX: invalid CustomAspectRatio value", false);
		}
	} else {
		var asp_range_start = extension_get_option_value("NOGX", "AspectRatioRangeStart");
		var asp_range_end = extension_get_option_value("NOGX", "AspectRatioRangeEnd");
		var asp_start_split = string_split(asp_range_start, ":");
		var asp_end_split = string_split(asp_range_end, ":");
		var asp_start_value = real(asp_start_split[0]) / real(asp_start_split[1]);
		var asp_end_value = real(asp_end_split[0]) / real(asp_end_split[1]);
		min_asp = min(asp_start_value, asp_end_value);
		max_asp = max(asp_start_value, asp_end_value);
	}
}

global.__NOGX_min_asp = min_asp;
global.__NOGX_max_asp = max_asp;
global.__NOGX_limit_asp_ratio = limit_asp_ratio;

var update_canvas_size;

if(os_type==os_gxgames) {
	update_canvas_size = function() {
		var cw = _NOGX_get_canvas_width();
		var ch = _NOGX_get_canvas_height();
		
		if( cw==global.__NOGX_canvas_w && ch==global.__NOGX_canvas_h ) {
			return;
		}
		
		global.__NOGX_canvas_w = cw;
		global.__NOGX_canvas_h = ch;
		
		if(global.__NOGX_resize_app_surf && application_surface_is_enabled()) {
			surface_resize(application_surface, cw, ch);
		}
		window_set_size(cw, ch);
	}
} else {
	global.__NOGX_window_w = -1;
	global.__NOGX_window_h = -1;
	
	update_canvas_size = function() {
		var w, h;
		if(os_browser==browser_not_a_browser) {
			w = window_get_width();
			h = window_get_height();
		} else {
			var scl = _NOGX_get_device_pixel_ratio_html5();
			w = browser_width * scl;
			h = browser_height * scl;
		}
		
		if( (w==global.__NOGX_window_w && h==global.__NOGX_window_h) || w<1 || h<1 ) {
			return;
		}
		
		global.__NOGX_window_w = w;
		global.__NOGX_window_h = h;
		
		var screenW = w;
		var screenH = h;
		
		if(global.__NOGX_limit_asp_ratio) {
			var asp = screenW/screenH;
			var aspLimited = clamp(asp, global.__NOGX_min_asp, global.__NOGX_max_asp);
			if(asp/aspLimited>=1) {
				screenW = floor(screenH * aspLimited);
			} else {
				screenH = floor(screenW / aspLimited);
			}
		}
		
		// blur fix:
		if(os_browser==browser_not_a_browser) {
			if(w % 2 != screenW % 2) screenW--;
			if(h % 2 != screenH % 2) screenH--;
		} else {
			if(screenW % 2 != 0) screenW--;
			if(screenH % 2 != 0) screenH--;
		}
		
		global.__NOGX_canvas_w = screenW;
		global.__NOGX_canvas_h = screenH;
		
		if(global.__NOGX_resize_app_surf && application_surface_is_enabled()) {
			surface_resize(application_surface, screenW, screenH);
		}
		
		if(os_browser!=browser_not_a_browser) {
			window_set_size(screenW, screenH);
			_NOGX_resize_canvas_html5(window_handle(), screenW / scl, screenH / scl);
		}
	}
}

var ts = time_source_create(time_source_global, 1, time_source_units_frames, update_canvas_size, [], -1);
time_source_start(ts);
global.__NOGX_canvas_size_update_ticker = ts;

if(os_type==os_gxgames) {
	if(code_is_compiled()) {
		// An alternative way to call ev_async_social from JS. Used for YYC.
		global.__NOGX_async_social_event_map = undefined;
		var GML_send_async_event_social = function(result) {
			global.__NOGX_async_social_event_map = ds_map_create();
			
			struct_foreach(result, function(name, value) {
				global.__NOGX_async_social_event_map[? name] = value;
			});
			
			event_perform_async(ev_async_social, global.__NOGX_async_social_event_map);
			global.__NOGX_async_social_event_map = undefined;
		}
		gxc_payment("#GMS_API_async_event_social", GML_send_async_event_social); // register callback
	}
	
	_NOGX_init_in_js(limit_asp_ratio, min_asp, max_asp);
}


#define _NOGX_free
if(global.__NOGX_canvas_size_update_ticker !=undefined) {
	time_source_destroy(global.__NOGX_canvas_size_update_ticker);
	global.__NOGX_canvas_size_update_ticker = undefined;
}


#define NOGX_get_canvas_width
return global.__NOGX_canvas_w!=-1 ? global.__NOGX_canvas_w : window_get_width(); 


#define NOGX_get_canvas_height
return global.__NOGX_canvas_h!=-1 ? global.__NOGX_canvas_h : window_get_height();


#define NOGX_get_pixel_ratio
return os_browser!=browser_not_a_browser ? _NOGX_get_device_pixel_ratio_html5() : 1;
