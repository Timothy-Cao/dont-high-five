shader_type spatial;
render_mode unshaded, depth_test_disabled, depth_draw_never, fog_disabled, shadows_disabled;
void fragment() {
 ALPHA = 0.96;
 ALBEDO = vec3(1.0, 0.78, 0.025);
 EMISSION = vec3(1.0, 0.68, 0.01) * 1.4;
}
