shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, fog_disabled;
uniform float age = 0.0;
void fragment() {
    vec2 p = (UV-0.5)*2.0;
    float r = length(p);
    float circle = 1.0-smoothstep(0.99,1.0,r);
    float rim = smoothstep(0.96,0.975,r)*circle;
    float tick = step(0.68,fract(atan(p.y,p.x)*3.81972));
    float inner = smoothstep(0.86,0.88,r)*(1.0-smoothstep(0.9,0.92,r))*tick;
    float pulse = 0.5+0.5*sin(age*14.0);
    vec3 color = mix(vec3(1.0,0.08,0.025),vec3(1.0,0.5,0.12),pulse*0.3);
    ALBEDO = color;
    EMISSION = color*(2.0+2.0*pulse);
    ALPHA = circle*0.065+rim*0.87+inner*(0.4+0.25*pulse);
}
