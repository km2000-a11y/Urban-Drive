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


func _ready():
	if car:
		car.driver_name = "AI"

	await get_tree().process_frame
	_load_waypoints()
	_sort_waypoints()
	_start_at_closest_wp()

	print("[AI] Ready with", waypoints.size(), "waypoints.")


func _load_waypoints():
	if waypoint_root:
		waypoints = waypoint_root.get_children()
	else:
		push_error("AI ERROR: waypoint_root not assigned!")


func _sort_waypoints():
   waypoints.sort_custom(_wp_sort)


func _wp_sort(a, b):
	var na = int(a.name.trim_prefix("WP"))
	var nb = int(b.name.trim_prefix("WP"))
	return na < nb


func _start_at_closest_wp():
	var best_dist := INF
	var best_index := 0

	for i in range(waypoints.size()):
		var d = global_transform.origin.distance_to(waypoints[i].global_transform.origin)
		if d < best_dist:
			best_dist = d
			best_index = i

	current_wp = best_index
	print("[AI] Starting at waypoint:", waypoints[current_wp].name)


func _physics_process(delta):
	if car == null or waypoints.size() == 0:
		return

	var steer = _compute_steer()
	var accel = _compute_accel()
	var brake = _compute_brake()

	car._drive(delta, accel, brake, steer)

	_handle_stuck(delta)


func _compute_steer() -> float:
	target = waypoints[current_wp].global_transform.origin

	var to_wp = (target - car.global_transform.origin).normalized()
	var local = car.global_transform.basis.inverse() * to_wp

	var steer = clamp(local.x * steer_strength, -1.0, 1.0)

	if car.global_transform.origin.distance_to(target) < 25.0:
		current_wp = (current_wp + 1) % waypoints.size()
		print("[AI] Switched to:", waypoints[current_wp].name)

	return steer


func _compute_accel() -> float:
	var speed_kmh = car.velocity.length() * 3.6

	if speed_kmh < target_speed_kmh:
		return 1.0
	else:
		return 0.0


func _compute_brake() -> float:
	var speed_kmh = car.velocity.length() * 3.6

	if speed_kmh > target_speed_kmh + 20.0:
		return 0.7
	else:
		return 0.0


func _handle_stuck(delta):
	var moved = global_transform.origin.distance_to(last_pos)

	if moved < 0.3:
		stuck_timer += delta
	else:
		stuck_timer = 0.0

	last_pos = global_transform.origin

	if stuck_timer > 1.0:
		car._drive(delta, -0.8, 0.0, randf_range(-0.5, 0.5))
		stuck_timer = 0.0
