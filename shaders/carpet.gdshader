shader_type spatial;
render_mode specular_disabled;
varying vec3 world_position;
float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
void vertex() { world_position=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
void fragment() {
	vec2 tile=world_position.xz*3.0;
	float seed=hash(floor(tile));
	float fleck=step(0.90,seed)*(1.0-smoothstep(0.05,0.15,length(fract(tile)-0.5)));
	ALBEDO=vec3(0.019,0.029,0.047)*(0.94+0.12*hash(floor(tile*4.0)));
	EMISSION=mix(vec3(0.075,0.15,0.25),vec3(0.18,0.055,0.14),seed)*fleck*0.65;
	ROUGHNESS=0.96;
}
