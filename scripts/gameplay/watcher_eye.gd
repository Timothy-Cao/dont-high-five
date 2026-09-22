extends StaticBody3D
var watcher:Node3D
var index:=0
func _ready() -> void:
	collision_layer=32;set_meta("grippy",true)
	var col:=CollisionShape3D.new();var shape:=SphereShape3D.new();shape.radius=1.5;col.shape=shape;add_child(col)
func receive_punch(_impulse:Vector3,_strength:float) -> bool:
	watcher.towers[index].blind=4;watcher.towers[index].pending=0.0;watcher.lab.sound("brake");return true
