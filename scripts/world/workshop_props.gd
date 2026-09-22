extends RefCounted
const P=preload("res://scripts/gameplay/props.gd")
static func catalogue() -> Array:
	var result:Array=[]
	for row in [["spawn","Player start",[2,2,2]],["tower","Watcher tower",[3,11,3]],["cargo","Carry core",[1.2,1.2,1.2]],["socket","Cargo socket",[4,1,4]],["ring","Traversal ring",[5,5,.4]],["light","Soft light",[1,1,1]],["portal_a","Portal A",[5,5,.6]],["portal_b","Portal B",[5,5,.6]]]:
		result.append({"id":row[0],"name":row[1],"bounds":row[2],"gameplay":true})
	return result
static func make(spec:Dictionary,collidable:bool) -> Node3D:
	var root:Node3D=StaticBody3D.new() if collidable else Node3D.new()
	if collidable:
		root.collision_layer=32 # Pickable in edit mode; never solid gameplay collision.
		var col:=CollisionShape3D.new();var shape:=BoxShape3D.new();shape.size=Vector3(spec.bounds[0],spec.bounds[1],spec.bounds[2]);col.shape=shape;col.position.y=shape.size.y/2;root.add_child(col)
	var color:=Color("83ded1")
	match spec.id:
		"tower":
			for data in [["watcher_base",0.0],["watcher_crown",8.0],["watcher_eye",8.0]]:
				var node=load("res://assets/"+data[0]+".glb").instantiate();root.add_child(node);node.position.y=data[1]
			P.box(root,Vector3(0,3,0),Vector3(1.3,6,1.3),Color("243942"),false)
		"cargo":P.orb(root,Vector3.UP*.6,.48,Color("ffcc80"),.7)
		"socket":P.ring(root,Vector3.UP*.06,1.8,Color("ffcc80"))
		"ring":P.ring(root,Vector3.UP*2.5,2.4,color,true)
		"portal_a","portal_b":
			color=Color("a68ade") if spec.id=="portal_b" else color
			P.ring(root,Vector3.UP*2.2,2.2,color,true)
			var surface:=MeshInstance3D.new();var quad:=QuadMesh.new();quad.size=Vector2(4.25,4.4);surface.mesh=quad;surface.position.y=2.2
			var mat:=ShaderMaterial.new();mat.shader=preload("res://shaders/portal.gdshader");mat.set_shader_parameter("tint",color);surface.material_override=mat
			surface.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;root.add_child(surface)
			for x in [-2.3,2.3]:P.box(root,Vector3(x,2.3,0),Vector3(.2,4.6,.4),color,false)
		"spawn":
			P.ring(root,Vector3.UP*.08,.9,color)
			P.beam(root,Vector3(0,.15,.5),Vector3(0,.15,-.6),color,.08)
		"light":P.orb(root,Vector3.UP*.5,.25,Color("ffe5bb"),1)
	return root
