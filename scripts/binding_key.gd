extends Button
var binder: Control
var action_name := ""
var key_code := 0
func _get_drag_data(_at: Vector2) -> Variant:
	var action := action_name
	if action.is_empty() and key_code!=0:
		for candidate in binder.lab.controls.keys:
			if binder.lab.controls.keys[candidate]==key_code: action=candidate
	if action.is_empty(): return null
	var preview := Label.new()
	preview.text = binder.lab.controls.TITLES[action]
	preview.add_theme_font_size_override("font_size",22)
	set_drag_preview(preview)
	return {"ability":action}
func _can_drop_data(_at: Vector2,data: Variant) -> bool:
	return key_code!=0 and data is Dictionary and data.has("ability") and binder.lab.controls.permitted(key_code)
func _drop_data(_at: Vector2,data: Variant) -> void:
	binder.assign_binding(data.ability,key_code)
