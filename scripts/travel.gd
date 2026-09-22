extends Node3D
## Swept portal crossings and deliberate ballistic pads. No dependency on camera mode.
var lab: Node3D
var portals: Array[Dictionary]=[]
var launch_pads: Array[Dictionary]=[]
var portal_count:=0
var pad_count:=0
var flash:=0.0

func add_portal(a: Node3D,base: Vector3,yaw: float,color: Color,pair: int) -> void:
	var b:=Basis(Vector3.UP,yaw)
	var xf:=Transform3D(b,base+Vector3.UP*2.2)
	portals.append({"xf":xf,"base":base,"pair":pair,"color":color})
	for x in [-2.25,2.25]:
		a.block(base+b*Vector3(x,2.2,0),Vector3(0.32,4.7,0.6),a.WALL,true,b)
		a.stripe(base+b*Vector3(x,2.2,0.34),Vector3(0.09,4.2,0.035),color,b)
	a.block(base+Vector3.UP*4.55,Vector3(4.8,0.3,0.6),a.WALL,true,b)
	var mesh:=MeshInstance3D.new()
	var quad:=QuadMesh.new();quad.size=Vector2(4.25,4.4)
	mesh.mesh=quad
	var material:=ShaderMaterial.new();material.shader=load("res://shaders/portal.gdshader")
	material.set_shader_parameter("tint",color)
	mesh.material_override=material;mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh);mesh.transform=xf
	var ring:=MeshInstance3D.new();var torus:=TorusMesh.new()
	torus.inner_radius=2.03;torus.outer_radius=2.12;torus.rings=64;torus.ring_segments=8
	ring.mesh=torus;ring.material_override=a.material(color,0.9)
	ring.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(ring);ring.transform=xf*Transform3D(Basis(Vector3.RIGHT,PI/2),Vector3.ZERO)
	# One or two short bars give each pair an identity beyond color alone.
	for i in pair+1: a.stripe(base+b*Vector3((i-pair*0.5)*0.4,4.56,0.34),Vector3(0.23,0.11,0.04),color,b)

func add_pad(a: Node3D,pos: Vector3,target: Vector3,flight: float,color: Color) -> void:
	var v:=(target-pos)/flight+Vector3.UP*12.0*flight
	var horizontal:=Vector3(v.x,0,v.z).normalized()
	var b:=Basis.looking_at(horizontal,Vector3.UP)
	launch_pads.append({"pos":pos,"target":target,"velocity":v,"basis":b,"flight":flight})
	# Flush to its floor: stepping onto it works without first jumping a lip.
	a.block(pos-Vector3.UP*0.015,Vector3(4.4,0.035,5.5),Color("344156"),false,b)
	for x in [-2.05,2.05]: a.stripe(pos+b*Vector3(x,0.018,0),Vector3(0.10,0.03,5.3),color,b)
	for z in [-1.5,0,1.5]:
		for side in [-1,1]:
			var arrow_basis:=b*Basis(Vector3.UP,side*0.60)
			a.stripe(pos+b*Vector3(side*0.48,0.024,z),Vector3(0.14,0.03,1.7),color,arrow_basis)

func update_player(p: CharacterBody3D,from: Vector3,dt: float) -> void:
	p.portal_lock=maxf(0,p.portal_lock-dt);p.pad_lock=maxf(0,p.pad_lock-dt)
	flash=move_toward(flash,0,dt*3)
	if from.distance_to(p.position)>6: return
	if p.portal_lock<=0:
		for i in portals.size():
			var gate:Dictionary=portals[i]
			var inv:Transform3D=gate.xf.affine_inverse()
			var start:Vector3=inv*(from+p.collider.position)
			var end:Vector3=inv*(p.position+p.collider.position)
			if start.z<=0 or end.z>0: continue
			var hit:=start.lerp(end,start.z/(start.z-end.z))
			var half_height:float=0.32 if p.ball else (0.525 if p.crouched else 0.9)
			if absf(hit.x)>1.64 or absf(hit.y)>2.2-half_height+0.02: continue
			var partner:=i+1 if i%2==0 else i-1
			if transfer(p,i,partner,hit): return
	if p.pad_lock<=0 and not p.held("brake") and not p.held("anchor"):
		for pad in launch_pads:
			var local:Vector3=pad.basis.inverse()*(p.position-pad.pos)
			if absf(local.x)<2.05 and absf(local.z)<2.6 and local.y>=-0.05 and local.y<0.18 and p.velocity.y<=0.1:
				p.launch_from_pad(pad.velocity)
				p.pad_lock=0.65;pad_count+=1
				lab.sound("pad")
				return

func transfer(p: CharacterBody3D,source: int,destination: int,local_hit: Vector3) -> bool:
	var src:Transform3D=portals[source].xf
	var dst:Transform3D=portals[destination].xf
	var rotation:=dst.basis*Basis(Vector3.UP,PI)*src.basis.inverse()
	var arrival:Vector3=dst*Vector3(-local_hit.x,local_hit.y,1.2)-p.collider.position
	arrival.y=maxf(arrival.y,portals[destination].base.y+0.045)
	var q:=PhysicsShapeQueryParameters3D.new()
	q.shape=p.collider.shape;q.transform=Transform3D(Basis.IDENTITY,arrival+p.collider.position)
	q.collision_mask=1;q.exclude=[p.get_rid()]
	if not get_world_3d().direct_space_state.intersect_shape(q,1).is_empty(): return false
	var cargo_arrival:=Vector3.ZERO
	if p.has_cargo():
		cargo_arrival=arrival+rotation*(p.cargo.global_position-p.global_position)
		var cq:=PhysicsShapeQueryParameters3D.new();var cs:=SphereShape3D.new();cs.radius=0.48;cq.shape=cs;cq.transform.origin=cargo_arrival;cq.collision_mask=1;cq.exclude=[p.get_rid()]
		if not get_world_3d().direct_space_state.intersect_shape(cq,1).is_empty():return false
	p.cancel_hands();p.clear_mouse_chord()
	p.position=arrival;p.velocity=rotation*p.velocity
	p.global_basis=rotation*p.global_basis
	if p.has_cargo():
		p.cargo.global_position=cargo_arrival;p.cargo.velocity=p.velocity;p.hands[p.cargo_hand].point=cargo_arrival
	p.portal_lock=0.65;p.wall_lock=0.2;p.wall_clinging=false
	p.flying=true;p.flight_time=0;p.launch_origin=arrival;p.momentum_air=true
	p.camera_cut=true
	lab.arena.previous_body=arrival+p.collider.position
	portal_count+=1;flash=0.65
	lab.sound("portal")
	return true

