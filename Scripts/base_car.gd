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
var transmission := "Front-wheel drive" # "Front-wheel drive", "Rear-wheel drive", "Four-wheel drive"

# DIESEL FLAG
var is_diesel := false

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
var boost := false

# PERFORMANCE POINTS
var performance_points := 0

# DEBUG
var debug_enabled := true

# HANDLING PROFILE
var handling_type := "balanced"

# ============================================================
#  SPAWN ORIENTATION
# ============================================================
@export var spawn_yaw_deg: float = 0.0
# Set this per car:
# 0   = already faces correct way
# 180 = model is backwards
# 90/-90 = sideways, etc.

# ============================================================
#  NODES
# ============================================================
@onready var car_model := $ModelRoot
@onready var forward_ref := $ForwardRef
@onready var nitro := $Exhaust/GPUParticles3D

# ============================================================
#  APPLY STATS
# ============================================================
func apply_stats():
	acceleration_calc = (27.78 / zero_to_hundred) * 3.0
	torque = (horsepower * 5252.0) / max_rpm

	if is_diesel:
		torque *= 1.6

	top_speed = top_speed_kmh / 3.6

	performance_points = round(
		(top_speed_kmh * 1.5)
		+ (100.0 / zero_to_hundred)
		+ ((horsepower / mass) * 700.0)
	)

func apply_handling_profile():
	match handling_type:
		"light_sport":
			turn_speed *= 1.25
			lateral_friction *= 1.15
			brake_strength *= 1.1
			mass *= 0.95
		"heavy_muscle":
			turn_speed *= 0.75
			lateral_friction *= 0.85
			brake_strength *= 0.9
			mass *= 1.15
		"luxury_boat":
			turn_speed *= 0.65
			lateral_friction *= 0.8
			brake_strength *= 0.85
			mass *= 1.2
		"awd_grip":
			turn_speed *= 1.05
			lateral_friction *= 1.2
			brake_strength *= 1.1
		"fwd_hot_hatch":
			turn_speed *= 1.15
			lateral_friction *= 1.05
		"supercar":
			turn_speed *= 1.2
			lateral_friction *= 1.3
			brake_strength *= 1.25
			mass *= 0.9
		"balanced":
			pass

# ============================================================
#  READY
# ============================================================
func _ready():
	apply_stats()
	apply_handling_profile()
	nitro.hide()

