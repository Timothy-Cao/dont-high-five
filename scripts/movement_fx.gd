extends Node3D
## Bounded, cosmetic effects; no gameplay colliders or independent timers.
var player: CharacterBody3D
var ghosts: Array[Dictionary]=[]
var marks: Array[Dictionary]=[]
var interval:=0.0
var stamp_texture:GradientTexture2D
const GHOST_LIMIT:=6
const MARK_LIMIT:=24
const GHOST_LIFE:=0.30

func _ready() -> void:
	stamp_texture=GradientTexture2D.new();stamp_texture.width=64;stamp_texture.height=64
	stamp_texture.fill=GradientTexture2D.FILL_RADIAL;stamp_texture.fill_from=Vector2(0.5,0.5);stamp_texture.fill_to=Vector2(1,0.5)
	var gradient:=Gradient.new();gradient.offsets=PackedFloat32Array([0,0.82,1])
	gradient.colors=PackedColorArray([Color.WHITE,Color.WHITE,Color(1,1,1,0)])
	stamp_texture.gradient=gradient
	for i in GHOST_LIMIT:
		var root:=Node3D.new();add_child(root);root.hide()
		var body:Node3D=load("res://assets/courier.glb").instantiate();root.add_child(body)
		var skeleton:Skeleton3D=body.find_children("*","Skeleton3D",true,false)[0]
		var animation:AnimationPlayer=body.find_children("*","AnimationPlayer",true,false)[0]
		animation.stop();animation.active=false
		var mat:=StandardMaterial3D.new()
		mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.albedo_color=Color(0.25,0.85,0.77,0.15)
		for mesh in body.find_children("*","MeshInstance3D",true,false):
			mesh.material_override=mat;mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;mesh.layers=4
		var ball:=MeshInstance3D.new();var shape:=SphereMesh.new();shape.radius=0.32;shape.height=0.64
		ball.mesh=shape;ball.position.y=0.32;ball.material_override=mat;ball.layers=4
		ball.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;root.add_child(ball)
		ghosts.append({"root":root,"body":body,"skeleton":skeleton,"ball":ball,"mat":mat,"life":0.0})

func clear_history() -> void:
	interval=0
	for ghost in ghosts:
		ghost.life=0;ghost.root.hide()

func emit_ghost() -> void:
	var ghost:Dictionary=ghosts[0]
	for candidate in ghosts:
		if candidate.life<ghost.life: ghost=candidate
	ghost.root.global_transform=player.global_transform
	ghost.body.transform=player.avatar.body.transform
	ghost.body.visible=not player.ball;ghost.ball.visible=player.ball
	for bone in player.avatar.skeleton.get_bone_count():
		ghost.skeleton.set_bone_pose(bone,player.avatar.skeleton.get_bone_pose(bone))
	ghost.life=GHOST_LIFE;ghost.root.show()

func stamp(point: Vector3,normal: Vector3,color: Color,strength: float) -> void:
	if normal.length_squared()<0.5: return
	if marks.size()>=MARK_LIMIT:
		marks[0].root.queue_free();marks.pop_front()
	var root:=Node3D.new();add_child(root)
	var n:=normal.normalized()
	var right:=Vector3.UP.cross(n).normalized()
	if right.length_squared()<0.5: right=Vector3.RIGHT
	var up:=n.cross(right).normalized()
	root.global_transform=Transform3D(Basis(right,up,n),point+n*0.012)
	var mat:=StandardMaterial3D.new();mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;mat.albedo_color=Color(color,0.7);mat.albedo_texture=stamp_texture
	# A compact four-knuckle stamp, not a destructive-looking bullet hole.
	for i in 5:
		var mesh:=MeshInstance3D.new();var quad:=QuadMesh.new()
		quad.size=Vector2(0.095,0.11) if i<4 else Vector2(0.39,0.15)
		mesh.mesh=quad;mesh.position=Vector3((i-1.5)*0.105,0.10,0) if i<4 else Vector3(0,-0.04,0)
		mesh.material_override=mat;mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;root.add_child(mesh)
	root.scale=Vector3.ONE*lerpf(0.8,1.3,strength)
	marks.append({"root":root,"mat":mat,"life":12.0})

func _process(dt: float) -> void:
	if player.lab.paused: return
	interval=maxf(0,interval-dt)
	for ghost in ghosts:
		ghost.life=maxf(0,ghost.life-dt)
		ghost.root.visible=ghost.life>0
		var view:Camera3D=get_viewport().get_camera_3d()
		var distance:float=view.global_position.distance_to(ghost.root.global_position+Vector3.UP*0.7) if view else 5.0
		ghost.mat.albedo_color.a=0.12*ghost.life/GHOST_LIFE*smoothstep(1.1,2.4,distance)
	if player.velocity.length()>14 and interval<=0:
		emit_ghost();interval=0.055
	for i in range(marks.size()-1,-1,-1):
		var mark:Dictionary=marks[i]
		mark.life-=dt;mark.mat.albedo_color.a=0.65*clampf(mark.life/3.0,0,1)
		if mark.life<=0: mark.root.queue_free();marks.remove_at(i)
