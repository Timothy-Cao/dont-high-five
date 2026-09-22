extends Node3D
const P=preload("res://scripts/gameplay/props.gd")
var lab:Node3D
var towers:Array[Dictionary]=[]
var camera:Camera3D
var active:=false
var selected:=0
var auto_fire:=false
var demo_patrol:=true
var pressure:="Patrol"
var single_tower:=false
func set_pressure(value:String) -> void:
	if value not in ["Peaceful","One tower","Patrol","Chaos"]:return
	pressure=value;single_tower=value=="One tower";auto_fire=value in ["One tower","Chaos"];demo_patrol=value=="Patrol"
	if lab.builder and lab.builder.testing and lab.session.watcher==self:lab.builder.pressure=value
var reveal:Node3D
var reveal_left:=0.0
var scope:=false
var firing:=false
var yaw:=0.0
var pitch:=-0.4
var cooldowns:Dictionary={"gun":0.0,"grenade":0.0,"strike":0.0,"blackout":0.0,"mine":0.0,"reveal":0.0}
var blackout:=0.0
var mines:Array[Node3D]=[]
var entry_grace:=0.0
var stationary:=0.0
var saved_position:=Vector3.ZERO
var saved_rotation:=Vector3.ZERO
var saved_health:=100.0
var bombs:Array[Dictionary]=[]
var strikes:Array[Dictionary]=[]
var fields:Array[Node3D]=[]
var effects:Array[Dictionary]=[]
var shots:=0
var hit_confirm:=0.0
var shot_flash:=0.0
var feedback:Node3D
const SNIPER_INTERVAL:=0.4
const GRENADE_INTERVAL:=0.25
const STRIKE_INTERVAL:=5.0
const MG_INTERVAL:=0.10/3.0
const MG_SPREAD:=0.036
const MINE_INTERVAL:=2.0
var rng:=RandomNumberGenerator.new()
var darkness:Node
var night_vision:Node
var tower_ai:RefCounted
func build() -> void:
	rng.seed=260921
	tower_ai=load("res://scripts/gameplay/tower_ai.gd").new();tower_ai.watcher=self
	var tower_positions:Array[Vector3]=lab.session.positions("tower")
	for i in tower_positions.size():
		var pos:=tower_positions[i];var floor_y:float=lab.session.layout.get_node("Eye%02d"%(i+1)).get_meta("base_y",0.0)
		var base:=Vector3(pos.x,floor_y,pos.z)
		var pedestal=load("res://assets/watcher_base.glb").instantiate();add_child(pedestal);pedestal.position=base
		var shaft=load("res://assets/watcher_shaft.glb").instantiate();add_child(shaft);shaft.position=base+Vector3.UP*0.7;shaft.scale.y=maxf(1,pos.y-floor_y-3.0)
		var solid:=StaticBody3D.new();add_child(solid);solid.position=base+Vector3.UP*(pos.y-floor_y-2.2)/2;solid.set_meta("grippy",true)
		var col:=CollisionShape3D.new();var shape:=BoxShape3D.new();shape.size=Vector3(1.95,pos.y-floor_y-2.2,1.7);col.shape=shape;solid.add_child(col)
		var crown=load("res://assets/watcher_crown.glb").instantiate();add_child(crown);crown.position=pos;crown.rotation.y=atan2(pos.x,pos.z)
		var rig=load("res://assets/watcher_eye.glb").instantiate();add_child(rig);rig.position=pos;rig.rotation.y=crown.rotation.y
		var eye_light:=OmniLight3D.new();add_child(eye_light);eye_light.position=pos+Vector3(0,0,-1.5).rotated(Vector3.UP,crown.rotation.y);eye_light.light_color=Color("ff3a32");eye_light.light_energy=1.6;eye_light.omni_range=7;eye_light.shadow_enabled=false
		var iris:Node3D=rig
		for root in [rig,crown]:
			for m in root.find_children("*","MeshInstance3D",true,false):m.layers=8
		var eye=load("res://scripts/gameplay/watcher_eye.gd").new();eye.watcher=self;eye.index=i;add_child(eye);eye.position=pos
		towers.append({"pos":pos,"base":base,"rig":rig,"iris":iris,"eye":eye,"blind":0.0,"clock":1.0+i*0.3,"pending":0.0,"aim":Vector3.ZERO})
	camera=Camera3D.new();add_child(camera);camera.near=0.1;camera.far=420;camera.fov=78;camera.cull_mask=0xFFFFF & ~10
	feedback=load("res://scripts/gameplay/watcher_feedback.gd").new();feedback.watcher=self;feedback.set_meta("blackout_exempt",true);add_child(feedback)
	night_vision=load("res://scripts/gameplay/night_vision.gd").new();night_vision.watcher=self;add_child(night_vision)
	reveal=load("res://scripts/gameplay/watcher_reveal.gd").new();reveal.watcher=self;add_child(reveal)
	darkness=load("res://scripts/gameplay/blackout.gd").new();darkness.lab=lab;darkness.process_priority=100;add_child(darkness)
