shader_type spatial;
render_mode unshaded, depth_draw_opaque, cull_disabled, fog_disabled;
uniform float age = 0.0;
uniform float power : hint_range(0.0,1.0) = 1.0;
void fragment() {
    float vertical = pow(0.5+0.5*sin(UV.x*100.5309+sin(UV.y*50.0-age*7.0)*0.3),6.0);
    float packets = 0.35+0.65*pow(0.5+0.5*sin(UV.y*120.0+age*18.0+UV.x*19.0),2.0);
    float fine = pow(0.5+0.5*sin(UV.x*402.1239-UV.y*12.0-age*2.0),20.0);
    float edge = pow(1.0-abs(dot(normalize(NORMAL),normalize(VIEW))),3.0);
    float energy = clamp(vertical*packets+fine*0.3+edge*0.6,0.0,1.0);
    vec3 hot = mix(vec3(0.6,0.015,0.008),vec3(1.0,0.65,0.22),energy);
    ALBEDO = hot;
    EMISSION = hot*(0.7+energy*4.5)*(0.8+power*0.2);
}
