class_name AIController
extends Node3D

@export var car: CarController
@export var waypoint_root: Node3D

var waypoints: Array = []
var current_wp := 0
var target: Vector3 = Vector3.ZERO

var target_speed_kmh := 140.0
var steer_strength := 2.0
var aggression := 1.0

var stuck_timer := 0.0
var last_pos := Vector3.ZERO

var driver_names := [
	"David","Takashi","Ricco","Chris","Petar","Nina","Steve","Linus",
	"Chris","Jesse","Dimitri","Mirko","Abdullah","Will","Jimmy M.",
	"Tiffany","Hoff","Jake"
]


func _ready():
	print("[AI] _ready() called")

	var chosen_name :String= driver_names[randi() % driver_names.size()]
	if car:
		car.driver_name = chosen_name
		car.controls_enabled = false
		print("[AI] Driver:", chosen_name)
	else:
		print("[AI] ERROR: car not assigned")

	if waypoint_root == null:
	var scene := get_tree().get_current_scene()

	# Deep search anywhere in the scene tree
	var found := scene.find_child("Waypoints", true, false)

	if found:
		waypoint_root = found
		print("[AI] Found Waypoints:", waypoint_root)
	else:
		print("[AI] ERROR: Waypoints not found in scene!")


	await get_tree().process_frame

	if car == null:
		print("[AI] ERROR: car not assigned (after delay)")
		return


	_load_waypoints()
	if waypoints.is_empty():
		print("[AI] ERROR: No waypoints")
		return

	_sort_waypoints()
	_force_start_at_wp0()

	print("[AI] READY FINISHED")


func _load_waypoints():
	waypoints.clear()
	if waypoint_root:
		waypoints = waypoint_root.get_children()


func _sort_waypoints():
	waypoints.sort_custom(_wp_sort)


func _wp_sort(a, b):
	var na := _safe_wp_number(a.name)
	var nb := _safe_wp_number(b.name)
	return na < nb


func _safe_wp_number(name: String) -> int:
	var trimmed := name.trim_prefix("WP")
	if trimmed.is_valid_int():
		return int(trimmed)
	return 99999


func _force_start_at_wp0():
	for i in range(waypoints.size()):
		if waypoints[i].name == "WP0":
			current_wp = i
			return
	current_wp = 0


func _physics_process(delta):
	if car == null or waypoints.is_empty():
		return

	if current_wp >= waypoints.size():
		current_wp = 0

	var steer := _compute_steer(delta)
	var accel := _compute_accel()
	var brake := _compute_brake()

	car._drive(delta, accel, brake, steer)
	_handle_stuck(delta)


# ---------------------------------------------------------
# PRO RACER STEERING
# ---------------------------------------------------------
func _compute_steer(delta) -> float:
	var wp :Node3D= waypoints[current_wp]
	var to_wp := (wp.global_transform.origin - car.global_transform.origin).normalized()
	var local := car.global_transform.basis.inverse() * to_wp

	var steer :float= clamp(local.x * steer_strength, -1.0, 1.0)

	var speed_kmh := car.velocity.length() * 3.6
	if speed_kmh > 80.0:
		steer *= 1.4
	if speed_kmh > 120.0:
		steer *= 1.8

	var space := get_world_3d().direct_space_state
	# Raycast origin (lower + centered)
	var origin := car.global_transform.origin + Vector3.UP * 1.0

	# Raycast distance (longer)
	var side_dist := 3.0

	# Left ray
	var left_q := PhysicsRayQueryParameters3D.new()
	left_q.from = origin
	left_q.to = origin + (-car.global_transform.basis.x * side_dist)

	# Right ray
	var right_q := PhysicsRayQueryParameters3D.new()
	right_q.from = origin
	right_q.to = origin + (car.global_transform.basis.x * side_dist)

	var left_hit := space.intersect_ray(left_q)
	var right_hit := space.intersect_ray(right_q)

	# Tunnel detection (center ray)
	var center_q := PhysicsRayQueryParameters3D.new()
	center_q.from = origin
	center_q.to = origin + (-car.global_transform.basis.z * 6.0)

	var center_hit := space.intersect_ray(center_q)

	# Only disable avoidance if center ray hits VERY CLOSE
	if not center_hit.is_empty() and center_hit.position.distance_to(origin) < 2.0:
		left_hit = {}
		right_hit = {}

	# Wall avoidance
	if not left_hit.is_empty():
		steer += 1.5 * aggression

	if not right_hit.is_empty():
		steer -= 1.5 * aggression



	# Lane centering
	steer = lerp(steer, 0.0, 0.15)

	# Human wobble
	steer += randf_range(-0.05, 0.05) * (1.0 / aggression)

	# Waypoint switching
	var dist := car.global_transform.origin.distance_to(wp.global_transform.origin)
	if dist < 22.0:
		current_wp = (current_wp + 1) % waypoints.size()

	return clamp(steer, -1.0, 1.0)


# ---------------------------------------------------------
# PRO RACER ACCELERATION
# ---------------------------------------------------------
func _compute_accel() -> float:
	var speed_kmh := car.velocity.length() * 3.6

	var next_wp :Node3D= waypoints[(current_wp + 1) % waypoints.size()]
	var dir_to_next := (next_wp.global_transform.origin - car.global_transform.origin).normalized()
	var local_next := car.global_transform.basis.inverse() * dir_to_next

	if abs(local_next.x) > 0.45:
		return 0.35 * aggression

	if speed_kmh < target_speed_kmh:
		return 1.0

	return 0.0


func _compute_brake() -> float:
	var speed_kmh := car.velocity.length() * 3.6

	if speed_kmh > target_speed_kmh + 20.0:
		return 0.7

	return 0.0


func _handle_stuck(delta):
	var moved := global_transform.origin.distance_to(last_pos)

	if moved < 0.3:
		stuck_timer += delta
	else:
		stuck_timer = 0.0

	last_pos = global_transform.origin

	if stuck_timer > 1.0:
		var steer := randf_range(-0.5, 0.5)
		car._drive(delta, -0.8, 0.0, steer)
		stuck_timer = 0.0
