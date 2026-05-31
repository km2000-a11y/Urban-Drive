class_name CarController
extends CharacterBody3D

# ============================================================
#  CONSTANTS
# ============================================================
const GRAVITY := 30.0
const ENGINE_BRAKE := 0.5
const DRAG := 0.1

# ============================================================
#  CAR STATS
# ============================================================
var mass := 1200.0
var zero_to_hundred := 7.0
var top_speed_kmh := 200.0
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

# GEARS
var gear_count := 6
var gear_ratios := [3.5, 2.1, 1.5, 1.2, 1.0, 0.82]
var current_gear := 1
var shift_up_rpm := 6200
var shift_down_rpm := 2000

# INTERNAL
var acceleration_calc := 0.0
var steering := 0.0
var old_rotation_y := 0.0

# DRIFT SYSTEM
var drifting := false
var drift_factor := 0.0

var debug_enabled := true
var debug_timer := 0.0

@onready var car_model := $ModelRoot
@onready var forward_ref := $ForwardRef
@onready var nitro:=$Exhaust/GPUParticles3D


# ============================================================
#  APPLY STATS
# ============================================================
func apply_stats():
	acceleration_calc = (27.78 / zero_to_hundred) * 2.0
	torque = (horsepower * 5252.0) / max_rpm
	top_speed = top_speed_kmh / 3.6

# ============================================================
#  READY
# ============================================================
func _ready():
	apply_stats()
	nitro.hide()

# ============================================================
#  GEAR LOGIC
# ============================================================
func update_gears(speed_kmh):
	if rpm > shift_up_rpm and current_gear < gear_count:
		current_gear += 1
		rpm *= 0.6

	if rpm < shift_down_rpm and current_gear > 1:
		current_gear -= 1
		rpm *= 1.3

	current_gear = clamp(current_gear, 1, gear_count)

# ============================================================
#  PHYSICS
# ============================================================
func _physics_process(delta):
	# INPUT
	var accel := Input.get_action_strength("accelerate")
	var brake := Input.get_action_strength("brake")
	var steer := Input.get_action_strength("turn_left") - Input.get_action_strength("turn_right")
	var drift_input := Input.is_action_pressed("drift")
	var nitrous:=Input.is_action_pressed("nos")

	# DRIFT SMOOTHING
	var target_drift := 0.0
	if drift_input:
		target_drift = 1.0
	drift_factor = lerp(drift_factor, target_drift, delta * 6.0)

	# STEERING
	old_rotation_y = rotation.y
	steering = lerp(steering, steer, delta * 6.0)
	rotation.y += steering * turn_speed * delta

	var delta_rot := rotation.y - old_rotation_y
	if velocity.length() > 0.1 and abs(delta_rot) > 0.0005:
		velocity = velocity.rotated(Vector3.UP, delta_rot)

	# VISUAL LEAN
	car_model.rotation_degrees.z = lerp(car_model.rotation_degrees.z, -steering * 10.0, delta * 8.0)

	# DIRECTIONS
	var forward := -transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()

	var right := transform.basis.x.normalized()

	# ============================================================
	# RPM + GEARS
	# ============================================================
	var speed_kmh := velocity.length() * 3.6

	rpm += accel * 3000.0 * delta
	rpm -= (rpm - idle_rpm) * 0.5 * delta
	rpm = clamp(rpm, idle_rpm, max_rpm)

	rpm = clamp(speed_kmh * gear_ratios[current_gear - 1] * 35.0, idle_rpm, max_rpm)

	update_gears(speed_kmh)

	var torque_factor := rpm / max_rpm

	# ============================================================
	# DRIVETRAIN TRACTION
	# ============================================================
	var traction_factor := 1.0
	match transmission:
		"Front-wheel drive":
			traction_factor = 0.85
		"Rear-wheel drive":
			traction_factor = 1.0
		"Four-wheel drive":
			traction_factor = 1.15

	# ============================================================
	# ACCELERATION
	# ============================================================
	var accel_force := 0.0

	if accel > 0.0:
		var launch_boost := 1.0
		if current_gear == 1:
			launch_boost = 1.4

		accel_force = acceleration_calc * torque_factor * traction_factor * launch_boost
		velocity += forward * accel_force * delta
	else:
		var flat := Vector3(velocity.x, 0, velocity.z)
		if flat.dot(forward) > 0.0:
			flat = flat.move_toward(Vector3.ZERO, ENGINE_BRAKE * delta)
		else:
			flat = Vector3.ZERO
		velocity.x = flat.x
		velocity.z = flat.z

	# ============================================================
	# BRAKING
	# ============================================================
	if brake > 0.0:
		var brake_force := brake_strength * (mass / 1200.0) * 1.4
		velocity = velocity.move_toward(Vector3.ZERO, brake_force * delta)

	# ============================================================
	# DRAG
	# ============================================================
	velocity -= velocity * DRAG * delta

	# ============================================================
	# LATERAL FRICTION + DRIFT
	# ============================================================
	var lateral := right.dot(velocity)

	var friction_strength := lateral_friction
	friction_strength = lerp(friction_strength, 0.25, drift_factor)

	if abs(lateral) > 0.1:
		velocity -= right * lateral * (friction_strength * 0.5) * delta

	# Extra rotation during drift
	if drift_factor > 0.1:
		rotation.y += steering * drift_factor * 1.5 * delta

	# ============================================================
	# DRIVETRAIN PERSONALITY
	# ============================================================
	match transmission:
		"Front-wheel drive":
			if drift_factor > 0.1:
				rotation.y += steering * 0.8 * delta

		"Rear-wheel drive":
			if drift_factor > 0.1:
				velocity += right * steering * 4.0 * delta

		"Four-wheel drive":
			if drift_factor > 0.1:
				velocity += right * steering * 2.0 * delta

	# ============================================================
	# SPEED LIMIT
	# ============================================================
	var flat2 := Vector3(velocity.x, 0, velocity.z)
	if flat2.length() > top_speed:
		flat2 = flat2.normalized() * top_speed
		velocity.x = flat2.x
		velocity.z = flat2.z
	
	if nitrous:
		nitro.show()
	else:
		nitro.hide()
		
	# ============================================================
	# GRAVITY
	# ============================================================
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = -0.01

	# ============================================================
	# COLLISIONS
	# ============================================================
	var old_velocity := velocity
	move_and_slide()

	# MOMENTUM EXCHANGE
	for i in range(get_slide_collision_count()):
		var col := get_slide_collision(i)
		var other := col.get_collider()

		if other is CarController:
			var my_p := mass * velocity
			var their_p :Vector3 = other.mass * other.velocity

			var impulse := (my_p - their_p) * 0.5

			velocity += impulse / mass
			other.velocity -= impulse / other.mass

	# DEBUG
	_debug_stats(delta, flat2.length())

# ============================================================
#  DEBUG
# ============================================================
func _debug_stats(delta, speed):
	if not debug_enabled:
		return

	debug_timer += delta
	if debug_timer < 1.0:
		return
	debug_timer = 0.0

	var speed_kmh: int = speed * 3.6
	print("\n===== CAR DEBUG =====")
	print("Speed:", speed_kmh, "km/h")
	print("=====================\n")
	print("ON FLOOR:", is_on_floor(), "vel:", velocity)
	print("BODY POS:", global_transform.origin)
	print("MODEL POS:", car_model.global_transform.origin)
