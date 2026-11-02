#macro LUI_CACHE_MAX_SIZE 8192

/// Блендинг для РИСОВАНИЯ В кеш-поверхность (результат — premultiplied alpha)
function _luiBlendBake() {
	gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha);
}

/// Блендинг для ВЫВОДА premultiplied-поверхности (в экран или в другую поверхность)
function _luiBlendBlit() {
	gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
}

/// Обычный блендинг (предполагается, что в GUI всегда bm_normal)
function _luiBlendReset() {
	gpu_set_blendmode(bm_normal);
}

/// Пересечение двух прямоугольников [x1, y1, x2, y2]
function _luiClipIntersect(_a, _b) {
	return [max(_a[0], _b[0]), max(_a[1], _b[1]), min(_a[2], _b[2]), min(_a[3], _b[3])];
}

/// Применяет прямоугольник [x1, y1, x2, y2] как scissor
function _luiApplyClip(_c) {
	var _x = floor(_c[0]);
	var _y = floor(_c[1]);
	gpu_set_scissor(_x, _y, max(0, ceil(_c[2]) - _x), max(0, ceil(_c[3]) - _y));
}

/// AABB прямоугольника после применения матрицы (строчная конвенция GM: v * M)
function _luiTransformRect(_m, _x1, _y1, _x2, _y2) {
	var _ax = _x1 * _m[0] + _y1 * _m[4] + _m[12];
	var _ay = _x1 * _m[1] + _y1 * _m[5] + _m[13];
	var _bx = _x2 * _m[0] + _y1 * _m[4] + _m[12];
	var _by = _x2 * _m[1] + _y1 * _m[5] + _m[13];
	var _cx = _x1 * _m[0] + _y2 * _m[4] + _m[12];
	var _cy = _x1 * _m[1] + _y2 * _m[5] + _m[13];
	var _dx = _x2 * _m[0] + _y2 * _m[4] + _m[12];
	var _dy = _x2 * _m[1] + _y2 * _m[5] + _m[13];
	return [min(_ax, _bx, _cx, _dx), min(_ay, _by, _cy, _dy), max(_ax, _bx, _cx, _dx), max(_ay, _by, _cy, _dy)];
}

/// Прямоугольник клипа детей элемента (в координатах после матрицы _m)
function _luiElementClipRect(_el, _m) {
	var _style = _el.getStyle();
	var _o = is_undefined(_style) ? _el.render_region_offset : _style.render_region_offset;
	return _luiTransformRect(_m,
		_el.x + _o.left, _el.y + _o.top,
		_el.x + _el.width - _o.right, _el.y + _el.height - _o.bottom);
}