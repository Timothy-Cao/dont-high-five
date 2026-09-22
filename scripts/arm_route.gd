extends RefCounted
## Bounded contact polyline. Static arena boxes use a visibility route around their
## expanded collision bounds, in the plane of travel. This is not a rope simulator.
const SKIN:=0.10
const MAX_BENDS:=12
var bends:Array[Dictionary]=[] # Player -> original glove anchor.
var goal:=Vector3.ZERO
var initialized:=false
var retry_left:=0.0

func clear() -> void:
	bends.clear();initialized=false;retry_left=0

func points() -> Array[Vector3]:
	var result:Array[Vector3]=[]
	for bend in bends:
		if is_instance_valid(bend.body):result.append(bend.body.to_global(bend.local))
	return result

func pivot(anchor:Vector3) -> Vector3:
	var path:=points()
	return path[0] if not path.is_empty() else anchor

func tail(anchor:Vector3) -> float:
	var path:=points();var length:=0.0
	path.append(anchor)
	for i in range(1,path.size()):length+=path[i-1].distance_to(path[i])
	return length

func length_from(start:Vector3,anchor:Vector3) -> float:
	return start.distance_to(pivot(anchor))+tail(anchor)

func obstructed(player:CharacterBody3D,a:Vector3,b:Vector3) -> Dictionary:
	if a.distance_to(b)<0.03:return {}
	var hit:Dictionary=player.ray(a,b)
	if not hit.is_empty() and hit.position.distance_to(b)>0.025:return hit
	return {}

func update(player:CharacterBody3D,hand:Dictionary,start:Vector3,motion:Vector3,dt:float) -> void:
	var anchor:Vector3=hand.point+hand.normal*SKIN
	if not initialized or goal.distance_to(hand.point)>0.01:
		clear();initialized=true;goal=hand.point
	bends=bends.filter(func(bend):return is_instance_valid(bend.body))
	if obstructed(player,start,anchor).is_empty():
		bends.clear();return
	# Unwrap only when a direct shortcut is actually clear. Never keep a stale angle gate.
	while not bends.is_empty():
		var path:=points()
		var next:Vector3=path[1] if path.size()>1 else anchor
		if not obstructed(player,start,next).is_empty():break
		bends.pop_front()
	retry_left=maxf(0,retry_left-dt)
	if retry_left>0:return
	# Insert contacts into any newly obstructed segment; bounded work per physics tick.
	for attempt in 2:
		var path:=points();path.append(anchor)
		var from:=start;var inserted:=false
		for i in path.size():
			var hit:=obstructed(player,from,path[i])
			if not hit.is_empty():
				var detour:=route_around(player,from,path[i],motion,hit)
				if detour.is_empty() or bends.size()+detour.size()>MAX_BENDS:
					retry_left=0.1;return # Unusual/concave cover never cancels player velocity.
				for j in detour.size():bends.insert(i+j,{"body":hit.collider,"local":hit.collider.to_local(detour[j])})
				inserted=true;break
			from=path[i]
		if not inserted:break

func blocked_by(player:CharacterBody3D,a:Vector3,b:Vector3,body:CollisionObject3D) -> bool:
	# Solve one collider at a time; other walls receive their own contacts next.
	var excluded:Array[RID]=[player.get_rid()]
	for attempt in 8:
		var query:=PhysicsRayQueryParameters3D.create(a,b,1,excluded)
		var hit:Dictionary=player.get_world_3d().direct_space_state.intersect_ray(query)
		if hit.is_empty() or hit.position.distance_to(b)<=0.025:return false
		if hit.collider==body:return true
		excluded.append(hit.rid)
	return true

func route_around(player:CharacterBody3D,a:Vector3,b:Vector3,motion:Vector3,hit:Dictionary) -> Array[Vector3]:
	var empty:Array[Vector3]=[]
	var body:CollisionObject3D=hit.collider
	var owner=body.shape_owner_get_owner(body.shape_find_owner(hit.shape))
	if not owner is CollisionShape3D:return empty
	var half:=Vector3.ZERO
	if owner.shape is BoxShape3D:half=owner.shape.size*0.5
	elif owner.shape is CylinderShape3D:half=Vector3(owner.shape.radius,owner.shape.height*0.5,owner.shape.radius)
	else:return empty
	half+=Vector3.ONE*SKIN
	var corners:Array[Vector3]=[]
	for x in [-1,1]:
		for y in [-1,1]:
			for z in [-1,1]:corners.append(owner.to_global(half*Vector3(x,y,z)))
	var direction:Vector3=(b-a).normalized()
	var normal:=direction.cross(motion).normalized()
	if normal.length_squared()<0.5:normal=direction.cross(Vector3.UP).normalized()
	if normal.length_squared()<0.5:normal=Vector3.FORWARD
	var candidates:Array[Vector3]=[a,b]
	# Intersect the twelve OBB edges with the swing plane: contacts stay at the
	# player's travel height on columns instead of routing over their roof.
	for i in 8:
		for bit in [1,2,4]:
			var j:int=i^bit
			if j<=i:continue
			var da:=normal.dot(corners[i]-a);var db:=normal.dot(corners[j]-a)
			if da*db<=0 and absf(da-db)>0.0001:
				var contact:=corners[i].lerp(corners[j],da/(da-db))
				var unique:=true
				for existing in candidates:
					if contact.distance_to(existing)<0.02:unique=false;break
				if unique:candidates.append(contact)
	# Fallback corners also handle a plane that only grazes an edge or a low slab.
	candidates.append_array(corners)
	var size:=candidates.size();var costs:Array[float]=[];var previous:Array[int]=[];var visited:Array[bool]=[]
	for i in size:costs.append(INF);previous.append(-1);visited.append(false)
	costs[0]=0
	for step in size:
		var nearest:=-1
		for i in size:
			if not visited[i] and (nearest<0 or costs[i]<costs[nearest]):nearest=i
		if nearest<0 or is_inf(costs[nearest]):break
		if nearest==1:break
		visited[nearest]=true
		for i in range(1,size):
			if visited[i]:continue
			var cost:float=costs[nearest]+candidates[nearest].distance_to(candidates[i])
			if cost>=costs[i]:continue
			if not blocked_by(player,candidates[nearest],candidates[i],body):costs[i]=cost;previous[i]=nearest
	if previous[1]<0:return empty
	var cursor:int=previous[1]
	while cursor>0:
		empty.push_front(candidates[cursor]);cursor=previous[cursor]
	return empty
