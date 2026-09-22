shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, fog_disabled;
uniform vec4 tint : source_color = vec4(1.0, 0.15, 0.2, 0.4);
varying vec3 world_position;
void vertex() { world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
    float near_fade = smoothstep(2.0, 9.0, distance(CAMERA_POSITION_WORLD, world_position));
    ALBEDO = tint.rgb;
    EMISSION = tint.rgb * 1.6;
    ALPHA = tint.a * near_fade;
}
