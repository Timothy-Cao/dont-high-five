shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix;
uniform vec4 tint : source_color = vec4(0.2,0.7,0.8,1.0);
void fragment() {
	vec2 p=(UV-0.5)*2.0;
	float r=length(p);
	float a=atan(p.y,p.x);
	float ribbon=pow(0.5+0.5*sin(r*18.0-a*2.0-TIME*1.4),7.0);
	float edge=smoothstep(0.68,1.0,r);
	ALBEDO=mix(tint.rgb*0.035,tint.rgb*0.48,ribbon*0.45+edge*0.45);
	EMISSION=tint.rgb*(ribbon*0.20+edge*0.28);
	ALPHA=(1.0-smoothstep(0.93,1.0,r));
}
