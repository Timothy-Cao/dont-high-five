extends Node3D
## Camera-isolated animated silhouette. No lights or target materials are modified.
const LAYER:=1<<18
var watcher:Node3D
var copies:Dictionary={}
var material:ShaderMaterial
func _ready() -> void:
	set_meta("blackout_exempt",true)
	material=ShaderMaterial.new();material.shader=load("res://shaders/watcher_reveal.gdshader")
	watcher.lab.player.camera.cull_mask &= ~LAYER
	watcher.lab.player.follow_camera.cull_mask &= ~LAYER
func _process(_dt:float) -> void:
	visible=watcher.active and watcher.camera.current and watcher.reveal_left>0 and watcher.towers[watcher.selected].blind<=0
	if not visible:return
	var live:Dictionary={}
	for target in watcher.targets():
		var sources:Array=[target.model] if target!=watcher.lab.player else [target.avatar.body]
		if target!=watcher.lab.player:sources.append_array(target.gloves)
		for source in sources:
			var id:int=source.get_instance_id();live[id]=true
			if not copies.has(id):
				# Instantiate the clean asset, not runtime material overrides (which
				# can contain sparse/null surface slots after visor and blackout edits).
				var copy:Node3D=load(source.scene_file_path).instantiate();add_child(copy)
				for animation in copy.find_children("*","AnimationPlayer",true,false):animation.stop();animation.active=false
				for mesh in copy.find_children("*","MeshInstance3D",true,false):
					mesh.material_override=material;mesh.layers=LAYER;mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				var src_bones=source.find_children("*","Skeleton3D",true,false)
				var dst_bones=copy.find_children("*","Skeleton3D",true,false)
				copies[id]={"node":copy,"src":src_bones[0] if not src_bones.is_empty() else null,"dst":dst_bones[0] if not dst_bones.is_empty() else null}
			var item:Dictionary=copies[id];item.node.global_transform=source.global_transform;item.node.show()
			if item.src:
				for bone in item.src.get_bone_count():item.dst.set_bone_pose(bone,item.src.get_bone_pose(bone))
	for id in copies.keys():
		if not live.has(id):copies[id].node.queue_free();copies.erase(id)
