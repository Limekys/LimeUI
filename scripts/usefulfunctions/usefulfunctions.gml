function Approach(value, dest, amount) {
	return (value + clamp(dest - value, -amount, amount));
}

function ApproachDelta(value, dest, amount) {
	return (value + clamp(dest-value, -amount*DT, amount*DT));
}

function Chance(value) {
	return value>random(1);
}

function Wave(from, dest, duration, offset) {
	var a4 = (dest - from) * 0.5;
	return from + a4 + sin((((current_time * 0.001) + duration * offset) / duration) * (pi*2)) * a4;
}

function ReachTween(value, destination, smoothness) {
	return(lerp(value, destination, 1/smoothness));
}

function DrawSetText(color, font, haling, valing, alpha) {
	draw_set_color(color);
	draw_set_font(font);
	draw_set_halign(haling);
	draw_set_valign(valing);
	draw_set_alpha(alpha);
}

function DrawTextShadow(x, y, _string) {
	var color = draw_get_color();
	draw_set_color(c_black);
	draw_text(x + 1, y + 1, _string);
	draw_set_color(color);
	draw_text(x, y, _string);
}

function DrawTextOutline(x, y, _string, outwidth, outcolor, outfidelity) {
	//Created by Andrew McCluskey http://nalgames.com/
	//x,y: Coordinates to draw
	//str: String to draw
	//outwidth: Width of outline in pixels
	//outcol: Colour of outline (main text draws with regular set colour)
	//outfidelity: Fidelity of outline (recommended: 4 for small, 8 for medium, 16 for larger. Watch your performance!)

	var dto_dcol = draw_get_color();

	draw_set_color(outcolor);

	for(var dto_i = 45; dto_i < 405; dto_i += 360 / outfidelity) {
	    draw_text(x + lengthdir_x(outwidth, dto_i), y + lengthdir_y(outwidth, dto_i), _string);
	}

	draw_set_color(dto_dcol);
	draw_text(x, y, _string);
}

function DrawTextOutlineTransformed(x, y, _string, xscale, yscale, outwidth, outcolor, outfidelity) {
	var dto_dcol = draw_get_color();
	
	draw_set_color(outcolor);

	for(var dto_i = 45; dto_i < 405; dto_i += 360 / outfidelity) {
	    draw_text_transformed(x + lengthdir_x(outwidth, dto_i), y + lengthdir_y(outwidth, dto_i), _string, xscale, yscale, 0);
	}

	draw_set_color(dto_dcol);
	draw_text_transformed(x, y, _string, xscale, yscale, 0);
}

function DrawRectangleWidth(x1, y1, x2, y2, width, inside, outline) {
	///@desc by Limekys
	if !inside
	for (var i = 0; i < width; ++i) {
	    draw_rectangle(x1-i,y1-i,x2+i,y2+i, outline);
	}
	else
	for (var i = 0; i < width; ++i) {
	    draw_rectangle(x1+i,y1+i,x2-i,y2-i, outline);
	}
}

function StringZeroes(_string, _nubmer) {
	//Returns _string as a string with zeroes if it has fewer than _nubmer characters
	///eg string_zeroes(150,6) returns "000150" or
	///string_zeroes(mins,2)+":"+string_zeroes(secs,2) might return "21:02"
	///Created by Andrew McCluskey, use it freely

	var str = "";
	if string_length(string(_string)) < _nubmer {
	    repeat(_nubmer-string_length(string(_string))) str += "0";
	}
	str += string(_string);
	return str;
}

