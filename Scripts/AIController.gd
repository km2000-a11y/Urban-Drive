extends Node3D

@export var car: CarController = null

@export var target_speed_kmh := 180.0
@export var steer_strength := 1.8
@export var aggression := 1.0
@export var mistake_chance := 0.02

func _physics_process(delta):
	if car == null:
		return

	var steer := compute_steer()
	var accel := compute_accel()
	var brake := compute_brake()

	car._drive(delta, accel, brake, steer)

func ray(dir: Vector3, dist: float) -> bool:
	var space := car.get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.new()
	q.from = car.global_transform.origin
	q.to = car.global_transform.origin + dir * dist
	q.collide_with_areas = false
	q.collide_with_bodies = true
	return space.intersect_ray(q).size() > 0

func compute_steer() -> float:
	var steer := 0.0
	var forward := -car.transform.basis.z
	var left := -car.transform.basis.x
	var right := car.transform.basis.x

	if ray(forward, 5.0):
		steer += 1.0 * aggression

	if ray(left + forward * 0.5, 4.0):
		steer += 0.6 * aggression

	if ray(right + forward * 0.5, 4.0):
		steer -= 0.6 * aggression

	steer += randf_range(-0.05, 0.05)

	if randf() < mistake_chance:
		steer += randf_range(-0.3, 0.3)

	return clamp(steer, -1.0, 1.0) * steer_strength

func compute_accel() -> float:
	var speed_kmh := car.velocity.length() * 3.6

	if abs(car.steering) > 0.4:
		return 0.4 * aggression

	if ray(-car.transform.basis.z, 5.0):
		return 0.3 * aggression

	if speed_kmh < target_speed_kmh:
		return 1.0 * aggression

	return 0.0

func compute_brake() -> float:
	if abs(car.steering) > 0.6:
		return 0.6

	if ray(-car.transform.basis.z, 3.0):
		return 1.0

	return 0.0

func apply_pp_behavior(pp: int):
	if pp < 350:
		target_speed_kmh = 120
		steer_strength = 1.2
		aggression = 0.6
		mistake_chance = 0.05
	elif pp < 500:
		target_speed_kmh = 150
		steer_strength = 1.5
		aggression = 0.8
		mistake_chance = 0.03
	elif pp < 650:
		target_speed_kmh = 180
		steer_strength = 1.8
		aggression = 1.0
		mistake_chance = 0.02
	elif pp < 800:
		target_speed_kmh = 220
		steer_strength = 2.2
		aggression = 1.2
		mistake_chance = 0.015
	else:
		target_speed_kmh = 260
		steer_strength = 2.6
		aggression = 1.4
		mistake_chance = 0.01
