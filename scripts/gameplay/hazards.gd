extends Node3D
## Small, opt-out hazard gallery. No live arm/leg-disable fields.
const P=preload("res://scripts/gameplay/props.gd")
var lab:Node3D
var enabled:=true
var elapsed:=0.0
var hurt_clock:=0.0
var gate_pos:=Vector3(0,0,82)
var sweep_pos:=Vector3(-13,0,88)
var river_pos:=Vector3(17,0,88)
var press_pos:=Vector3(30,0,88)
var sweep:Node3D
var press:Node3D
var warning:MeshInstance3D
var gate:Node3D
func build() -> void:
	gate=P.box(self,gate_pos+Vector3.UP*0.65,Vector3(6,1.3,0.12),Color("65a5eb"),false)
	gate.get_child(0).material_override=P.material(Color("65a5eb"),1.1)
	for x in [-3.4,3.4]:P.box(self,gate_pos+Vector3(x,2,0),Vector3(0.4,4,0.6),Color("293e4e"))
	sweep=P.beam(self,sweep_pos+Vector3(-5,0.4,0),sweep_pos+Vector3(5,0.4,0),Color("f67485"),0.10)
	for z in [-5,5]:P.beam(self,sweep_pos+Vector3(-5,0.05,z),sweep_pos+Vector3(5,0.05,z),Color("975567"))
	# Recessed-looking channel with a safe exit on every edge; damage is deliberately low.
	for i in 5:P.beam(self,river_pos+Vector3(-3+i*1.5,0.12,-4),river_pos+Vector3(-3+i*1.5,0.12,4),Color("d6619e"),0.09)
	for x in [-4,4]:P.box(self,press_pos+Vector3(x,4,0),Vector3(0.7,8,7),Color("293e4e"))
	P.box(self,press_pos+Vector3.UP*8,Vector3(9,0.8,7),Color("293e4e"))
	press=P.box(self,press_pos+Vector3.UP*6,Vector3(7,0.7,6),Color("71525d"),false)
	warning=P.ring(self,press_pos+Vector3.UP*0.05,3,Color("ff997e"))
func _physics_process(dt:float) -> void:
	if lab.paused or lab.session.training.active:return
	elapsed+=dt;hurt_clock=maxf(0,hurt_clock-dt)
	var wave:=sin(elapsed*0.7)*4.5
	sweep.position=sweep_pos+Vector3(0,0.4,wave)
	var phase:=fmod(elapsed,6.0)
	var height:=6.0
	if phase>3.0 and phase<3.3:height=lerpf(6,0.45,(phase-3)/0.3)
	elif phase>=3.3 and phase<4.0:height=0.45
	elif phase>=4.0:height=lerpf(0.45,6,(phase-4)/2)
	press.position.y=press_pos.y+height
	warning.visible=enabled and phase>1.5 and phase<4
	warning.scale=Vector3.ONE*(0.85+0.15*sin(elapsed*15))
	sweep.visible=enabled;gate.visible=enabled
	if not enabled or lab.session.watcher.active or lab.player.respawn_left>0:return
	var p=lab.player;var here:Vector3=p.position
	if absf(here.x-gate_pos.x)<3 and absf(here.z-gate_pos.z)<0.5 and here.y<1.4:
		p.velocity.x*=exp(-dt*12);p.velocity.z*=exp(-dt*12)
	if hurt_clock>0:return
	var sweep_hit:=absf(here.x-sweep_pos.x)<5 and absf(here.z-sweep_pos.z-wave)<0.6 and here.y<0.75
	var river_hit:=absf(here.x-river_pos.x)<3.2 and absf(here.z-river_pos.z)<4 and here.y<0.45
	var press_hit:=absf(here.x-press_pos.x)<3.5 and absf(here.z-press_pos.z)<3 and here.y<height and here.y+1.7>height-0.35 and phase>3 and phase<4
	if sweep_hit or river_hit or press_hit:
		p.take_damage(18 if press_hit else (8 if river_hit else 4),here,"hazard");hurt_clock=0.65