func enter() -> void:
	if active or towers.is_empty():return
	saved_position=lab.player.position;saved_rotation=lab.player.rotation;saved_health=lab.player.health
	lab.player.cancel_hands(true);lab.player.clear_mouse_chord();lab.player.velocity=Vector3.ZERO;lab.player.collision_layer=0;lab.player.impostor=false
	active=true;firing=false;scope=false;camera.current=true;select(selected)
func leave() -> void:
	if not active and not lab.player.impostor:return
	active=false;scope=false;firing=false;feedback.hide_scope();lab.player.impostor=false;stationary=0
	lab.player.reset_to(saved_position);lab.player.rotation=saved_rotation;lab.player.health=saved_health;lab.player.collision_layer=2
	lab.player.camera.current=not lab.player.third_person;lab.player.follow_camera.current=lab.player.third_person
func select(index:int) -> void:
	if towers.is_empty():return
	selected=posmod(index,towers.size());camera.position=towers[selected].pos;yaw=atan2(camera.position.x,camera.position.z);pitch=-0.4
	camera.rotation=Vector3(pitch,yaw,0)
func infiltrate() -> void:
	if not active:return
	active=false;firing=false;scope=false;feedback.hide_scope();lab.player.impostor=true;entry_grace=1.5;stationary=0
	lab.player.reset_to(infiltration_spawn(selected));lab.player.health=100;lab.player.collision_layer=2
	lab.player.camera.current=not lab.player.third_person;lab.player.follow_camera.current=lab.player.third_person
func handle_input(event:InputEvent) -> void:
	if event is InputEventMouseMotion:
		yaw-=event.screen_relative.x*lab.player.sensitivity*(0.5 if scope else 1.0);pitch=clampf(pitch-event.screen_relative.y*lab.player.sensitivity*(0.5 if scope else 1.0),-1.5,0.8)
		camera.rotation=Vector3(pitch,yaw,0)
	elif event is InputEventMouseButton:
		if event.button_index==MOUSE_BUTTON_LEFT:
			firing=event.pressed
			if firing:manual_fire()
		if event.button_index==MOUSE_BUTTON_RIGHT:scope=event.pressed
	elif event is InputEventKey and event.pressed and not event.echo:
		var key:int=event.physical_keycode if event.physical_keycode else event.keycode
		if key>=KEY_1 and key<=KEY_7:select(key-KEY_1)
		elif key==KEY_A:select(selected-1)
		elif key==KEY_D:select(selected+1)
		elif key==KEY_Q:grenade()
		elif key==KEY_W:strike()
		elif key==KEY_E:throw_mine()
		elif key==KEY_R:reveal_players()
		elif key==KEY_S:infiltrate()
func aim() -> Dictionary:
	var from:=camera.global_position;var end:=from-camera.global_basis.z*400
	var q:=PhysicsRayQueryParameters3D.create(from,end,19,[lab.player.get_rid()])
	var hit:=get_world_3d().direct_space_state.intersect_ray(q)
	return hit if not hit.is_empty() else {"position":end,"normal":Vector3.UP}
func clear_line(from:Vector3,to:Vector3,target:CollisionObject3D) -> bool:
	var q:=PhysicsRayQueryParameters3D.create(from,to,1,[target.get_rid()])
	return get_world_3d().direct_space_state.intersect_ray(q).is_empty()
func manual_fire() -> bool:
	if not active or lab.paused or cooldowns.gun>0.00001 or towers[selected].blind>0:return false
	fire(camera.global_position,-camera.global_basis.z,55 if scope else 8,0 if scope else MG_SPREAD)
	cooldowns.gun=SNIPER_INTERVAL if scope else MG_INTERVAL
	shot_flash=1.0 if scope else 0.3
	return true
func add_effect(node:Node3D,life:float) -> void:
	node.set_meta("blackout_exempt",true)
	# Cosmetic load must never suppress a real shot or damage event.
	while effects.size()>=64:
		effects[0].node.queue_free();effects.pop_front()
	effects.append({"node":node,"life":life})
