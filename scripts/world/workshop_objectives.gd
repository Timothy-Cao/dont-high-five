extends Node3D
## Reuse the real cargo and portal traversal; workshop data defines only placement.
const P=preload("res://scripts/gameplay/props.gd")
var lab:Node3D
var builder:Node3D
var partners:Array=[]
var cargos:Array=[]
var rings:Array=[]
var sockets:Array=[]
var complete_flash:=0.0
var previous:=Vector3.ZERO
var travel:Node3D
func build() -> void:
	travel=preload("res://scripts/travel.gd").new();travel.lab=lab;add_child(travel)
	var gates:Dictionary={}
	for entry in builder.entries:
		var id:String=builder.specs[entry.part].id;var at:Vector3=builder.ORIGIN+builder.Kit.vector(entry.pos);var turn:float=entry.yaw*PI/2
		match id:
			"cargo":
				var cargo=preload("res://scripts/gameplay/cargo.gd").new();cargo.lab=lab;cargo.position=at+Vector3.UP*.6;add_child(cargo);cargos.append(cargo)
			"socket":sockets.append({"pos":at,"done":false,"node":P.ring(self,at+Vector3.UP*.05,1.8,Color("ffcc80"))})
			"ring":
				var node=P.ring(self,at+Vector3.UP*2.5,2.4,Color("83ded1"),true);node.rotate_y(turn)
				rings.append({"xf":Transform3D(Basis(Vector3.UP,turn),at+Vector3.UP*2.5),"node":node,"done":false})
			"light":
				var lamp:=OmniLight3D.new();add_child(lamp);lamp.position=at+Vector3.UP*.5;lamp.omni_range=24;lamp.light_color=Color("a6d6dc");lamp.light_energy=3
				P.orb(self,lamp.position,.25,Color("c2ddd9"),1)
			"portal_a","portal_b":
				gates[id]={"xf":Transform3D(Basis(Vector3.UP,turn),at+Vector3.UP*2.2),"base":at,"pair":0,"color":Color("83ded1")}
				var spec:Dictionary=builder.specs[entry.part];var model=preload("res://scripts/world/workshop_props.gd").make(spec,false);add_child(model);model.position=at;model.rotation.y=turn
	if gates.has("portal_a") and gates.has("portal_b"):travel.portals.assign([gates.portal_a,gates.portal_b])
	previous=lab.player.chest()
func total() -> int:return rings.size()+sockets.size()
func progress() -> int:
	var count:=0
	for item in rings+sockets:count+=int(item.done)
	return count
func hint() -> String:return "Deliver the core with one hand free" if lab.player.has_cargo() else ""
func interact() -> void:pass
func highfive(_at:Vector3) -> void:pass
func reset_tasks() -> void:
	for item in rings+sockets:item.done=false;item.node.material_override=P.material(Color("83ded1"),1.4)
	for cargo in cargos:cargo.reset_cargo()
func _physics_process(dt:float) -> void:
	if lab.paused:return
	complete_flash=maxf(0,complete_flash-dt)
	var now:Vector3=lab.player.chest()
	if not lab.session.watcher.active and previous.distance_to(now)<8:
		for ring in rings:
			if ring.done:continue
			var inv:Transform3D=ring.xf.affine_inverse();var a:Vector3=inv*previous;var b:Vector3=inv*now
			if absf(a.z-b.z)<.001:continue
			var t:=a.z/(a.z-b.z)
			if t>=0 and t<=1 and a.lerp(b,t).length()<2.2:finish(ring)
	previous=now
	for socket in sockets:
		if socket.done:continue
		for cargo in cargos:
			if not cargo.delivered and cargo.position.distance_to(socket.pos+Vector3.UP*.5)<1.8:
				cargo.release();cargo.delivered=true;cargo.position=socket.pos+Vector3.UP*.5;finish(socket);break
func finish(item:Dictionary) -> void:
	item.done=true;item.node.material_override=P.material(Color("ffe5ad"),1.4);complete_flash=1;lab.sound("success")
