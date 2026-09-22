extends RefCounted
## Explicit developer-only entry points; normal play has no active test nodes.
const CASES={
	"--workshop-gameplay-capture":"res://tests/capture_workshop_gameplay.gd",
	"--workshop-gameplay-verify":"res://tests/verify_workshop_gameplay.gd",
	"--refinement-capture":"res://tests/capture_refinement.gd",
	"--refinement-verify":"res://tests/verify_refinement.gd",
	"--minimap-verify":"res://tests/verify_minimap.gd",
	"--minimap-capture":"res://tests/capture_minimap.gd",
	"--reveal-capture":"res://tests/capture_reveal.gd",
	"--reveal-verify":"res://tests/verify_reveal_demo.gd",
	"--workshop-capture":"res://tests/capture_workshop.gd",
	"--workshop-verify":"res://tests/verify_workshop.gd",
	"--crowd-capture":"res://tests/capture_crowd.gd",
	"--crowd-verify":"res://tests/verify_crowd.gd",
	"--orbital-capture":"res://tests/capture_orbital.gd",
	"--orbital-verify":"res://tests/verify_orbital.gd",
	"--night-capture":"res://tests/capture_night.gd",
	"--carry-night-verify":"res://tests/verify_carry_night.gd",
	"--wrap-verify":"res://tests/verify_wrap.gd",
	"--sentinel-capture":"res://tests/capture_sentinel.gd",
	"--watcher-capture":"res://tests/capture_watcher.gd",
	"--pilot-capture":"res://tests/capture_pilot.gd",
	"--plan-coverage":"res://tests/plan_coverage.gd",
	"--pilot-verify":"res://tests/verify_pilot.gd",
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
		# Deterministic fixtures opt out of ambient attacks; demo-specific tests enable them.
		if lab.session:lab.session.watcher.demo_patrol=false
		var task:Node=load(CASES[flag]).new()
		lab.add_child(task);task.call_deferred("run",lab)
		return true
	return false
