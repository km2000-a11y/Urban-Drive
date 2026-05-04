extends VehicleBody3D

@export var stats: CarStats
@export var car_model_scene: PackedScene

var car_model: Node3D

# Wheel references
@onready var w_fl = $VehicleWheelFL
@onready var w_fr = $VehicleWheelFR
@onready var w_rl = $VehicleWheelRL
@onready var w_rr = $VehicleWheelRR

func _ready():
	load_car_model()
	apply_stats()

# ---------------------------------------------------------
#  LOAD MODEL + STATS
# ---------------------------------------------------------
func load_car_model():
	if car_model:
		car_model.queue_free()

	car_model = car_model_scene.instantiate()
	$ModelRoot.add_child(car_model)

	align_wheels_to_model()

func apply_stats():
	mass = stats.weight

	# traction affects friction_slip
	w_fl.friction_slip = stats.traction
	w_fr.friction_slip = stats.traction
	w_rl.friction_slip = stats.traction
	w_rr.friction_slip = stats.traction

# ---------------------------------------------------------
#  PHYSICS LOOP
# ---------------------------------------------------------
func _physics_process(delta):
	handle_input(delta)
	update_visual_wheels(delta)

# ---------------------------------------------------------
#  INPUT HANDLING
# ---------------------------------------------------------
func handle_input(delta):
	var throttle = Input.get_action_strength("accelerate")
	var brake = Input.get_action_strength("brake")
	var steer = Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")

	# Steering
	var steer_angle = deg_to_rad(stats.handling)
	w_fl.steering = steer * steer_angle
	w_fr.steering = steer * steer_angle

	# Max speed limiter
	if linear_velocity.length() > stats.max_speed:
		throttle = 0.0

	# Acceleration force
	var accel_force = throttle * stats.acceleration * 120.0

	# Drivetrain distribution
	match stats.drivetrain:
		"FWD":
			w_fl.engine_force = accel_force
			w_fr.engine_force = accel_force
			w_rl.engine_force = 0
			w_rr.engine_force = 0

		"RWD":
			w_fl.engine_force = 0
			w_fr.engine_force = 0
			w_rl.engine_force = accel_force
			w_rr.engine_force = accel_force

		"AWD":
			w_fl.engine_force = accel_force * 0.5
			w_fr.engine_force = accel_force * 0.5
			w_rl.engine_force = accel_force * 0.5
			w_rr.engine_force = accel_force * 0.5

	# Braking
	var brake_force = brake * stats.brake_strength * 100.0
	w_fl.brake = brake_force
	w_fr.brake = brake_force
	w_rl.brake = brake_force
	w_rr.brake = brake_force

# ---------------------------------------------------------
#  WHEEL ALIGNMENT
# ---------------------------------------------------------
func align_wheels_to_model():
	var m = car_model

	w_fl.global_transform = m.get_node("WheelFL_Pos").global_transform
	w_fr.global_transform = m.get_node("WheelFR_Pos").global_transform
	w_rl.global_transform = m.get_node("WheelRL_Pos").global_transform
	w_rr.global_transform = m.get_node("WheelRR_Pos").global_transform

# ---------------------------------------------------------
#  VISUAL WHEEL SYNC
# ---------------------------------------------------------
func update_visual_wheels(delta):
	var m = car_model

	m.get_node("WheelFL_Mesh").global_transform = w_fl.global_transform
	m.get_node("WheelFR_Mesh").global_transform = w_fr.global_transform
	m.get_node("WheelRL_Mesh").global_transform = w_rl.global_transform
	m.get_node("WheelRR_Mesh").global_transform = w_rr.global_transform
