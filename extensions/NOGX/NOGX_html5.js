function __NOGX_init_html5() {
	// disable context menu
	document.addEventListener('contextmenu', (event) => {
		event.preventDefault();
	});
	
	// disable scrollbars
	document.body.style.overflow = "hidden";
}

function __NOGX_get_device_pixel_ratio_html5() {
	return window.devicePixelRatio || 1;
}

function __NOGX_resize_canvas_html5(canvasId, w, h) {
	const el = document.getElementById(canvasId);
	el.style.width = w + "px";
	el.style.height = h + "px";
}

