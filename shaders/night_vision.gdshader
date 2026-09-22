shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float boot_gain : hint_range(0.0,1.0) = 1.0;
void fragment() {
    vec3 scene = texture(screen_texture,SCREEN_UV).rgb;
    float luma = dot(scene,vec3(0.299,0.587,0.114));
    float value = pow(max(luma - 0.025,0.0),0.85);
    value = value / (0.45 + value);
    vec2 centered = SCREEN_UV * 2.0 - 1.0;
    float vignette = 1.0 - 0.16 * dot(centered,centered);
    vec3 phosphor = mix(vec3(0.005,0.014,0.008),vec3(0.35,1.0,0.48),value);
    COLOR = vec4(mix(scene,phosphor * vignette,boot_gain),1.0);
}
