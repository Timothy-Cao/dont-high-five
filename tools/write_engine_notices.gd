extends SceneTree

func _initialize() -> void:
	var license_file:=FileAccess.open("res://licenses/GODOT-LICENSE.txt",FileAccess.WRITE)
	license_file.store_string(Engine.get_license_text())
	var third_party:=FileAccess.open("res://licenses/GODOT-THIRD-PARTY.txt",FileAccess.WRITE)
	third_party.store_string("Godot engine third-party copyright notices\n\n")
	for component in Engine.get_copyright_info():
		third_party.store_string(str(component)+"\n\n")
	third_party.store_string("\nFull license texts\n\n")
	var licenses:=Engine.get_license_info()
	for name in licenses:
		third_party.store_string(str(name)+"\n"+str(licenses[name])+"\n\n")
	print("Engine license and third-party notices written from the bundled engine.")
	quit()
