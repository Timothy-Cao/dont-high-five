extends Node3D
## Visual-only rigid-part prototype. Movement remains owned by the player controller.
var body: Node3D
var ball_shell: MeshInstance3D
var feet: Array[Node3D]=[]
var foot_rest: Array[Vector3]=[]
var gait:=0.0

func _ready() -> void:
	body=load("res://assets/courier.glb").instantiate();add_child(body)
	for piece in body.find_children("*","GeometryInstance3D",true,false): piece.layers=4
	for name in ["left_foot","right_foot","sole_-1","sole_1"]:
		var foot=body.find_child(name,true,false)
		if foot: feet.append(foot);foot_rest.append(foot.position)
	ball_shell=MeshInstance3D.new()
	var sphere:=SphereMesh.new();sphere.radius=0.32;sphere.height=0.64;sphere.radial_segments=40;sphere.rings=20
	ball_shell.mesh=sphere
	var mat:=StandardMaterial3D.new();mat.albedo_color=Color("7ca99c");mat.roughness=0.55
	ball_shell.material_override=mat;ball_shell.position.y=0.32;ball_shell.layers=4
	add_child(ball_shell)
	for axis in [Vector3.RIGHT,Vector3.FORWARD]:
		var band:=MeshInstance3D.new();var ring:=TorusMesh.new();ring.inner_radius=0.305;ring.outer_radius=0.328;ring.rings=40;ring.ring_segments=6
		band.mesh=ring;band.rotation=axis*PI/2;band.layers=4
		var rubber:=StandardMaterial3D.new();rubber.albedo_color=Color("172d36")
		band.material_override=rubber;ball_shell.add_child(band)

func pose(p: CharacterBody3D,dt: float) -> void:
	body.visible=not p.ball;ball_shell.visible=p.ball
	var speed:=Vector2(p.velocity.x,p.velocity.z).length()
	if p.ball:
		var local_velocity:Vector3=p.global_basis.inverse()*p.velocity
		var axis:=Vector3.UP.cross(Vector3(local_velocity.x,0,local_velocity.z))
		if axis.length()>0.01: ball_shell.rotate(axis.normalized(),speed*dt/0.32)
		return
	gait+=speed*dt*4.2
	var walking:=p.is_on_floor() and speed>0.25
	body.scale.y=lerpf(body.scale.y,0.60 if p.crouched else 1.0,1-exp(-dt*18))
	body.position.y=absf(sin(gait))*0.025 if walking else 0
	for i in feet.size():
		var phase:float=gait+(PI if i%2 else 0)
		var offset:=Vector3(0,maxf(0,sin(phase))*0.065,cos(phase)*0.10) if walking else Vector3.ZERO
		feet[i].position=foot_rest[i]+offset

