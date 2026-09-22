extends Node
## Optional parallel-grip zip: real surface required, modest pull, same hand range.
var player:CharacterBody3D
var active:=false
var target:=Vector3.ZERO
var left:=0.0
func begin() -> bool:
	if active or player.combat.active or player.combat.charging or player.stone or player.has_cargo() or player.arms_suppressed() or player.hand_recovery>0 or player.held("anchor") or player.held("brake"): return false
	var hits:Array[Dictionary]=[]
	for i in 2:
		var from:Vector3=player.hand_start(i)
		var hit:Dictionary=player.ray(from,from-player.camera.global_basis.z*player.hand_range())
		if hit.is_empty() or not hit.collider.get_meta("grippy",false): return false
		hits.append(hit)
	player.cancel_hands();target=(hits[0].position+hits[1].position)/2
	for i in 2:
		player.hands[i].state=5;player.hands[i].from=player.hand_start(i);player.hands[i].point=hits[i].position
	active=true;left=0.5;player.lab.sound("fire");return true
func cancel() -> void:
	if not active: return
	active=false
	for i in 2: player.recovery_origins[i]=player.hands[i].point;player.hands[i].state=0
	player.hand_recovery=player.HAND_RECOVERY_DURATION
func tick(dt:float) -> void:
	if not active: return
	if player.held("anchor") or player.held("brake"): cancel();return
	left-=dt
	var delta:Vector3=target-player.chest()
	if left<=0 or delta.length()<2: cancel();return
	var direction:=delta.normalized()
	# Add only the missing forward component; preserve transverse momentum.
	var gain:=minf(36*dt,maxf(0,18-player.velocity.dot(direction)))
	player.velocity+=direction*gain;player.momentum_air=true;player.flying=true;player.flight_time=0
