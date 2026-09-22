extends RefCounted
## One active, inextensible rope. Integrate along its sphere instead of repeatedly
## projecting a straight step, which quietly destroys tangential speed each frame.
var active_hand := -1
var retiring_hand := -1
var overlap := 0.0
var tangent_velocity := Vector3.ZERO
var constrained := false
const TRAVERSE_LENGTH := 5.0
const WINCH_SPEED := 14.0
const WINCH_ACCEL := 50.0
var winch_speed := 0.0
var winch_contribution := Vector3.ZERO
var pending_contribution := Vector3.ZERO

func clear() -> void:
	active_hand=-1;retiring_hand=-1;overlap=0
	winch_speed=0;winch_contribution=Vector3.ZERO;pending_contribution=Vector3.ZERO

func attach(player: CharacterBody3D,index: int) -> void:
	var h: Dictionary=player.hands[index]
	h.rest=maxf(0.5,player.chest().distance_to(h.point))
	h.spool_target=minf(TRAVERSE_LENGTH,h.rest)
	var other:=1-index
	retiring_hand=other if player.hands[other].state==2 else -1
	overlap=0.3 if retiring_hand>=0 else 0.0
	active_hand=index

func tick(player: CharacterBody3D,dt: float) -> void:
	# Remove only last frame's motor contribution before ordinary forces run.
	# This lets the motor ease to rest without deleting earned swing momentum.
	player.velocity-=winch_contribution
	winch_contribution=Vector3.ZERO
	if retiring_hand>=0:
		overlap=maxf(0,overlap-dt)
		if overlap<=0:
			player.retract_hand(retiring_hand);retiring_hand=-1
	if active_hand<0 or player.hands[active_hand].state!=2:
		active_hand=-1
		for i in 2:
			if player.hands[i].state==2: active_hand=i

# Pure integration is also used by deterministic 60/120 Hz regression tests.
func integrate(offset: Vector3,velocity: Vector3,length: float,dt: float) -> Dictionary:
	var next:=offset+velocity*dt
	if next.length()<=length:
		return {"offset":next,"velocity":velocity,"taut":false}
	var remaining:=dt
	var contact:=offset
	if offset.length()<length-0.001:
		var a:=velocity.length_squared()
		var b:=2*offset.dot(velocity)
		var c:=offset.length_squared()-length*length
		var time:=clampf((-b+sqrt(maxf(0,b*b-4*a*c)))/maxf(2*a,0.00001),0,dt)
		contact=offset+velocity*time;remaining-=time
	var normal:=contact.normalized()
	if normal.length_squared()<0.5: normal=Vector3.DOWN
	# A rope may remove outward radial speed; it never invents tangential speed.
	var tangent:=velocity-normal*maxf(0,velocity.dot(normal))
	var radial:=minf(0,tangent.dot(normal))
	tangent-=normal*radial
	var speed:=tangent.length()
	var axis:=normal.cross(tangent).normalized()
	var rotation:=Basis(axis,speed*remaining/maxf(length,0.5)) if speed>0.001 else Basis.IDENTITY
	return {"offset":rotation*normal*length,"velocity":rotation*tangent+rotation*normal*radial,"taut":true}

func constrain(player: CharacterBody3D,dt: float) -> void:
	constrained=false
	if active_hand<0: return
	var h:Dictionary=player.hands[active_hand]
	var old_length:float=h.rest
	var remaining:float=maxf(0,old_length-h.spool_target)
	var acceleration:float=WINCH_ACCEL*player.pull_multiplier()
	var desired_speed:float=minf(WINCH_SPEED*player.pull_multiplier(),sqrt(2*acceleration*remaining))
	winch_speed=move_toward(winch_speed,desired_speed,acceleration*dt)
	var requested:float=move_toward(old_length,h.spool_target,winch_speed*dt)
	pending_contribution=Vector3.ZERO
	var result:=integrate(player.chest()-h.point,player.velocity,requested,dt)
	var destination:Vector3=h.point+result.offset-Vector3.UP*1.15
	# An arm cannot silently wrap through a wall. Hold its crossing component.
	var blocked:Dictionary=player.ray(destination+Vector3.UP*1.15,h.point+h.normal*0.04)
	if not blocked.is_empty() and blocked.position.distance_to(h.point)>0.35:
		var current:Dictionary=player.ray(player.chest(),h.point+h.normal*0.04)
		if current.is_empty() or current.position.distance_to(h.point)<=0.35:
			destination.x=player.position.x;destination.z=player.position.z
			result.velocity=Vector3.ZERO;result.taut=true
	h.rest=requested
	constrained=result.taut
	tangent_velocity=result.velocity
	if requested<old_length and constrained:
		# The winch does work: retain its inward velocity when the player lets go.
		# Set a minimum inward rate, rather than adding it again every frame.
		var normal:Vector3=result.offset.normalized()
		var winch_rate:float=(old_length-requested)/dt
		pending_contribution=-normal*maxf(0,winch_rate+tangent_velocity.dot(normal))
		tangent_velocity+=pending_contribution
	if constrained:
		# Movement still goes through CharacterBody3D collision; never teleport.
		player.velocity=(destination-player.position)/dt
		player.tether_limited=true

func after_move(player: CharacterBody3D) -> void:
	if active_hand<0 or not constrained: return
	if player.get_slide_collision_count()==0:
		player.velocity=tangent_velocity
		winch_contribution=pending_contribution
	else:
		# A blocked reel does not wind invisible rope through solid cover.
		var h:Dictionary=player.hands[active_hand]
		h.rest=maxf(h.rest,player.chest().distance_to(h.point))
