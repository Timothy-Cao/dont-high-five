extends Node
## Camera-only environment plus a pre-HUD display filter. High Fiver lighting is untouched.
var watcher:Node3D
var environment:Environment
var layer:CanvasLayer
var screen:ColorRect
const DARK_BEAT:=0.5
const BOOT_TIME:=0.45
var elapsed:=0.0
var enabled_before:=false
# Independent future/testing option. Blackout never grants this automatically.
var available:=false
var gain:=0.0
func _ready() -> void:
	environment=watcher.lab.environment.duplicate()
	environment.ambient_light_color=Color.WHITE;environment.ambient_light_energy=0.9
	environment.background_color=Color("020803");environment.fog_light_color=Color("15261a");environment.fog_light_energy=0.3;environment.fog_density=0.004
	environment.glow_intensity=0.18
	layer=CanvasLayer.new();layer.layer=0;add_child(layer)
	screen=ColorRect.new();screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);screen.mouse_filter=Control.MOUSE_FILTER_IGNORE;layer.add_child(screen)
	var mat:=ShaderMaterial.new();mat.shader=load("res://shaders/night_vision.gdshader");screen.material=mat
	update_view()
func update_view() -> void:
	var enabled:bool=available and watcher.active and watcher.blackout>0
	if enabled!=enabled_before:
		elapsed=0;enabled_before=enabled
	var boot:=maxf(0,elapsed-DARK_BEAT)
	gain=smoothstep(0.0,BOOT_TIME,boot) if enabled else 0.0
	# Two short startup dropouts, then a stable image; no perpetual strobe.
	if (boot>0.085 and boot<0.12) or (boot>0.225 and boot<0.25):gain*=0.2
	var visible_mode:=enabled and elapsed>=DARK_BEAT
	environment.ambient_light_energy=0.9*gain;environment.fog_light_energy=0.3*gain
	watcher.camera.environment=environment if visible_mode else null
	screen.material.set_shader_parameter("boot_gain",gain)
	screen.visible=visible_mode and watcher.camera.current
func _process(dt:float) -> void:
	update_view()
	if enabled_before and not watcher.lab.paused:elapsed+=dt
	update_view()
