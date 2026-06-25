class_name CarController
extends CharacterBody3D

const GRAVITY := 30.0
const ENGINE_BRAKE := 0.5
const DRAG := 0.1

var driver_name := "Player"

var mass := 1200.0
var zero_to_hundred := 7.0
var top_speed_kmh := 200.0
var top_speed := 60.0
var turn_speed := 2.5
var brake_strength := 20.0
var lateral_friction := 1.2
var transmission := "Front-wheel drive"

var is_diesel := false

var horsepower := 150.0
var max_rpm := 6500.0
var idle_rpm := 900.0
var rpm := 900.0
var torque := 0.0

var gear_count := 6
var gear_ratios := [3.5, 2.1, 1.5, 1.2, 1.0, 0.82]
var current_gear := 1
var shift_up_rpm := 6200
var shift_down_rpm := 2000

var acceleration_calc := 0.0
var steering := 0.0
var old_rotation_y := 0.0

var drifting := false
var drift_factor := 0.0
var boost := false
var nitro_top_speed_multiplier:=1.12

var performance_points := 0
var debug_enabled := true
var handling_type := "balanced"

var controls_enabled: bool = true

@export var spawn_yaw_deg: float = 0.0

@onready var car_model := $ModelRoot
@onready var forward_ref := $ForwardRef
@onready var nitro := $Exhaust/GPUParticles3D

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

func _ready():
	apply_stats()
	apply_handling_profile()
	nitro.hide()

func update_gears(speed_kmh: float) -> void:
	if rpm > shift_up_rpm and current_gear < gear_count:
		current_gear += 1
		rpm *= 0.6

	if rpm < shift_down_rpm and current_gear > 1:
		current_gear -= 1
		rpm *= 1.3

	current_gear = clamp(current_gear, 1, gear_count)

func _physics_process(delta: float) -> void:
	if not controls_enabled:
		if not is_on_floor():
			velocity.y -= GRAVITY * delta
		move_and_slide()
		return

	var accel := Input.get_action_strength("accelerate")
	var brake := Input.get_action_strength("brake")
	var steer := Input.get_action_strength("turn_left") - Input.get_action_strength("turn_right")

	_drive(delta, accel, brake, steer)

func _drive(delta: float, accel: float, brake: float, steer: float) -> void:
	var drift_input := false
	if driver_name == "Player":
		if Input.is_action_pressed("drift"):
			drift_input = true

	var nitrous := false
	if driver_name == "Player":
		if Input.is_action_pressed("nos"):
			nitrous = true

	var target_drift := 0.0
	if drift_input:
		target_drift = 1.0

	drift_factor = lerp(drift_factor, target_drift, delta * 6.0)
	drifting = drift_factor > 0.1

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
		var impact_strength :float= clamp(speed_kmh / 120.0, 0.2, 1.0)
		velocity *= (1.0 - impact_strength * 0.55)
		velocity -= forward * (impact_strength * 4.0)

	if wall_scrape:
		var scrape_strength :float= clamp(speed_kmh / 220.0, 0.05, 0.25)
		velocity -= right * (scrape_strength * 6.0)
		velocity *= (1.0 - scrape_strength * 0.15)

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

	var traction_factor := 1.0
	var throttle_steer := 0.0
	var launch_grip := 1.0

	if transmission == "Front-wheel drive":
		traction_factor = 0.90
		throttle_steer = -steering * 0.35
		launch_grip = 1.15
	elif transmission == "Rear-wheel drive":
		traction_factor = 1.05
		throttle_steer = steering * 0.55
		launch_grip = 0.85
	elif transmission == "Four-wheel drive":
		traction_factor = 1.20
		throttle_steer = steering * 0.25
		launch_grip = 1.35

	var accel_force := 0.0

	if accel > 0.0:
		var launch_boost := 1.0
		if current_gear == 1:
			launch_boost = 1.4

		accel_force = acceleration_calc * torque_factor * traction_factor * launch_boost * launch_grip
		velocity += forward * accel_force * delta
		velocity = velocity.rotated(Vector3.UP, throttle_steer * delta)
	else:
		var flat := Vector3(velocity.x, 0, velocity.z)
		var brake_power := ENGINE_BRAKE
		if drifting:
			brake_power = ENGINE_BRAKE * 0.05
		flat = flat.move_toward(Vector3.ZERO, brake_power * delta)
		velocity.x = flat.x
		velocity.z = flat.z

	if nitrous:
		nitro.show()
		velocity += forward * accel_force * 1.35 * delta
	else:
		nitro.hide()

	if brake > 0.1:
		var brake_force := brake_strength * (mass / 1200.0) * 1.4
		velocity = velocity.move_toward(Vector3.ZERO, brake_force * delta)

	velocity -= velocity * DRAG * delta

	var flat2 := Vector3(velocity.x, 0, velocity.z)
	var current_top_speed := top_speed
	if nitrous:
		current_top_speed = top_speed * nitro_top_speed_multiplier
	if flat2.length() > current_top_speed:
		flat2 = flat2.normalized() * current_top_speed

	velocity.x = flat2.x
	velocity.z = flat2.z

	Global.speed = speed_kmh
	Global.gear = current_gear

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = -0.01

	move_and_slide()

	for i in range(get_slide_collision_count()):
		var col2 := get_slide_collision(i)
		var other2 := col2.get_collider()
		var n2 := col2.get_normal()
		n2.y = 0.0
		n2 = n2.normalized()

		if other2 is RigidBody3D:
			var pre_speed := velocity.length()
			var impact :float= clamp(pre_speed, 4.0, 18.0)
			other2.apply_impulse(-n2 * impact * 1.4, col2.get_position())
			velocity += -n2 * (impact * 0.05)
			velocity = velocity.normalized() * pre_speed
			velocity = velocity.rotated(Vector3.UP, randf_range(-0.03, 0.03))
			continue

		if other2 is CarController:
			var my_p := mass * velocity
			var their_p :Vector3= other2.mass * other2.velocity
			var impulse := (my_p - their_p) * 0.5
			velocity += impulse / mass
			other2.velocity -= impulse / other2.mass
