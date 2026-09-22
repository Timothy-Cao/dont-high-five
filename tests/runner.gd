extends RefCounted
## Explicit developer-only entry points; normal play has no active test nodes.
const CASES={
	"--verify":"res://tests/verify.gd",
	"--metrics":"res://tests/verify_movement.gd",
	"--polish":"res://tests/verify_polish.gd",
	"--arena-verify":"res://tests/verify_arena.gd",
	"--expansion-verify":"res://tests/verify_expansion.gd",
	"--combat-power":"res://tests/verify_combat_power.gd",
	"--settings-verify":"res://tests/verify_settings.gd",
	"--charge-verify":"res://tests/verify_charge.gd",
	"--recoil-verify":"res://tests/verify_recoil.gd",
	"--fiver-capture":"res://tests/capture_fiver.gd",
	"--fixed-verify":"res://tests/verify_fixed.gd",
	"--density-verify":"res://tests/verify_density.gd",
	"--capture":"res://tests/capture_legacy.gd",
	"--arena-capture":"res://tests/capture_arena.gd",
	"--expansion-capture":"res://tests/capture_expansion.gd",
	"--combat-capture":"res://tests/capture_combat_power.gd",
	"--showcase":"res://tests/capture_showcase.gd",
	"--avatar-capture":"res://tests/capture_avatar.gd",
	"--rave-capture":"res://tests/capture_rave.gd",
	"--density-capture":"res://tests/capture_density.gd",
}
func start(lab:Node3D,args:PackedStringArray) -> bool:
	for flag in CASES:
		if flag not in args: continue
		var task:Node=load(CASES[flag]).new()
		lab.add_child(task);task.call_deferred("run",lab)
		return true
	return false
