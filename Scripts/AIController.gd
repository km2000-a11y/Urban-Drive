class_name AIController
extends Node3D

@export var car: CarController
@export var waypoint_root: Node3D

var waypoints: Array = []
var current_wp := 0

var target_speed_kmh := 150.0
var steer_strength := 1.8
var aggression := 1.0

var stuck_timer := 0.0
var last_pos := Vector3.ZERO

var driver_names := [
	"David","Takashi","Ricco","Chris","Petar","Nina","Steve","Linus",
	"Chris","Jesse","Dimitri","Mirko","Abdullah","Will","Jimmy M.",
	"Tiffany","Hoff","Jake"
]

func _ready():
	# Safety: AIController must NEVER run on player car
	if car != null and not car.is_ai:
		queue_free()
		return

	if car == null:
		print("[AI] ERROR: No car assigned!")
		queue_free()
		return

	# Assign driver name
	var chosen_name = driver_names[randi() % driver_names.size()]
	car.driver_name = chosen_name
	car.controls_enabled = false
	print("[AI] Driver:", chosen_name)

	# Find waypoint root if not assigned
	var scene := get_tree().get_current_scene()
	if waypoint_root == null:
		var found := scene.find_child("Waypoints", true, false)
		if found != null:
			waypoint_root = found
		else:
			print("[AI] ERROR: Waypoints not found!")
			queue_free()
			return

	_load_waypoints()
	_sort_waypoints()
	_force_start_at_wp0()

	last_pos = car.global_transform.origin
	print("[AI] READY")


func _load_waypoints():
	waypoints.clear()
	if waypoint_root != null:
		waypoints = waypoint_root.get_children()


func _sort_waypoints():
	waypoints.sort_custom(_wp_sort)


func _wp_sort(a, b):
	var na = _safe_wp_number(a.name)
	var nb = _safe_wp_number(b.name)
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

	var steer = _compute_steer(delta)
	var accel = _compute_accel()
	var brake = _compute_brake()

	car._drive(delta, accel, brake, steer)
	_handle_stuck(delta)


# ---------------------------------------------------------
# SMART STEERING (predictive + smooth)
# ---------------------------------------------------------
func _compute_steer(delta) -> float:
	var wp = waypoints[current_wp]
	var to_wp = (wp.global_transform.origin - car.global_transform.origin).normalized()
	var local = car.global_transform.basis.inverse() * to_wp

	var steer = clamp(local.x * steer_strength, -1.0, 1.0)

	# Predictive steering (look ahead)
	var future_wp = waypoints[(current_wp + 2) % waypoints.size()]
	var to_future = (future_wp.global_transform.origin - car.global_transform.origin).normalized()
	var local_future = car.global_transform.basis.inverse() * to_future
	steer += local_future.x * 0.25

	# Smooth steering
	steer = lerp(car.steer_input, steer, delta * 4.0)

	# Gentle wall avoidance
	var space := get_world_3d().direct_space_state
	var origin := car.global_transform.origin + Vector3.UP * 1.0
	var side_dist := 2.5

	var left_q := PhysicsRayQueryParameters3D.new()
	left_q.from = origin
	left_q.to = origin + (-car.global_transform.basis.x * side_dist)
	var left_hit := space.intersect_ray(left_q)

	var right_q := PhysicsRayQueryParameters3D.new()
	right_q.from = origin
	right_q.to = origin + (car.global_transform.basis.x * side_dist)
	var right_hit := space.intersect_ray(right_q)


	if not left_hit.is_empty():
		steer += 0.35 * aggression
	if not right_hit.is_empty():
		steer -= 0.35 * aggression

	# Waypoint switching (bigger radius)
	var dist := car.global_transform.origin.distance_to(wp.global_transform.origin)
	if dist < 35.0:
		current_wp = (current_wp + 1) % waypoints.size()

	return clamp(steer, -1.0, 1.0)


# ---------------------------------------------------------
# SMART ACCELERATION (corner prediction)
# ---------------------------------------------------------
func _compute_accel() -> float:
	var speed_kmh := car.velocity.length() * 3.6

	var next_wp = waypoints[(current_wp + 1) % waypoints.size()]
	var dir_to_next = (next_wp.global_transform.origin - car.global_transform.origin).normalized()
	var local_next = car.global_transform.basis.inverse() * dir_to_next

	# Slow down before sharp turns
	if abs(local_next.x) > 0.35:
		return 0.25 * aggression

	# If next waypoint is behind → brake
	if local_next.z < 0.0:
		return 0.0

	# Normal acceleration
	if speed_kmh < target_speed_kmh:
		return 1.0

	return 0.0


func _compute_brake() -> float:
	var speed_kmh := car.velocity.length() * 3.6
	if speed_kmh > target_speed_kmh + 25.0:
		return 0.7
	return 0.0


# ---------------------------------------------------------
# SMART STUCK RECOVERY
# ---------------------------------------------------------
func _handle_stuck(delta):
	var moved := car.global_transform.origin.distance_to(last_pos)

	if moved < 0.25:
		stuck_timer += delta
	else:
		stuck_timer = 0.0

	last_pos = car.global_transform.origin

	if stuck_timer > 1.0:
		# Reverse strongly
		car._drive(delta, -1.0, 0.0, randf_range(-0.6, 0.6))
	elif stuck_timer > 0.5:
		# Hard steer to escape
		car._drive(delta, 0.0, 0.0, randf_range(-1.0, 1.0))
