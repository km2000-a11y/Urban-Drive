class_name CarController
extends CharacterBody3D

# ============================================================
#  CONSTANTS
# ============================================================
const GRAVITY := 30.0
const ENGINE_BRAKE := 1.5
const DRAG := 0.4

# ============================================================
#  CAR STATS (Overridden by child scripts)
# ============================================================
var mass := 1200.0
var zero_to_hundred := 7.0
var top_speed := 60.0
var turn_speed := 2.5
var brake_strength := 20.0
var lateral_friction := 1.2
var transmission := "Front-wheel drive"

# ENGINE
var horsepower := 150.0
var max_rpm := 6500.0
var idle_rpm := 900.0
var rpm := 900.0
var torque := 0.0

# ============================================================
#  INTERNAL
# ============================================================
var acceleration_calc := 0.0
var steering := 0.0
var old_rotation_y := 0.0

var debug_enabled := true
var debug_timer := 0.0

@onready var car_model := $ModelRoot
@onready var forward_ref := $ForwardRef


# ============================================================
#  APPLY STATS (called by child AFTER overriding)
# ============================================================
func apply_stats():
	acceleration_calc = 27.78 / zero_to_hundred
	torque = (horsepower * 5252.0) / max_rpm


# ============================================================
#  READY
# ============================================================
func _ready():
	# Parent ready runs first, but child will override stats and call apply_stats()
	apply_stats()


# ============================================================
#  PHYSICS
# ============================================================
func _physics_process(delta):

	# ------------------------------------------------------------
	# INPUT
	# ------------------------------------------------------------
	var accel := Input.get_action_strength("accelerate")
	var brake := Input.get_action_strength("brake")
	var steer := Input.get_action_strength("turn_left") - Input.get_action_strength("turn_right")

	# ------------------------------------------------------------
	# STEERING
	# ------------------------------------------------------------
	old_rotation_y = rotation.y
	steering = lerp(steering, steer, delta * 6.0)
	rotation.y += steering * turn_speed * delta

	# Rotate velocity with car
	var delta_rot := rotation.y - old_rotation_y
	if delta_rot != 0.0:
		velocity = velocity.rotated(Vector3.UP, delta_rot)

	# Visual lean
	var tilt := -steering * 10.0
	car_model.rotation_degrees.z = lerp(car_model.rotation_degrees.z, tilt, delta * 8.0)

	# ------------------------------------------------------------
	# DIRECTIONS
	# ------------------------------------------------------------
	var forward :Vector3= (-forward_ref.global_transform.basis.z).normalized()
	var right :Vector3= forward_ref.global_transform.basis.x.normalized()

	# ------------------------------------------------------------
	# RPM SIMULATION
	# ------------------------------------------------------------
	rpm += accel * 3000.0 * delta
	rpm -= (rpm - idle_rpm) * 0.5 * delta
	rpm = clamp(rpm, idle_rpm, max_rpm)

	var torque_factor := rpm / max_rpm

	# ------------------------------------------------------------
	# DRIVETRAIN TRACTION
	# ------------------------------------------------------------
	var traction_factor := 1.0
	match transmission:
		"Front-wheel drive": traction_factor = 0.85
		"Rear-wheel drive": traction_factor = 1.0
		"Four-wheel drive": traction_factor = 1.15

	# ------------------------------------------------------------
	# ACCELERATION
	# ------------------------------------------------------------
	if accel > 0.0:
		var accel_force := acceleration_calc * torque_factor * traction_factor
		velocity += forward * accel_force * delta
	else:
		velocity = velocity.move_toward(Vector3.ZERO, ENGINE_BRAKE * delta)

	# ------------------------------------------------------------
	# BRAKING
	# ------------------------------------------------------------
	if brake > 0.0:
		velocity = velocity.move_toward(Vector3.ZERO, brake_strength * delta)

	# ------------------------------------------------------------
	# DRAG
	# ------------------------------------------------------------
	velocity = velocity.move_toward(Vector3.ZERO, DRAG * delta)

	# ------------------------------------------------------------
	# LATERAL FRICTION
	# ------------------------------------------------------------
	var lateral := right.dot(velocity)
	if abs(lateral) > 0.05:
		velocity -= right * lateral * lateral_friction * delta

	# ------------------------------------------------------------
	# DRIVETRAIN PERSONALITY
	# ------------------------------------------------------------
	match transmission:
		"Front-wheel drive":
			if accel > 0.7:
				rotation.y += steering * 0.1 * delta

		"Rear-wheel drive":
			velocity -= right * lateral * 0.15 * delta

		"Four-wheel drive":
			velocity = velocity.move_toward(Vector3.ZERO, -0.25 * delta)

	# ------------------------------------------------------------
	# SPEED LIMIT
	# ------------------------------------------------------------
	var flat := Vector3(velocity.x, 0, velocity.z)
	if flat.length() > top_speed:
		flat = flat.normalized() * top_speed
		velocity.x = flat.x
		velocity.z = flat.z

	# ------------------------------------------------------------
	# GRAVITY
	# ------------------------------------------------------------
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	# ------------------------------------------------------------
	# COLLISION HANDLING
	# ------------------------------------------------------------
	var old_velocity := velocity
	move_and_slide()

	var collision_count := get_slide_collision_count()
	if collision_count > 0:
		var combined_reflect := Vector3.ZERO
		for i in range(collision_count):
			combined_reflect += old_velocity.bounce(get_slide_collision(i).get_normal())
		velocity = combined_reflect / collision_count

	# ------------------------------------------------------------
	# DEBUG
	# ------------------------------------------------------------
	_debug_stats(delta, flat.length())


# ============================================================
#  DEBUG FUNCTION
# ============================================================
func _debug_stats(delta, speed):
	if not debug_enabled:
		return

	debug_timer += delta
	if debug_timer < 1.0:
		return
	debug_timer = 0.0

	print("\n===== CAR DEBUG =====")
	print("HP:", horsepower, "  Torque:", torque)
	print("RPM:", rpm, "/", max_rpm)
	print("0–100:", zero_to_hundred)
	print("Top Speed:", top_speed)
	print("Turn Speed:", turn_speed)
	print("Brake Strength:", brake_strength)
	print("Lateral Friction:", lateral_friction)
	print("Transmission:", transmission)
	print("Speed:", speed)
	print("=====================\n")
