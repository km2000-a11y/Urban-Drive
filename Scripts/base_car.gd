class_name CarController
extends CharacterBody3D

const GRAVITY := 30.0
const ENGINE_BRAKE := 0.5
const DRAG := 0.1
const HARD_LIMIT_KMH := 400.0
const HARD_LIMIT := HARD_LIMIT_KMH / 3.6

# --- ROLE FLAGS ---
var is_ai: bool = false
var waypoint_root: Node3D = null
var waypoints: Array[Node] = []
var current_wp: int = 0
var seam_wiggle_timer := 0.0
var seam_wiggle_phase := 0


# --- AI INPUT ---
var ai_throttle: float = 0.0
var ai_brake: float = 0.0
var ai_steer: float = 0.0
var ai_names := [
	"David", "Takashi", "Ricco", "Chris", "Petar", "Nina",
	"Steve", "Linus", "Chris", "Jesse", "Dimitri", "Mirko",
	"Abdullah", "Will", "Jimmy M.", "Tiffany", "Hoff", "Jake"
]

# --- PLAYER INPUT ---
var throttle_input: float = 0.0
var brake_input: float = 0.0
var steer_input: float = 0.0

# --- CAR STATS ---
var mass := 1200.0
var zero_to_hundred := 7.0
var top_speed_kmh := 200.0
var top_speed := 60.0
var turn_speed := 2.5
var brake_strength := 20.0
var lateral_friction := 1.2
var driver_name: String = "Unknown"

# Use consistent transmission strings
var transmission := "Front wheel drive" # "Front wheel drive", "Rear wheel drive", "Four wheel drive"

var is_diesel := false

var horsepower := 150.0
var max_rpm := 6500.0
var idle_rpm := 900.0
var rpm := 900.0
var torque := 0.0

var gear_count := 6
var gear_ratios := [3.5, 2.1, 1.5, 1.2, 1.0, 0.82]
var current_speed: float = 0.0
var current_gear := 1
var shift_up_rpm := 6200
var shift_down_rpm := 2000

var acceleration_calc := 0.0
var steering := 0.0

var drifting := false
var drift_factor := 0.0
var boost := false
var nitro_top_speed_multiplier := 1.12

var performance_points := 0
var debug_enabled := true
var handling_type := "balanced"

var controls_enabled: bool = true

@export var spawn_yaw_deg: float = 0.0

@onready var car_model := $ModelRoot
@onready var forward_ref := $ForwardRef
@onready var nitro := $Exhaust/GPUParticles3D

# --- OVERTAKING ---
var ai_overtake_offset: float = 0.0
var ai_overtake_side: float = 0.0 # -1 left, +1 right

func apply_stats() -> void:
	acceleration_calc = (27.78 / zero_to_hundred) * 2.0
	torque = (horsepower * 5252.0) / max_rpm

	if is_diesel:
		torque *= 1.6

	top_speed = top_speed_kmh / 3.6

	performance_points = round(
		(top_speed_kmh * 1.5)
		+ (100.0 / zero_to_hundred)
		+ ((horsepower / mass) * 700.0)
	)

func apply_handling_profile() -> void:
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

func _ready() -> void:
	apply_stats()
	apply_handling_profile()
	nitro.hide()

	if is_ai:
		driver_name = ai_names[randi() % ai_names.size()]
	else:
		driver_name = "Player"



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
		velocity.y = -0.01
		return

	if is_ai:
		_update_ai_inputs(delta)
		throttle_input = ai_throttle
		brake_input = ai_brake
		steer_input = ai_steer
	else:
		throttle_input = Input.get_action_strength("accelerate")
		brake_input = Input.get_action_strength("brake")
		steer_input = Input.get_action_strength("turn_left") - Input.get_action_strength("turn_right")

	_drive(delta, throttle_input, brake_input, steer_input)


