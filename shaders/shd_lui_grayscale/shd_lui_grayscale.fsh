varying vec2 v_vTexcoord;
varying vec4 v_vColour;
uniform float u_amount;

void main()
{
    vec4 c = texture2D(gm_BaseTexture, v_vTexcoord);
    float g = dot(c.rgb, vec3(0.299, 0.587, 0.114));
    c.rgb = mix(c.rgb, vec3(g), u_amount);
    gl_FragColor = v_vColour * c;
}