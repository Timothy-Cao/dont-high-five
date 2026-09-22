extends Node
func run(lab:Node3D) -> void:
	lab.set_paused(true)
	for i in 5:await get_tree().physics_frame
	var samples:Array[Vector3]=lab.arena.powerups.candidates
	var candidates:Array[Dictionary]=[]
	var q:=PhysicsShapeQueryParameters3D.new();var shape:=SphereShape3D.new();shape.radius=1.8;q.shape=shape;q.collision_mask=1
	var space:=lab.get_world_3d().direct_space_state
	for y in [10,15,28,36,40]:
		for x in [-132,-100,-68,-36,0,36,68,100,132]:
			for z in [-104,-72,-40,0,40,72,104]:
				var pos:=Vector3(x,y,z);q.transform.origin=pos
				if not space.intersect_shape(q,1).is_empty():continue
				var visible:Dictionary={}
				for i in samples.size():
					if pos.distance_to(samples[i])<130 and lab.player.ray(pos,samples[i]).is_empty():visible[i]=true
				candidates.append({"pos":pos,"visible":visible})
	var selected:Array=[];var union:Dictionary={}
	for i in 7:
		var best:Dictionary={};var score:=-1
		for c in candidates:
			var gain:=0
			for index in c.visible:
				if not union.has(index):gain+=1
			if gain>score:score=gain;best=c
		if best.is_empty():break
		union.merge(best.visible);selected.append({"position":str(best.pos),"individual":best.visible.size(),"gain":score});candidates.erase(best)
	var result:={"samples":samples.size(),"greedy_visible":union.size(),"fraction":float(union.size())/maxi(1,samples.size()),"eyes":selected}
	print("COVERAGE PROPOSAL ",JSON.stringify(result))
	var f:=FileAccess.open("res://.local/reports/coverage-proposal.json",FileAccess.WRITE);f.store_string(JSON.stringify(result,"  "));f.close()
	get_tree().quit()
