shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, fog_disabled;
uniform vec4 tint : source_color = vec4(1.0,0.12,0.025,1.0);
uniform float strength = 1.0;
void vertex() {
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
    MODELVIEW_MATRIX[0].xyz *= length(MODEL_MATRIX[0].xyz);
    MODELVIEW_MATRIX[1].xyz *= length(MODEL_MATRIX[1].xyz);
}
void fragment() {
    vec2 p = UV * 2.0 - 1.0;
    float r = length(p);
    float flare = exp(-r * 9.0) * 5.0;
    flare += pow(max(0.0,1.0-abs(p.x)),65.0) * exp(-abs(p.y)*3.0) * 0.35;
    flare += pow(max(0.0,1.0-abs(p.y)),85.0) * exp(-abs(p.x)*2.7) * 0.5;
    ALBEDO = tint.rgb;
    EMISSION = mix(tint.rgb,vec3(1.0,0.9,0.7),exp(-r*9.0)) * 14.0;
    ALPHA = clamp(flare * strength,0.0,1.0);
}