func fire(from:Vector3,direction:Vector3,damage:float,spread:=0.0) -> void:
	direction=(direction+Vector3(rng.randf_range(-spread,spread),rng.randf_range(-spread,spread),rng.randf_range(-spread,spread))).normalized()
	var q:=PhysicsRayQueryParameters3D.create(from,from+direction*400,19)
	if active:q.exclude=[lab.player.get_rid()]
	var hit:=get_world_3d().direct_space_state.intersect_ray(q)
	var end:Vector3=hit.position if not hit.is_empty() else from+direction*220
	var confirmed:=false
	if not hit.is_empty() and hit.collider.has_method("take_damage"):
		hit.collider.take_damage(damage,from,"watcher");confirmed=true
	var manual:=active and from.distance_to(camera.global_position)<0.1
	if manual and confirmed:hit_confirm=0.18
	var muzzle:Vector3=from+direction*2.0
	if manual:muzzle+=camera.global_basis.x*0.7-camera.global_basis.y*0.4
	feedback.shot(muzzle,end,damage>=10,hit)
	shots+=1
	var sound_kind:="watcher_sniper" if damage>=10 else "watcher_mg"
	if manual:lab.sound(sound_kind)
	else:lab.audio_service.play_at(sound_kind,from,0.94)
func grenade() -> bool:
	if cooldowns.grenade>0.00001 or towers[selected].blind>0:return false
	cooldowns.grenade=GRENADE_INTERVAL
	lab.sound("fire",0.65)
	var pos:=camera.position-camera.global_basis.z*2
	launch_grenade(pos,-camera.global_basis.z*30+Vector3.UP*5)
	return true
func strike() -> bool:
	if cooldowns.strike>0 or towers[selected].blind>0:return false
	var hit:=aim()
	if not hit.has("collider"):return false
	cooldowns.strike=STRIKE_INTERVAL
	var pos:Vector3=hit.position+hit.normal*0.3
	var excluded:Array[RID]=[lab.player.get_rid()]
	if hit.collider is CharacterBody3D:excluded.append(hit.collider.get_rid())
	var floor_hit:=get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(pos,pos+Vector3.DOWN*80,1,excluded))
	if not floor_hit.is_empty():pos=floor_hit.position+Vector3.UP*0.12
	mark_strike(pos)
	lab.sound("brake",0.65);return true
func cut_power() -> bool:
	blackout=0.0 if blackout>0 else 1.0;cooldowns.blackout=0
	set_dark(blackout>0);lab.sound("brake",0.6 if blackout>0 else 1.1);return true
func throw_mine() -> bool:
	if not active or lab.paused or cooldowns.mine>0.00001 or towers[selected].blind>0:return false
	mines=mines.filter(func(node):return is_instance_valid(node))
	var mine=load("res://scripts/gameplay/landmine.gd").new();mine.watcher=self
	mine.position=camera.position-camera.global_basis.z*2;mine.velocity=-camera.global_basis.z*24+Vector3.UP*4
	add_child(mine);mines.append(mine);cooldowns.mine=MINE_INTERVAL;lab.sound("fire",0.8);return true
func reveal_players() -> bool:
	if not active or lab.paused or cooldowns.reveal>0.00001 or towers[selected].blind>0:return false
	reveal_left=5.0;cooldowns.reveal=5.0;lab.sound("success",0.75);return true
func set_dark(dark:bool) -> void:
	darkness.set_active(dark)
	night_vision.update_view()
func targets() -> Array:
	var result:Array=[]
	if not active and not lab.player.impostor and lab.player.respawn_left<=0 and not lab.player.buffs.has("invisible"):result.append(lab.player)
	if lab.session.objectives:
		for p in lab.session.objectives.partners:
			if p.respawn<=0:result.append(p)
	return result
func begin_orbital(pos:Vector3) -> Node3D:
	fields=fields.filter(func(node):return is_instance_valid(node))
	if fields.size()>=8:fields.pop_front().queue_free()
	var field=load("res://scripts/gameplay/orbital_strike.gd").new();field.watcher=self;field.position=pos;add_child(field);fields.append(field)
	return field

func explode(pos:Vector3,radius:float,damage:float) -> void:
	lab.audio_service.play_at("watcher_blast",pos)
	feedback.explosion(pos,radius)
	for target in targets()+lab.arena.dummies:
		var center:Vector3=target.position+Vector3.UP
		var distance:=center.distance_to(pos)
		if distance<radius and clear_line(pos,center,target):target.take_damage(damage*(1-distance/radius*0.5),pos,"blast")
