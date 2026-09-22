extends Control
## Cached, unlit floor-plan raster. Redrawn only when its slice or geometry changes.
const BOUNDS:=Rect2(-160,-128,320,256)
const SCALE:=4.0
const VOID:=Color("0a151d")
const FLOOR:=Color("29434b")
const WALL:=Color("8cabae")
const RAMP:=Color("377f80")
var floors:Array[PackedVector2Array]=[]
var walls:Array[PackedVector2Array]=[]
var ramps:Array[PackedVector2Array]=[]
func project(points:PackedVector2Array) -> PackedVector2Array:
	var out:=PackedVector2Array()
	for point in points:out.append((point-BOUNDS.position)*SCALE)
	return out
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,BOUNDS.size*SCALE),VOID)
	for polygon in floors:draw_colored_polygon(project(polygon),FLOOR)
	for polygon in ramps:draw_colored_polygon(project(polygon),RAMP)
	for polygon in walls:draw_colored_polygon(project(polygon),WALL)
