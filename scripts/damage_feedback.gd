extends RefCounted
## Brief attack bearings, not enemy tracking. Store the impact-time source position.
const LIFETIME:=0.85
var hits:Array[Dictionary]=[]
func record(amount:float,source:Vector3,kind:String) -> void:
	if amount<=0 or kind not in ["watcher","blast","orbital"]:return
	for hit in hits:
		if hit.source.distance_to(source)<3:hit.left=LIFETIME;return
	if hits.size()>=4:hits.pop_front()
	hits.append({"source":source,"left":LIFETIME})
func update(dt:float) -> void:
	for i in range(hits.size()-1,-1,-1):
		hits[i].left-=dt
		if hits[i].left<=0:hits.remove_at(i)
func bearing(camera:Camera3D,source:Vector3) -> Vector2:
	# Yaw-relative compass works even when looking straight up at a ceiling.
	var right:=camera.global_basis.x;right.y=0;right=right.normalized()
	var forward:=Vector3.UP.cross(right)
	var offset:=source-camera.global_position
	var direction:=Vector2(offset.dot(right),-offset.dot(forward))
	return direction.normalized() if direction.length_squared()>0.001 else Vector2.UP
func draw(hud:Control,camera:Camera3D) -> void:
	var radius:=minf(hud.size.x,hud.size.y)*0.19
	for hit in hits:
		var direction:=bearing(camera,hit.source);var angle:=direction.angle()
		var color:=Color(1,0.44,0.24,minf(1,hit.left/0.25)*0.9)
		hud.draw_arc(hud.size/2,radius,angle-0.22,angle+0.22,18,color,4,true)
		var tip:Vector2=hud.size/2+direction*(radius+7)
		var tangent:=Vector2(-direction.y,direction.x)
		hud.draw_colored_polygon(PackedVector2Array([tip,tip-direction*7+tangent*4,tip-direction*7-tangent*4]),color)