function DrawCircleCurve(_xx, _yy, _radius, _bones, _angle, _angleadd, _width, _outline) {
	///@desc draw_circle_curve(x,y,r,bones,ang,angadd,width,outline)
	/*
	x,y — Center of circle.
	r — Radius.
	bones — Amount of bones. More bones = more quality, but less speed. Minimum — 3.
	ang — Angle of first circle's point.
	angadd — Angle of last circle's point (relative to ang). 
	width — Width of circle (may be positive or negative).
	outline — 0 = curve, 1 = sector. 
	*/

	_bones = max(3,_bones);
	
	var a,lp,lm,dp,dm,AAa,Wh;
	a = _angleadd/_bones;
	Wh = _width/2;
	lp = _radius+Wh;
	lm = _radius-Wh;
	AAa = _angle+_angleadd;
	
	if _outline {
		//OUTLINE
		draw_primitive_begin(pr_trianglestrip);; //Change to pr_linestrip, to see how it works.
		draw_vertex(_xx+lengthdir_x(lm,_angle),_yy+lengthdir_y(lm,_angle)); //First point.
		for(var i=1; i<=_bones; ++i)
		{
			dp = _angle+a*i;
			dm = dp-a;
			draw_vertex(_xx+lengthdir_x(lp,dm),_yy+lengthdir_y(lp,dm));
			draw_vertex(_xx+lengthdir_x(lm,dp),_yy+lengthdir_y(lm,dp));
		}
		draw_vertex(_xx+lengthdir_x(lp,AAa),_yy+lengthdir_y(lp,AAa));
		draw_vertex(_xx+lengthdir_x(lm,AAa),_yy+lengthdir_y(lm,AAa)); //Last two points to make circle look right.
		//OUTLINE
	} else {
		//SECTOR
		draw_primitive_begin(pr_trianglefan); //Change to pr_linestrip, to see how it works.
		draw_vertex(_xx,_yy); //First point in the circle's center.
		for(var i=1; i<=_bones; ++i)
		{
			dp = _angle+a*i;
			dm = dp-a;
			draw_vertex(_xx+lengthdir_x(lp,dm),_yy+lengthdir_y(lp,dm));
		}
		draw_vertex(_xx+lengthdir_x(lp,AAa),_yy+lengthdir_y(lp,AAa)); //Last point.
		//SECTOR
	}
	draw_primitive_end();
}

function DrawHealthbarCircular(center_x, center_y, _radius, _start_ang, _health, _sprite) {
	///@desc draw_healthbar_circular(center_x,center_y,radius,start_angle,percent_health,sprite)
	
	var tex,steps,thick,oc;
	tex = sprite_get_texture(_sprite,0);
	steps = 200;
	thick = sprite_get_height(_sprite);

	if ceil(steps*(_health/100)) >= 1 {
		
		oc = draw_get_color();
		draw_set_color(c_white);
		
	    var step,ang,side,hps,hpd;
	    step = 0;
	    ang = _start_ang;
	    side = 0;
	    draw_primitive_begin_texture(pr_trianglestrip,tex);
	    draw_vertex_texture(center_x+lengthdir_x(_radius-thick/2+thick*side,ang),center_y+lengthdir_y(_radius-thick/2+thick*side,ang),side,side);
	    side = !side;
	    draw_vertex_texture(center_x+lengthdir_x(_radius-thick/2+thick*side,ang),center_y+lengthdir_y(_radius-thick/2+thick*side,ang),side,side);
	    side = !side;
	    draw_vertex_texture(center_x+lengthdir_x(_radius-thick/2+thick*side,ang+360/steps),center_y+lengthdir_y(_radius-thick/2+thick*side,ang+360/steps),side,side);
	    side = !side;
	    hps = _health/(ceil(steps*(_health/100))+1);
	    hpd = 0;
	    repeat ceil(steps*(_health/100)+1) {
	        step++;
	        if step == ceil(steps*(_health/100)+1) { //final step
	            ang += (360/steps)*(_health - hpd)/2;
	            if ang>_start_ang+360 ang=_start_ang+360
	            draw_vertex_texture(center_x+lengthdir_x(_radius-thick/2+thick*side,ang),center_y+lengthdir_y(_radius-thick/2+thick*side,ang),side,side);
	            side = !side;
	            draw_vertex_texture(center_x+lengthdir_x(_radius-thick/2+thick*side,ang),center_y+lengthdir_y(_radius-thick/2+thick*side,ang),side,side);
	        }
	        else {
	            ang+=360/steps;
	            draw_vertex_texture(center_x+lengthdir_x(_radius-thick/2+thick*side,ang),center_y+lengthdir_y(_radius-thick/2+thick*side,ang),side,side);
	            side = !side;
	        }
	        hpd += hps;
	    }
	    draw_primitive_end();
	    draw_set_color(oc);
	}
}

function print_format(_string, struct) {
	var list = variable_struct_get_names(struct);
	for(var i = 0; i < array_length(list); i++){
		var find = "${"+list[i]+"}"
		_string = string_replace_all(_string, find, struct[$ list[i]]);
	}
	return _string;
}

function print() {
	var time = print_format("[${hour}:${minute}:${second}]",{
		hour: current_hour,
		minute: current_minute,
		second: current_second
	});
	var caller = print_format("[${caller}]",{caller: argument[0]});
	var msg = "";
	for(var i = 1; i < argument_count; i++){
		msg += string(argument[i]) + " ";
	}
	var result = time+caller+": "+msg;
	show_debug_message(result);
}

function range(value, old_min, old_max, new_min, new_max) {
	return ((value - old_min) / (old_max - old_min)) * (new_max - new_min) + new_min;
}