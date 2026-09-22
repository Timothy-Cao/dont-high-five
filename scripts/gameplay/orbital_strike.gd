extends Node3D
## Sustained, cover-aware area denial. Damage cadence and lifetime share physics time.
const P=preload("res://scripts/gameplay/props.gd")
const RADIUS:=18.0
const DURATION:=4.0
const TICK:=0.25
const DPS:=70.0
const SOUNDS=[preload("res://assets/audio/sfx/watcher_orbital_0.wav"),preload("res://assets/audio/sfx/watcher_orbital_1.wav"),preload("res://assets/audio/sfx/watcher_orbital_2.wav"),preload("res://assets/audio/sfx/watcher_orbital_3.wav")]
var watcher:Node3D
var age:=0.0
var damage_time:=0.0
var height:=30.0
const VISUAL_HEIGHT:=180.0
var curtains:Array[ShaderMaterial]=[]
var columns:Array[MeshInstance3D]=[]
var filaments:Array[MeshInstance3D]=[]
var debris:Array[Dictionary]=[]
var light:OmniLight3D
var sound:AudioStreamPlayer3D
var beams_mat:StandardMaterial3D
func _ready() -> void:
	set_meta("blackout_exempt",true)
	var space:=get_world_3d().direct_space_state
	var ceiling:=space.intersect_ray(PhysicsRayQueryParameters3D.create(global_position+Vector3.UP*0.2,global_position+Vector3.UP*44,1))
	height=maxf(0.5,ceiling.position.y-global_position.y) if not ceiling.is_empty() else 44.0
	for radius in [RADIUS]:
		var mesh:=CylinderMesh.new();mesh.top_radius=radius;mesh.bottom_radius=radius;mesh.height=VISUAL_HEIGHT;mesh.radial_segments=96;mesh.cap_top=true;mesh.cap_bottom=true
		var node:=MeshInstance3D.new();node.mesh=mesh;node.position.y=VISUAL_HEIGHT/2;node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(node)
		columns.append(node)
		var mat:=ShaderMaterial.new();mat.shader=load("res://shaders/orbital_curtain.gdshader");node.material_override=mat;curtains.append(mat)
	beams_mat=P.material(Color("ffb864"),8);beams_mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	beams_mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;beams_mat.blend_mode=BaseMaterial3D.BLEND_MODE_ADD
	for i in 25:
		var angle:=i*2.399963;var radius:=sqrt(float(i)/25.0)*(RADIUS-0.6)
		var foot:=Vector3(cos(angle)*radius,0,sin(angle)*radius)
		var top:Vector3=foot+Vector3.UP*VISUAL_HEIGHT
		var beam=P.beam(self,foot,top,Color("ffb864"),0.28 if i==0 else 0.045)
		beam.material_override=beams_mat;filaments.append(beam)
	for i in 40:
		var shape:=BoxMesh.new();shape.size=Vector3(0.07,1.4,0.07)
		var shard=P.mesh(self,shape,Vector3.ZERO,Color("ff603c"),4)
		shard.material_override=beams_mat;shard.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		debris.append({"node":shard,"angle":i*2.399963,"radius":RADIUS*sqrt(float(i+1)/41),"phase":float(i)/40})
	light=OmniLight3D.new();light.light_color=Color("ff5336");light.omni_range=RADIUS*2;light.position.y=minf(height*0.4,8);light.shadow_enabled=true;add_child(light)
	watcher.feedback.explosion(global_position,RADIUS*0.55)
	sound=AudioStreamPlayer3D.new();sound.bus="Effects";sound.stream=SOUNDS[get_instance_id()%4];sound.volume_db=-11
	sound.unit_size=24;sound.max_distance=260;sound.max_db=-11;sound.panning_strength=0.75;add_child(sound);sound.position.y=2
	if watcher.lab.audio_enabled:sound.play()
	animate()
func damage_tick(amount:float) -> void:
	for target in watcher.targets()+watcher.lab.arena.dummies:
		var center:Vector3=target.global_position+Vector3.UP
		var offset:Vector3=center-global_position
		if Vector2(offset.x,offset.z).length()>RADIUS or offset.y< -0.5 or offset.y>height:continue
		if watcher.clear_line(global_position+Vector3.UP*0.5,center,target):target.take_damage(amount,global_position,"orbital")
func animate() -> void:
	var envelope:=smoothstep(0.0,0.16,age)*(1-smoothstep(DURATION,DURATION+0.55,age))
	for mat in curtains:mat.set_shader_parameter("age",age);mat.set_shader_parameter("power",envelope)
	# The live column is solid from ignition through the damaging phase.
	# Only the residual filaments/light fade once the burn ends.
	for column in columns:column.visible=age<DURATION
	beams_mat.albedo_color.a=envelope*(0.7+0.3*sin(age*15))
	light.light_energy=envelope*(8+2*sin(age*11))
	for item in debris:
		var angle:float=item.angle+age*0.25
		item.node.position=Vector3(cos(angle)*item.radius,fposmod(item.phase*height+age*12,height),sin(angle)*item.radius)
		item.node.scale=Vector3.ONE*envelope
func _physics_process(dt:float) -> void:
	sound.stream_paused=watcher.lab.paused
	if watcher.lab.paused:return
	var live_step:=minf(dt,maxf(0,DURATION-age))
	age+=dt;damage_time+=live_step
	while damage_time>=TICK-0.00001:
		damage_time-=TICK;damage_tick(DPS*TICK)
	animate()
	if age>=DURATION+0.6:queue_free()
func _exit_tree() -> void:
	if is_instance_valid(sound):sound.stop()
