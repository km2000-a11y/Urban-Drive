class_name AI_Car
extends CarController

var ai_enabled := true

# Dynamically set from PP
var target_speed_kmh := 180.0
var steer_strength := 1.8
var aggression := 1.0
var mistake_chance := 0.02

# Random human names
var ai_names := [
	"David","Takashi","Ricco","Chris","Petar",
	"Nina","Steve","Linus","Chris","Jesse",
	"Dimitri","Mirko","Abdullah","Will","Jimmy M."
]

func _ready():
	# Override the default "Player" name from CarController
	driver_name = ai_names[randi() % ai_names.size()]
	_set_behavior_from_pp()
	print("AI Driver:", driver_name, " | PP:", performance_points)


# ============================================================
#  PP → Behavior Mapping
# ============================================================
func _set_behavior_from_pp():
	var pp := performance_points

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


# ============================================================
#  MAIN AI LOOP
# ============================================================
func _physics_process(delta):
	if not ai_enabled:
		return

	var steer := _compute_steering()
	var accel := _compute_acceleration()
	var brake := 0.0

	_apply_ai_input(accel, brake, steer, delta)
	super._physics_process(delta)


# ============================================================
#  RAYCAST (NO NODES)
# ============================================================
func _raycast(dir: Vector3, dist: float) -> bool:
	var space := get_world_3d().direct_space_state

	var q := PhysicsRayQueryParameters3D.new()
	q.from = global_transform.origin
	q.to = global_transform.origin + dir * dist
	q.collide_with_areas = false
	q.collide_with_bodies = true

	var result := space.intersect_ray(q)
	return result.size() > 0


# ============================================================
#  STEERING (WALL AVOIDANCE + HUMAN WOBBLE + MISTAKES)
# ============================================================
func _compute_steering() -> float:
	var steer := 0.0

	var forward := -transform.basis.z
	var left := -transform.basis.x
	var right := transform.basis.x

	# Wall avoidance
	if _raycast(forward, 5.0):
		steer += 1.0 * aggression

	if _raycast(left + forward * 0.5, 4.0):
		steer += 0.6 * aggression

	if _raycast(right + forward * 0.5, 4.0):
		steer -= 0.6 * aggression

	# Human wobble
	steer += randf_range(-0.05, 0.05)

	# Human mistakes
	if randf() < mistake_chance:
		steer += randf_range(-0.3, 0.3)

	return clamp(steer, -1.0, 1.0) * steer_strength


# ============================================================
#  ACCELERATION (PP‑BASED)
# ============================================================
func _compute_acceleration() -> float:
	var speed_kmh := velocity.length() * 3.6

	# Slow down when turning hard
	if abs(steering) > 0.4:
		return 0.4 * aggression

	# Slow down near walls
	if _raycast(-transform.basis.z, 5.0):
		return 0.3 * aggression

	# Full throttle until target speed
	if speed_kmh < target_speed_kmh:
		return 1.0 * aggression

	return 0.0


# ============================================================
#  APPLY INPUT TO CarController
# ============================================================
func _apply_ai_input(accel: float, brake: float, steer: float, delta: float):
	steering = lerp(steering, steer, delta * 5.0)

	var forward := -transform.basis.z
	var speed_kmh := velocity.length() * 3.6

	if accel > 0.0 and speed_kmh < target_speed_kmh:
		velocity += forward * accel * acceleration_calc * delta

	if brake > 0.1:
		velocity = velocity.move_toward(Vector3.ZERO, brake_strength * delta)
