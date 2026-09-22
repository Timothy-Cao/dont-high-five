shader_type spatial;
render_mode specular_disabled;
uniform float power = 1.0;
uniform vec4 base_color : source_color = vec4(0.019,0.029,0.047,1.0);
varying vec3 world_position;
varying vec3 world_normal;
float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
void vertex() {
    world_normal=normalize(MODEL_NORMAL_MATRIX*NORMAL);
    world_position=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
}
void fragment() {
    vec3 n=abs(normalize(world_normal));
    vec2 plane=n.y>=max(n.x,n.z)?world_position.xz:(n.x>n.z?world_position.zy:world_position.xy);
    // The original sparse floor flecks, at the same tiny scale on vertical faces.
    vec2 tile=plane*3.0;
    float seed=hash(floor(tile));
    float fleck=step(0.90,seed)*(1.0-smoothstep(0.05,0.15,length(fract(tile)-0.5)));
    ALBEDO=base_color.rgb*(0.94+0.12*hash(floor(tile*4.0)));
    EMISSION=mix(vec3(0.075,0.15,0.25),vec3(0.18,0.055,0.14),seed)*fleck*power*(n.y<0.65?0.35:0.65);
    ROUGHNESS=0.96;
}
