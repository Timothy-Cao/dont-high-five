shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
void fragment() {
	float edge = pow(abs(UV.x * 2.0 - 1.0), 12.0);
	float grid = step(0.94, fract(UV.x * 24.0)) + step(0.965, fract(UV.y * 22.0));
	float scan = pow(max(0.0, sin(UV.y * 95.0 - TIME * 1.8)), 18.0);
	ALBEDO = vec3(0.9, 0.045, 0.12);
	EMISSION = vec3(1.1, 0.035, 0.12) * (0.2 + grid * 0.55 + edge);
	ALPHA = 0.10 + edge * 0.32 + grid * 0.14 + scan * 0.045;
}
