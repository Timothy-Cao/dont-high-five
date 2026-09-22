extends "res://scripts/gameplay/session.gd"
var builder:Node3D
func build() -> void:
	layout=Node3D.new();add_child(layout)
	var index:=0
	for entry in builder.entries:
		if builder.specs[entry.part].id!="tower":continue
		index+=1;var marker:=Marker3D.new();marker.name="Eye%02d"%index;layout.add_child(marker)
		marker.position=builder.ORIGIN+builder.Kit.vector(entry.pos)+Vector3.UP*8
		marker.set_meta("kind","tower");marker.set_meta("base_y",marker.position.y-8)
	training=builder.saved_session.training;hazards=builder.saved_session.hazards
	watcher=preload("res://scripts/gameplay/watcher.gd").new();watcher.lab=lab;add_child(watcher);watcher.build()
	objectives=preload("res://scripts/world/workshop_objectives.gd").new();objectives.lab=lab;objectives.builder=builder;add_child(objectives);objectives.build()
	watcher.set_pressure(builder.pressure)
func checkpoint() -> Vector3:return builder.ORIGIN+builder.test_start
func switch_role() -> void:
	if watcher.active or lab.player.impostor:watcher.leave()
	elif not watcher.towers.is_empty():watcher.enter()
	else:lab.notify("Place a Watcher tower to test this role")
