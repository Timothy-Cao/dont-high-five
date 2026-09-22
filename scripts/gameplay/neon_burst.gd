extends Node3D
## One bounded expanding geometric burst: cages, ballistic data shards, flash and local light.
const P=preload("res://scripts/gameplay/props.gd")
var lab:Node3D
var radius:=7.0
var age:=0.0
var cages:Array[Node3D]=[]
var pieces:Array[Dictionary]=[]
var light:OmniLight3D
var flash:MeshInstance3D
var flash_mat:ShaderMaterial
var cage_materials:Array[StandardMaterial3D]=[]
func _ready() -> void:
	set_meta("blackout_exempt",true)
	for layer in 2:
		var material=P.material(Color("ff244a") if layer==0 else Color("ffab38"),8)
		material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
		material.blend_mode=BaseMaterial3D.BLEND_MODE_ADD
		cage_materials.append(material)
		var cage:=Node3D.new();add_child(cage);cages.append(cage)
		var vertices=[Vector3.UP,Vector3.DOWN,Vector3.LEFT,Vector3.RIGHT,Vector3.FORWARD,Vector3.BACK]
		for i in 6:
			for j in range(i+1,6):
				if absf(vertices[i].dot(vertices[j]))>0.1:continue
				var edge=P.beam(cage,vertices[i],vertices[j],Color("ff244a") if layer==0 else Color("ffab38"),0.004)
				edge.material_override=material
	var random:=RandomNumberGenerator.new();random.seed=get_instance_id()
	for i in 48:
		var direction:=Vector3(random.randf_range(-1,1),random.randf_range(-0.25,1),random.randf_range(-1,1)).normalized()
		var shard:=MeshInstance3D.new();var shape:=BoxMesh.new();shape.size=Vector3(0.055,0.055,random.randf_range(0.45,1.6));shard.mesh=shape
		shard.material_override=P.material(Color("ffb754") if i%3 else Color("fa2459"),6);shard.material_override.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
		shard.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(shard)
		shard.basis=Basis.looking_at(direction,Vector3.FORWARD if absf(direction.y)>0.95 else Vector3.UP)
		pieces.append({"node":shard,"velocity":direction*random.randf_range(radius*0.8,radius*1.7)})
	flash=MeshInstance3D.new();var quad:=QuadMesh.new();quad.size=Vector2.ONE*radius*3;flash.mesh=quad;add_child(flash)
	flash_mat=ShaderMaterial.new();flash_mat.shader=load("res://shaders/energy_flash.gdshader");flash.material_override=flash_mat;flash.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	light=OmniLight3D.new();light.omni_range=radius*2.4;light.light_color=Color("ff713b");light.shadow_enabled=false;add_child(light)
	animate(0.0)
func animate(time:float) -> void:
	for i in cages.size():
		var fraction:=clampf((time-i*0.045)/0.7,0,1)
		cages[i].scale=Vector3.ONE*maxf(0.02,radius*(1-pow(1-fraction,3)))
		cages[i].rotation=Vector3(time*.45+i*.7,time*.3+i*.5,i*.4)
		cages[i].visible=time<0.85-i*.1
		cage_materials[i].albedo_color.a=pow(1-fraction,1.5)
		cage_materials[i].emission_energy_multiplier=8*pow(1-fraction,0.5)
	for item in pieces:
		item.node.position=item.velocity*time+Vector3.DOWN*3*time*time
		item.node.scale=Vector3.ONE*maxf(0.01,1-time/1.2)
	flash_mat.set_shader_parameter("strength",exp(-time*11)*1.8)
	light.light_energy=14*exp(-time*8)
func _process(dt:float) -> void:
	if lab.paused:return
	age+=dt;animate(age)
	if age>=1.3:queue_free()
