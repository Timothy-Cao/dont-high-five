extends Node3D
var lab:Node3D
var layout:Node3D
var training:Node3D
var watcher:Node3D
var objectives:Node3D
var hazards:Node3D
func build() -> void:
	layout=load("res://scenes/playtest_layout.tscn").instantiate();add_child(layout)
	training=load("res://scripts/gameplay/training.gd").new();training.lab=lab;add_child(training)
	watcher=load("res://scripts/gameplay/watcher.gd").new();watcher.lab=lab;add_child(watcher);watcher.build()
	objectives=load("res://scripts/gameplay/objectives.gd").new();objectives.lab=lab;add_child(objectives);objectives.build()
	hazards=load("res://scripts/gameplay/hazards.gd").new();hazards.lab=lab;add_child(hazards);hazards.build()
func checkpoint() -> Vector3:
	if lab.builder and lab.builder.active:return lab.builder.ORIGIN+Vector3(0,.05,24)
	return training.origin()+Vector3(-14,0.05,0) if training.active else lab.spawns[lab.station]
func handle_input(event:InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_F6:
		switch_role()
		return true
	if watcher.active:watcher.handle_input(event);return true
	if event.is_action_pressed("pop_interact"):
		objectives.interact();return true
	return false

func switch_role() -> void:
	if lab.builder and lab.builder.active:lab.builder.leave()
	if lab.player.respawn_left>0:return
	if training.active:training.leave()
	if watcher.active or lab.player.impostor:watcher.leave()
	else:watcher.enter()
func reset_round() -> void:
	objectives.reset_tasks();lab.player.health=100;lab.player.respawn_left=0;lab.player.collision_layer=0 if watcher.active else 2;watcher.saved_health=100
	for partner in objectives.partners:
		partner.reset_partner()

func positions(kind:String) -> Array[Vector3]:
	var result:Array[Vector3]=[]
	for marker in layout.get_children():
		if marker.get_meta("kind","")==kind:result.append(marker.position)
	return result

func visit_task(kind:String) -> void:
	if lab.builder and lab.builder.active:lab.builder.leave()
	if training.active:training.leave()
	watcher.leave();lab.player.respawn_left=0;lab.player.health=100;lab.player.collision_layer=2
	var pos:Vector3={"High five":Vector3(-16.5,0.05,29),"Cargo":Vector3(-110,0.05,-22),"Rings":Vector3(0,0.05,16),"Maintenance":Vector3(-12,23.05,-10),"Dummies":Vector3(-4,0.05,22),"Hazards":hazards.gate_pos+Vector3(0,0.05,4)}[kind]
	lab.player.reset_to(pos);lab.player.rotation=Vector3.ZERO;lab.player.camera.rotation=Vector3.ZERO
	if kind=="High five":lab.player.camera.look_at(objectives.social_pos+Vector3.UP)
	if kind=="Cargo":lab.player.rotation.y=-PI/2
	lab.started=true;lab.set_paused(false)