# ============================================================
#  GEAR LOGIC
# ============================================================
func update_gears(speed_kmh: float) -> void:
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
func _physics_process(delta: float) -> void:
	var accel := Input.get_action_strength("accelerate")
	var brake := Input.get_action_strength("brake")
	var steer := Input.get_action_strength("turn_left") - Input.get_action_strength("turn_right")
	var drift_input := Input.is_action_pressed("drift")
	var nitrous := Input.is_action_pressed("nos")

	var target_drift := 0.0
	if drift_input:
		target_drift = 1.0
	drift_factor = lerp(drift_factor, target_drift, delta * 6.0)
	drifting = drift_factor > 0.1

	old_rotation_y = rotation.y
	steering = lerp(steering, steer, delta * 6.0)

	var forward := -transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()

	var right := transform.basis.x.normalized()

	var speed := velocity.length()
	var speed_kmh := speed * 3.6

	if not drifting:
		rotation.y += steering * turn_speed * delta

		if speed > 0.1:
			velocity = velocity.rotated(Vector3.UP, steering * turn_speed * 0.20 * delta)

		lateral_friction = 1.2
	else:
		var drift_steer := steering * (turn_speed * 0.35)
		rotation.y += drift_steer * delta

		var slip_strength := 2.0 * drift_factor
		velocity = velocity.rotated(Vector3.UP, -steer * slip_strength * delta)

		lateral_friction = lerp(1.2, 0.12, drift_factor)

	car_model.rotation_degrees.z = lerp(car_model.rotation_degrees.z, -steering * 10.0, delta * 8.0)

	forward = -transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	right = transform.basis.x.normalized()

	var wall_block := false
	var wall_scrape := false

	for i in range(get_slide_collision_count()):
		var col := get_slide_collision(i)
		var other := col.get_collider()

		# Skip props — they should NOT trigger wall slowdown
		if other is RigidBody3D:
			continue

		var n := col.get_normal()
		n.y = 0.0
		n = n.normalized()

		if forward.dot(n) < -0.75:
			wall_block = true

		if abs(right.dot(n)) > 0.55:
			wall_scrape = true

	if wall_block:
		var impact_strength :float = clamp(speed_kmh / 120.0, 0.2, 1.0)
		velocity *= (1.0 - impact_strength * 0.55)
		velocity -= forward * (impact_strength * 4.0)

	if wall_scrape:
		var scrape_strength :float = clamp(speed_kmh / 220.0, 0.05, 0.25)
		velocity -= right * (scrape_strength * 6.0)
		velocity *= (1.0 - scrape_strength * 0.15)

	if speed_kmh < 2.0:
		if accel > 0.1:
			rpm = lerp(rpm, idle_rpm + 2500.0, delta * 2.5)
		else:
			rpm = lerp(rpm, idle_rpm, delta * 3.0)
	else:
		var wheel_rpm: float = speed_kmh * gear_ratios[current_gear - 1] * 35.0
		rpm = lerp(rpm, wheel_rpm, delta * 4.0)

	rpm = clamp(rpm, idle_rpm, max_rpm)
	update_gears(speed_kmh)

	var torque_factor := rpm / max_rpm

	var traction_factor := 1.0
	var throttle_steer := 0.0
	var launch_grip := 1.0

	match transmission:
		"Front-wheel drive":
			traction_factor = 0.90
			throttle_steer = -steering * 0.35
			launch_grip = 1.15
		"Rear-wheel drive":
			traction_factor = 1.05
			throttle_steer = steering * 0.55
			launch_grip = 0.85
		"Four-wheel drive":
			traction_factor = 1.20
			throttle_steer = steering * 0.25
			launch_grip = 1.35

	var accel_force := 0.0

	if accel > 0.0:
		var launch_boost := 1.0
		if current_gear == 1:
			launch_boost = 1.4

		accel_force = acceleration_calc * torque_factor * traction_factor * launch_boost * launch_grip

		if transmission == "Front-wheel drive" and current_gear == 1:
			accel_force *= 1.25

		velocity += forward * accel_force * delta
		velocity = velocity.rotated(Vector3.UP, throttle_steer * delta)
	else:
		var flat := Vector3(velocity.x, 0, velocity.z)

		var brake_power := ENGINE_BRAKE
		if drifting:
			brake_power = ENGINE_BRAKE * 0.05

		if flat.dot(forward) > 0.0:
			flat = flat.move_toward(Vector3.ZERO, brake_power * delta)
		else:
			flat = Vector3.ZERO

		velocity.x = flat.x
		velocity.z = flat.z

	if nitrous:
		nitro.show()
		velocity += forward * accel_force * 1.35 * delta

		var nitro_top := top_speed * 1.10
		if velocity.length() > nitro_top:
			velocity = velocity.normalized() * nitro_top
	else:
		nitro.hide()

	if brake > 0.1:
		var brake_force := brake_strength * (mass / 1200.0) * 1.4
		velocity = velocity.move_toward(Vector3.ZERO, brake_force * delta)

	velocity -= velocity * DRAG * delta

	var front_grip := 1.0
	var rear_grip := 1.0

	match transmission:
		"Front wheel drive":
			front_grip = 0.85
			rear_grip = 1.15

			var understeer_strength :float = clamp(speed_kmh / 120.0, 0.0, 1.0)
			rotation.y += steering * turn_speed * delta * (1.0 - understeer_strength * 0.55)
			velocity += right * (steering * understeer_strength * 2.0) * delta

		"Rear wheel drive":
			front_grip = 1.15
			rear_grip = 0.85

			var oversteer_strength :float = clamp(speed_kmh / 140.0, 0.0, 1.0)
			rotation.y += steering * turn_speed * delta * (1.0 + oversteer_strength * 0.65)
			velocity += right * (steering * oversteer_strength * 4.0) * delta

		"Four wheel drive":
			front_grip = 1.05
			rear_grip = 1.05

			var awd_balance :float = clamp(speed_kmh / 160.0, 0.0, 1.0)
			rotation.y += steering * turn_speed * delta * (1.0 + awd_balance * 0.15)

	var lateral := right.dot(velocity)
	var friction_strength: float = lerp(lateral_friction, 0.7, drift_factor)

	if abs(lateral) > 0.1:
		velocity -= right * lateral * (friction_strength * 0.15) * delta

	if drifting:
		match transmission:
			"Front-wheel drive":
				rotation.y += steering * 0.6 * delta
				velocity += right * (-steering * 2.0) * delta
			"Rear-wheel drive":
				velocity += right * (steering * 6.0) * delta
				rotation.y += steering * 0.25 * delta
			"Four-wheel drive":
				velocity += right * (steering * 3.0) * delta
				rotation.y += steering * 0.15 * delta

	var flat2 := Vector3(velocity.x, 0, velocity.z)

	if nitrous:
		var nitro_top2 := top_speed * 1.12
		if flat2.length() > nitro_top2:
			flat2 = flat2.normalized() * nitro_top2
	else:
		if flat2.length() > top_speed:
			flat2 = flat2.normalized() * top_speed

	velocity.x = flat2.x
	velocity.z = flat2.z

	Global.speed = speed_kmh
	Global.gear = current_gear

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = -0.01

	var old_velocity := velocity
	move_and_slide()

	# ============================================================
# COLLISIONS (AFTER MOVE)
# ============================================================
	for i in range(get_slide_collision_count()):
		var col := get_slide_collision(i)
		var other := col.get_collider()
		var n := col.get_normal()
		n.y = 0.0
		n = n.normalized()

		# --- LIGHT RIGIDBODY COLLISION (cones, crates, barriers) ---
				# --- LIGHT RIGIDBODY COLLISION (cones, crates, barriers) ---
		if other is RigidBody3D:
			# Save speed BEFORE collision
			var pre_speed := velocity.length()

			# Calculate impact force
			var impact: float = clamp(pre_speed, 4.0, 18.0)

			# Push the prop away
			other.apply_impulse(-n * impact * 1.4, col.get_position())

			# Apply tiny directional pushback
			velocity += -n * (impact * 0.05)

			# Restore EXACT speed (100% retention)
			velocity = velocity.normalized() * pre_speed

			# Optional wobble for feel
			velocity = velocity.rotated(Vector3.UP, randf_range(-0.03, 0.03))

			continue

		# --- CAR–CAR COLLISIONS (momentum exchange) ---
		if other is CarController:
			var my_p := mass * velocity
			var their_p: Vector3 = other.mass * other.velocity

			var impulse := (my_p - their_p) * 0.5

			velocity += impulse / mass
			other.velocity -= impulse / other.mass
