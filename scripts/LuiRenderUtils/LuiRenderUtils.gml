#macro LUI_CACHE_MAX_SIZE 8192
#macro LUI_GRID_STRIDE 65536

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

/// Writes the intersection of the parent clip and the transformed child clip into an existing array.
function _luiClipChildrenInto(_dst, _clip, _el, _m) {
	var _style = _el.getStyle();
	var _o = is_undefined(_style) ? _el.render_region_offset : _style.render_region_offset;
	var _x1 = _el.x + _o.left;
	var _y1 = _el.y + _o.top;
	var _x2 = _el.x + _el.width - _o.right;
	var _y2 = _el.y + _el.height - _o.bottom;
	var _ax = _x1 * _m[0] + _y1 * _m[4] + _m[12];
	var _ay = _x1 * _m[1] + _y1 * _m[5] + _m[13];
	var _bx = _x2 * _m[0] + _y1 * _m[4] + _m[12];
	var _by = _x2 * _m[1] + _y1 * _m[5] + _m[13];
	var _cx = _x1 * _m[0] + _y2 * _m[4] + _m[12];
	var _cy = _x1 * _m[1] + _y2 * _m[5] + _m[13];
	var _dx = _x2 * _m[0] + _y2 * _m[4] + _m[12];
	var _dy = _x2 * _m[1] + _y2 * _m[5] + _m[13];
	_dst[0] = max(_clip[0], min(_ax, _bx, _cx, _dx));
	_dst[1] = max(_clip[1], min(_ay, _by, _cy, _dy));
	_dst[2] = min(_clip[2], max(_ax, _bx, _cx, _dx));
	_dst[3] = min(_clip[3], max(_ay, _by, _cy, _dy));
}

/// _shader: ассет шейдера
/// _apply: function(_element, _material) — выставляет uniform'ы/текстуры (можно undefined)
/// _group: true = применять шейдер ко всему поддереву при выводе кеша
function luiMaterial(_shader, _apply = undefined, _group = false) {
	return { shader: _shader, apply: _apply, group: _group };
}

/// Материал-маска: альфа спрайта-маски умножается на всю группу (скруглённые карточки, круглые портреты).
/// Маска растягивается на весь элемент: используйте cache_padding = 0 и спрайт без обрезки (Crop выключен).
function luiMaskMaterial(_shader, _mask_sprite) {
	var _uvs = sprite_get_uvs(_mask_sprite, 0);   // [left, top, right, bottom, ...]
	var _mat = luiMaterial(_shader, function(_e, _mat) {
		texture_set_stage(_mat.s_mask, sprite_get_texture(_mat.sprite, 0));
		shader_set_uniform_f(_mat.u_uvs, _mat.uv_l, _mat.uv_t, _mat.uv_r, _mat.uv_b);
	}, true);
	_mat.sprite = _mask_sprite;
	_mat.s_mask = shader_get_sampler_index(_shader, "u_mask");
	_mat.u_uvs = shader_get_uniform(_shader, "u_mask_uvs");
	_mat.uv_l = _uvs[0];
	_mat.uv_t = _uvs[1];
	_mat.uv_r = _uvs[2];
	_mat.uv_b = _uvs[3];
	return _mat;
}