varying vec2 v_vTexcoord;
varying vec4 v_vColour;
uniform sampler2D u_mask;
uniform vec4 u_mask_uvs;   // Mask bounds on the texture page: left, top, right, bottom

void main()
{
    vec4 c = texture2D(gm_BaseTexture, v_vTexcoord);   // premultiplied
    vec2 muv = mix(u_mask_uvs.xy, u_mask_uvs.zw, v_vTexcoord);
    float m = texture2D(u_mask, muv).a;
    gl_FragColor = v_vColour * c * m;
}
