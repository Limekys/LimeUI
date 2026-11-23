varying vec2 v_vTexcoord;
varying vec4 v_vColour;
uniform vec2 u_blur_step;

vec4 sampleBackdrop(vec2 offset)
{
    return texture2D(gm_BaseTexture, clamp(v_vTexcoord + offset, vec2(0.0), vec2(1.0)));
}

void main()
{
    // Linear filtering combines adjacent taps of the 17-sample Gaussian kernel.
    vec2 d1 = u_blur_step * 1.476580;
    vec2 d2 = u_blur_step * 3.445530;
    vec2 d3 = u_blur_step * 5.414899;
    vec2 d4 = u_blur_step * 7.384912;
    vec4 color = 0.103153 * sampleBackdrop(vec2(0.0));
    color += 0.191011 * (sampleBackdrop(-d1) + sampleBackdrop(d1));
    color += 0.140429 * (sampleBackdrop(-d2) + sampleBackdrop(d2));
    color += 0.080715 * (sampleBackdrop(-d3) + sampleBackdrop(d3));
    color += 0.036269 * (sampleBackdrop(-d4) + sampleBackdrop(d4));
    gl_FragColor = v_vColour * color;
}