func _drive(delta: float, accel: float, brake: float, steer: float) -> void:
	var drift_input := false
	var nitrous := false

	if not is_ai:
		if Input.is_action_pressed("drift"):
			drift_input = true
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
	
	var forward_speed:=velocity.dot(forward)
	var sideways_speed:=velocity.dot(right)
	
	sideways_speed=lerp(sideways_speed, 0.0, delta*8)
	

	var speed := velocity.length()
	var speed_kmh := speed * 3.6

	# --- CAR ORIENTATION ---
	if not drifting:
		rotation.y += steering * turn_speed * delta
		lateral_friction = 1.2
	else:
		var drift_steer := steering * (turn_speed * 0.35)
		rotation.y += drift_steer * delta
		var slip_strength := 2.0 * drift_factor
		velocity = velocity.rotated(Vector3.UP, -steering * slip_strength * delta)
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

		# --- RIGIDBODY PROP PUSH (always handled first) ---
		if other is RigidBody3D:
			var n := col.get_normal()
			n.y = 0.0
			n = n.normalized()

			var push_force :float= clamp(velocity.length() * 0.25, 4.0, 18.0)
			other.apply_impulse(-n * push_force, col.get_position())
			continue


		# --- NORMAL CALC ---
		var n := col.get_normal()
		n.y = 0.0
		n = n.normalized()

		# --- SEAM IGNORE LOGIC ---
		# Ignore tiny normals (micro seams)
		if n.length() < 0.2:
			continue

		var side_dot := right.dot(n)
		var front_dot := forward.dot(n)

		# Ignore normals that are not real walls (soft angled normals)
		if abs(side_dot) < 0.25 and front_dot > -0.3:
			continue


		# --- REAL WALL DETECTION ---
		if forward.dot(n) < -0.85:
			wall_block = true

		if abs(right.dot(n)) > 0.55:
			wall_scrape = true

	if wall_block:
		var impact_strength: float = clamp(speed_kmh / 120.0, 0.2, 1.0)
		velocity *= (1.0 - impact_strength * 0.55)
		velocity -= forward * (impact_strength * 4.0)

	if wall_scrape:
		var scrape_strength: float = clamp(speed_kmh / 220.0, 0.05, 0.25)
		velocity += -right * (scrape_strength * 6.0)
		velocity *= (1.0 - scrape_strength * 0.15)

	# --- RPM & GEARS ---
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

	# --- DRIVETRAIN ---
	var traction_factor := 1.0
	var throttle_steer := 0.0
	var launch_grip := 1.0

	if transmission == "Front wheel drive":
		traction_factor = 1.05
		throttle_steer = steering * 0.08
		launch_grip = 1.0
	elif transmission == "Rear wheel drive":
		traction_factor = 1.0
		throttle_steer = steering * 0.2
		launch_grip = 0.9
	elif transmission == "Four wheel drive":
		traction_factor = 1.15
		throttle_steer = steering * 0.10
		launch_grip = 1.2

	var accel_force := 0.0

	if accel > 0.0:
		var launch_boost := 1.0
		if current_gear == 1:
			launch_boost = 1.25

		accel_force = acceleration_calc * torque_factor * traction_factor * launch_boost * launch_grip
		velocity += forward * accel_force * delta

		# torque-steer only, no extra steering rotation
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

	if not is_ai and controls_enabled:
		Global.speed = speed_kmh
		Global.gear = current_gear

	current_speed = speed_kmh

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = -0.01

	var flat_safe := Vector3(velocity.x, 0, velocity.z)
	if flat_safe.length() > HARD_LIMIT:
		flat_safe = flat_safe.normalized() * HARD_LIMIT
		velocity.x = flat_safe.x
		velocity.z = flat_safe.z

	velocity.y = clamp(velocity.y, -HARD_LIMIT, HARD_LIMIT)

	move_and_slide()

	for i in range(get_slide_collision_count()):
		var col := get_slide_collision(i)
		var other := col.get_collider()
		var n := col.get_normal()
		n.y = 0.0
		n = n.normalized()

		# --- Ignore tiny normals (micro seams) ---
		if n.length() < 0.2:
			continue

		# --- Ignore soft angled normals (seams) ---
		var side_dot := transform.basis.x.normalized().dot(n)
		var front_dot := (-transform.basis.z).normalized().dot(n)

		if abs(side_dot) < 0.25 and front_dot > -0.3:
			continue

		# --- RIGIDBODY COLLISION HANDLING ---
		if other is RigidBody3D:
			var push_force :float = clamp(velocity.length() * 0.25, 4.0, 18.0)
			other.apply_impulse(-n * push_force, col.get_position())

			# Ignore collision for the car
			velocity.y = 0.0
			velocity = Vector3(velocity.x, 0, velocity.z)

			continue



func set_waypoints(root: Node3D) -> void:
	waypoint_root = root
	waypoints = root.get_children()
	waypoints.sort_custom(_ai_sort_wp)
	current_wp = 0


func _ai_sort_wp(a: Node, b: Node) -> bool:
	var na_str := a.name.strip_edges().to_upper()
	var nb_str := b.name.strip_edges().to_upper()

	if na_str.begins_with("WP"):
		na_str = na_str.substr(2)
	if nb_str.begins_with("WP"):
		nb_str = nb_str.substr(2)

	var na := int(na_str) if na_str.is_valid_int() else 99999
	var nb := int(nb_str) if nb_str.is_valid_int() else 99999

	return na < nb

func _update_ai_inputs(delta: float) -> void:
	if waypoints.is_empty():
		ai_throttle = 0.0
		ai_brake = 1.0
		ai_steer = 0.0
		return

	var wp := waypoints[current_wp] as Node3D

	# --- BASIC LOOKAHEAD ---
	var wp_forward := -wp.transform.basis.z
	wp_forward.y = 0.0
	wp_forward = wp_forward.normalized()
	var target := wp.global_position + wp_forward * 8.0

	var to_wp := target - global_position
	to_wp.y = 0.0

	var dist := to_wp.length()
	if dist < 3.0:
		current_wp = (current_wp + 1) % waypoints.size()
		return

	var dir := to_wp.normalized()

	var forward := -transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	# --- AI SEAM IGNORE LOGIC ---
	var seam_hit := false

	for i in range(get_slide_collision_count()):
		var col := get_slide_collision(i)
		var n := col.get_normal()
		n.y = 0.0
		n = n.normalized()

		# Ignore tiny normals (micro seams)
		if n.length() < 0.2:
			seam_hit = true
			continue

		# Ignore soft angled normals (seams)
		var side_dot := transform.basis.x.normalized().dot(n)
		var front_dot := forward.dot(n)

		if abs(side_dot) < 0.25 and front_dot > -0.3:
			seam_hit = true
			continue


	# --- SIMPLE STEERING ---
	var angle := forward.signed_angle_to(dir, Vector3.UP)
	ai_steer = clamp(angle * 2.0, -1.0, 1.0)

	# --- ALWAYS THROTTLE ---
	ai_throttle = 1.0

	# --- LIGHT BRAKE ONLY ON SHARP TURNS ---
	if abs(angle) > 0.6:
		ai_brake = 0.3
	else:
		ai_brake = 0.0
		
	
		
	print("WP:", current_wp, " angle:", angle, " dist:", dist)


func _find_nearest_car() -> CarController:
	var nearest: CarController = null
	var best_dist := 99999.0

	for body in get_tree().get_nodes_in_group("cars"):
		if body == self:
			continue
		if not (body is CarController):
			continue

		var cc := body as CarController
		var d := cc.global_position.distance_to(global_position)
		if d < best_dist:
			best_dist = d
			nearest = cc

	return nearest
	
	