func _physics_process(dt:float) -> void:
	if lab.paused:return
	for key in cooldowns:cooldowns[key]=maxf(0,cooldowns[key]-dt)
	reveal_left=maxf(0,reveal_left-dt)
	hit_confirm=maxf(0,hit_confirm-dt);shot_flash=maxf(0,shot_flash-dt*5)
	entry_grace=maxf(0,entry_grace-dt)
	for i in range(effects.size()-1,-1,-1):
		effects[i].life-=dt
		if effects[i].life<=0:effects[i].node.queue_free();effects.remove_at(i)
	for i in range(strikes.size()-1,-1,-1):
		var item:Dictionary=strikes[i];item.left-=dt
		item.node.get_meta("warning_material").set_shader_parameter("age",2.8-item.left)
		if item.left<=0:begin_orbital(item.pos);item.node.queue_free();strikes.remove_at(i)
	for i in range(bombs.size()-1,-1,-1):
		var item:Dictionary=bombs[i];item.age+=dt
		if item.get("touched",false):item.fuse-=dt
		if not item.landed:
			item.velocity.y-=16*dt
			var next:Vector3=item.pos+item.velocity*dt
			var hit:=get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(item.pos,next,1))
			if not hit.is_empty():
				next=hit.position+hit.normal*0.24
				item.velocity=item.velocity.slide(hit.normal)*0.62+hit.normal*minf(3.2,absf(item.velocity.dot(hit.normal))*0.28)
				if hit.normal.y>0.45:
					if not item.get("touched",false):item.touched=true;item.fuse=1.0
					if item.velocity.length()<1.5:item.landed=true;item.velocity=Vector3.ZERO
			if int(item.age*30)!=int((item.age-dt)*30) and item.pos.distance_to(next)>0.01:
				var trail=P.beam(self,item.pos,next,Color("ff483a"),0.07);trail.material_override.emission_energy_multiplier=6;add_effect(trail,0.18)
			item.pos=next;item.node.position=next;item.node.rotate_y(dt*8);item.node.rotate_x(dt*4)
		if item.fuse<=0 or item.age>20:explode(item.pos,7,40);item.node.queue_free();bombs.remove_at(i)
	if lab.session.training.active:return
	if active:
		camera.fov=lerpf(camera.fov,28 if scope else 78,1-exp(-dt*15))
		if firing:manual_fire()
	if lab.player.impostor:
		stationary=stationary+dt if lab.player.velocity.length()<0.2 and lab.player.is_on_floor() else 0.0
		if stationary>=10:explode(lab.player.chest(),9,100);active=true;lab.player.impostor=false;lab.player.collision_layer=0;camera.current=true;select(selected);stationary=0
		if entry_grace<=0:
			for i in towers.size():
				if lab.player.position.distance_to(towers[i].base)<3:
					active=true;lab.player.impostor=false;lab.player.cancel_hands(true);lab.player.collision_layer=0;camera.current=true;select(i);break
	for i in towers.size():
		var tower:Dictionary=towers[i];tower.blind=maxf(0,tower.blind-dt)
		tower.iris.visible=tower.blind<=0
		if active and i==selected:tower.rig.rotation=camera.rotation
	tower_ai.update(dt)

func infiltration_spawn(index:int) -> Vector3:
	var base:Vector3=towers[index].base
	var shape:=CapsuleShape3D.new();shape.radius=0.4;shape.height=1.8
	var space:=get_world_3d().direct_space_state
	for radius in [4.0,6.0,8.0]:
		for i in 8:
			var pos:=base+Vector3(cos(i*TAU/8)*radius,0,sin(i*TAU/8)*radius)
			var floor_hit:=space.intersect_ray(PhysicsRayQueryParameters3D.create(pos+Vector3.UP*7,pos-Vector3.UP*8,1))
			if floor_hit.is_empty() or floor_hit.normal.y<0.9:continue
			pos=floor_hit.position+Vector3.UP*0.05
			var q:=PhysicsShapeQueryParameters3D.new();q.shape=shape;q.transform.origin=pos+Vector3.UP*0.95;q.collision_mask=1
			if space.intersect_shape(q,1).is_empty():return pos
	return saved_position

func launch_grenade(pos:Vector3,initial_velocity:Vector3) -> void:
	# A safety bound for unattended stress tests; normal throws expire much sooner.
	if bombs.size()>=64:bombs.pop_front().node.queue_free()
	bombs.append({"node":feedback.grenade_visual(pos),"pos":pos,"velocity":initial_velocity,"fuse":1.0,"landed":false,"age":0.0})
func mark_strike(pos:Vector3) -> void:
	var warning=feedback.strike_visual(pos,Vector3.UP)
	strikes.append({"node":warning,"pos":pos,"left":2.8})
