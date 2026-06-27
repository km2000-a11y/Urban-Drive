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
	last_pos = global_transform.origin
	print("[AI READY] Driver:", ai_name)


# ---------------------------------------------------------
# MAIN LOOP
# ---------------------------------------------------------

func _physics_process(delta):
	if car == null:
		return

	var steer = compute_steer()
	var accel = compute_accel()
	var brake = compute_brake()

	car._drive(delta, accel, brake, steer)

	handle_stuck(delta)


# ---------------------------------------------------------
# STEERING LOGIC
# ---------------------------------------------------------

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

	# 2. Chase player (soft)
	if chase_player:
		var to_player = (chase_player.global_transform.origin - car.global_transform.origin).normalized()
		var local_p = car.global_transform.basis.inverse() * to_player
		steer += clamp(local_p.x * 0.35, -0.35, 0.35)

	# 3. Obstacle avoidance
	if ray(forward, 10.0):
		steer += randf_range(-0.5, 0.5)

	if ray(left + forward * 0.6, 8.0):
		steer += 0.7
	if ray(right + forward * 0.6, 8.0):
		steer -= 0.7

	# 4. Wall avoidance (close)
	if ray(left, 2.5):
		steer += 0.5
	if ray(right, 2.5):
		steer -= 0.5

	# 5. Random mistakes
	if randf() < mistake_chance:
		steer += randf_range(-0.15, 0.15)

	return clamp(steer, -1.0, 1.0)


# ---------------------------------------------------------
# ACCELERATION
# ---------------------------------------------------------

func compute_accel() -> float:
	var speed_kmh = car.velocity.length() * 3.6

	if speed_kmh < target_speed_kmh:
		return 1.0 * aggression

	return 0.0


# ---------------------------------------------------------
# BRAKING
# ---------------------------------------------------------

func compute_brake() -> float:
	var speed_kmh = car.velocity.length() * 3.6

	if speed_kmh > target_speed_kmh + 12.0:
		return 0.5

	if ray(-car.transform.basis.z, 5.0):
		return 0.8

	return 0.0


# ---------------------------------------------------------
# RAYCAST
# ---------------------------------------------------------

func ray(dir: Vector3, dist: float) -> bool:
	var space = car.get_world_3d().direct_space_state
	var q = PhysicsRayQueryParameters3D.new()

	q.from = car.global_transform.origin + Vector3.UP * 1.5
	q.to = q.from + dir.normalized() * dist

	return space.intersect_ray(q).size() > 0


# ---------------------------------------------------------
# STUCK HANDLING
# ---------------------------------------------------------

func handle_stuck(delta):
	var moved = car.global_transform.origin.distance_to(last_pos)

	if moved < 0.4:
		stuck_timer += delta
	else:
		stuck_timer = 0.0

	last_pos = car.global_transform.origin

	if stuck_timer > 1.0:
		car._drive(delta, -0.7, 0.0, randf_range(-0.5, 0.5))
		stuck_timer = 0.0


# ---------------------------------------------------------
# PP BEHAVIOR
# ---------------------------------------------------------

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
