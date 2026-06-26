extends Node3D

@export var car: CarController
@export var road_direction: Node3D
@export var chase_player: CarController

var ai_name := ""
var stuck_timer := 0.0
var last_pos := Vector3.ZERO

var target_speed_kmh := 180.0
var steer_strength := 1.8
var aggression := 1.0
var mistake_chance := 0.02

const AI_NAMES = [
	"David","Takashi","Ricco","Chris","Petar","Nina",
	"Steve","Linus","Jesse","Dimitri","Mirko",
	"Abdullah","Will","Jimmy M."
]

func _ready():
	ai_name = AI_NAMES.pick_random()
	print("[AI READY]", ai_name, "initialized")

func _physics_process(delta):
	if car == null:
		return

	var steer := compute_steer()
	var accel := compute_accel()
	var brake := compute_brake()

	car._drive(delta, accel, brake, steer)

	handle_stuck(delta)

func compute_steer() -> float:
	var steer := 0.0

	var forward = -car.transform.basis.z
	var left = -car.transform.basis.x
	var right = car.transform.basis.x

	# 1. Follow road direction
	if road_direction:
		var dir = -road_direction.global_transform.basis.z
		var local = car.global_transform.basis.inverse() * dir
		steer += clamp(local.x * steer_strength, -1.0, 1.0)

	# 2. Chase player (soft influence)
	if chase_player:
		var to_player = (chase_player.global_transform.origin - car.global_transform.origin).normalized()
		var local_p = car.global_transform.basis.inverse() * to_player
		steer += clamp(local_p.x * 0.4, -0.4, 0.4)

	# 3. Turn detection (shorter, safer rays)
	var left_forward = (left + forward * 0.7).normalized()
	var right_forward = (right + forward * 0.7).normalized()

	if ray(left_forward, 10.0):
		steer += 0.8
	if ray(right_forward, 10.0):
		steer -= 0.8

	# 4. Forward obstacle
	if ray(forward, 12.0):
		steer += randf_range(-0.6, 0.6)

	# 5. Wall avoidance (closer range)
	if ray(left, 3.0):
		steer += 0.6
	if ray(right, 3.0):
		steer -= 0.6

	# 6. Wall-stick breaker (very close)
	if ray(left, 1.0):
		steer += 0.4
	if ray(right, 1.0):
		steer -= 0.4

	# 7. Centering force (keeps off walls)
	var offset_x = car.global_transform.origin.x
	steer -= offset_x * 0.05

	# 8. Random mistakes
	if randf() < mistake_chance:
		steer += randf_range(-0.2, 0.2)

	return clamp(steer, -1.0, 1.0)

func compute_accel() -> float:
	var speed_kmh = car.velocity.length() * 3.6

	if speed_kmh < target_speed_kmh:
		return 1.0 * aggression

	return 0.0

func compute_brake() -> float:
	var speed_kmh = car.velocity.length() * 3.6

	if speed_kmh > target_speed_kmh + 15.0:
		return 0.5

	if ray(-car.transform.basis.z, 6.0):
		return 0.8

	return 0.0

func ray(dir: Vector3, dist: float) -> bool:
	var space = car.get_world_3d().direct_space_state
	var q = PhysicsRayQueryParameters3D.new()

	# Lift ray above ground so it doesn't hit road/wheels
	q.from = car.global_transform.origin + Vector3.UP * 1.5
	q.to = q.from + dir * dist

	var hit = space.intersect_ray(q)
	return hit.size() > 0

func handle_stuck(delta):
	if car.global_transform.origin.distance_to(last_pos) < 0.5:
		stuck_timer += delta
	else:
		stuck_timer = 0.0

	last_pos = car.global_transform.origin

	if stuck_timer > 1.0:
		car._drive(delta, -0.6, 0.0, randf_range(-0.6, 0.6))
		stuck_timer = 0.0

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
