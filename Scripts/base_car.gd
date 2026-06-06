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
var boost := false

# DEBUG
var debug_enabled := true
var debug_timer := 0.0

# ============================================================
#  AUDIO SYSTEM
# ============================================================
var engine_pitch := 1.0
var engine_volume := 1.0
var gear_shift_cooldown := 0.0
var audio_rpm := 900.0

@onready var rev_player := $RevPlayer
@onready var brake_player := $BrakePlayer
@onready var skid_player := $SkidPlayer
@onready var crash_player := $CrashPlayer

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
	acceleration_calc = (27.78 / zero_to_hundred) * 2.0
	torque = (horsepower * 5252.0) / max_rpm
	top_speed = top_speed_kmh / 3.6

# ============================================================
#  READY
# ============================================================
func _ready():
	apply_stats()
	nitro.hide()
	if rev_player:
		rev_player.pitch_scale = 1.0
		rev_player.volume_db = linear_to_db(0.6)
		rev_player.play()

# ============================================================
#  GEAR LOGIC
# ============================================================
func update_gears(speed_kmh):
	if rpm > shift_up_rpm and current_gear < gear_count:
		current_gear += 1
		rpm *= 0.6
		gear_shift_cooldown = 0.12

	if rpm < shift_down_rpm and current_gear > 1:
		current_gear -= 1
		rpm *= 1.3
		gear_shift_cooldown = 0.12

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
	var nitrous := Input.is_action_pressed("nos")

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
	# RPM + GEARS (ENGINE RPM SEPARATED FROM WHEEL RPM)
	# ============================================================
	var speed_kmh := velocity.length() * 3.6

	if speed_kmh < 2.0:
		if accel > 0.1:
			rpm = lerp(rpm, idle_rpm + 2500.0, delta * 2.5)
		else:
			rpm = lerp(rpm, idle_rpm, delta * 3.0)
	else:
		var wheel_rpm :float= speed_kmh * gear_ratios[current_gear - 1] * 35.0
		rpm = lerp(rpm, wheel_rpm, delta * 4.0)

	rpm = clamp(rpm, idle_rpm, max_rpm)

	update_gears(speed_kmh)

	var torque_factor := rpm / max_rpm
	# ============================================================
	# ENGINE SOUND SYSTEM (SMOOTH, REACTIVE, NO POPS)
	# ============================================================

	audio_rpm = lerp(audio_rpm, rpm, delta * 8.0)

	var rpm_ratio = audio_rpm / max_rpm
	var speed_ratio = clamp(speed_kmh / top_speed_kmh, 0.0, 1.0)

		# Base pitch from RPM
	engine_pitch = lerp(0.7, 1.4, rpm_ratio)
	engine_pitch += speed_ratio * 0.1

	# Nitro pitch boost
	if nitrous:
		engine_pitch += 0.08

	# Volume based on throttle
	if accel > 0.1:
		engine_volume = lerp(engine_volume, 0.95, delta * 6.0)
	else:
		engine_volume = lerp(engine_volume, 0.5, delta * 4.0)

	# Idle wobble
	if audio_rpm < idle_rpm + 150.0:
		engine_pitch += randf_range(-0.01, 0.01)

	# Gearshift dip
	if gear_shift_cooldown > 0.0:
		gear_shift_cooldown -= delta
		engine_pitch -= 0.05
		engine_volume = lerp(engine_volume, engine_volume * 0.85, delta * 8.0)

	# ============================================================
	# TRUE IDLE MUTE (NO POPS, NO SILENCE BUGS)
	# ============================================================

	var is_true_idle = false
	if rpm <= idle_rpm + 5.0 and speed_kmh < 1.0:
		is_true_idle = true

	if is_true_idle:
		engine_volume = lerp(engine_volume, 0.0, delta * 8.0)
	else:
		engine_volume = clamp(engine_volume, 0.1, 1.0)

	# Apply audio safely
	if rev_player:
		rev_player.pitch_scale = engine_pitch
		rev_player.volume_db = linear_to_db(max(engine_volume, 0.001))

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
	# NITRO
	# ============================================================
	if nitrous:
		nitro.show()
		var nitro_accel := 1.35
		velocity += forward * accel_force * nitro_accel * delta

		var nitro_top := top_speed * 1.10
		if velocity.length() > nitro_top:
			velocity = velocity.normalized() * nitro_top
	else:
		nitro.hide()

	# ============================================================
	# BRAKING + BRAKE SOUND
	# ============================================================
	if brake > 0.1:
		var brake_force := brake_strength * (mass / 1200.0) * 1.4
		velocity = velocity.move_toward(Vector3.ZERO, brake_force * delta)

		if brake_player and not brake_player.playing:
			brake_player.play()
	else:
		if brake_player and brake_player.playing:
			brake_player.stop()

	# ============================================================
	# DRAG
	# ============================================================
	velocity -= velocity * DRAG * delta

	# ============================================================
	# LATERAL FRICTION + DRIFT + SKID SOUND
	# ============================================================
	var lateral := right.dot(velocity)

	var friction_strength : float = lerp(lateral_friction, 0.25, drift_factor)

	if abs(lateral) > 0.1:
		velocity -= right * lateral * (friction_strength * 0.5) * delta

	if abs(lateral) > 4.0 or drift_factor > 0.25:
		if skid_player and not skid_player.playing:
			skid_player.play()
	else:
		if skid_player and skid_player.playing:
			skid_player.stop()

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

	# SPEED LIMIT
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

	# ============================================================
	# GRAVITY
	# ============================================================
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = -0.01

	# ============================================================
	# COLLISIONS + CRASH SOUND
	# ============================================================
	var old_velocity := velocity
	move_and_slide()

	for i in range(get_slide_collision_count()):
		var col := get_slide_collision(i)
		var other := col.get_collider()

		if col.get_normal().dot(old_velocity) < -2.0:
			if crash_player:
				crash_player.play()

		if other is CarController:
			var my_p := mass * velocity
			var their_p : Vector3 = other.mass * other.velocity

			var impulse := (my_p - their_p) * 0.5

			velocity += impulse / mass
			other.velocity -= impulse / other.mass

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
