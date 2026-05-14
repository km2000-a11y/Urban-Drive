extends VehicleBody3D

@export var car_name: String
@export var engine: String
@export var drivetrain: String
@export var horsepower: int
@export var top_speed: float
@export var zero_to_hundred: float
@export var weight: float

@export var max_speed: float
@export var acceleration: float
@export var handling: float
@export var traction: float
@export var brake_strength: float

@export var country_of_origin: String = ""
@export var downforce: float = 1.0

# Steering parameters
# Steering parameters
@export var max_steer_angle: float = 0.8
@export var steering_speed: float = 2.5

var steer_target := 0.0

@onready var FL := $FL
@onready var FR := $FR
@onready var RL := $RL
@onready var RR := $RR

func _physics_process(delta):
	# INPUT
	var throttle := Input.get_action_strength("accelerate") - Input.get_action_strength("brake")
	var steer_input := Input.get_action_strength("turn_left") - Input.get_action_strength("turn_right")

	# STEERING (THIS ALWAYS WORKS)
	steer_target = steer_input * max_steer_angle
	steering = lerp(steering, steer_target, steering_speed * delta)

	# RESET ENGINE FORCE
	FL.engine_force = 0
	FR.engine_force = 0
	RL.engine_force = 0
	RR.engine_force = 0

	# DRIVETRAIN
	if drivetrain == "FWD":
		FL.engine_force = throttle * acceleration
		FR.engine_force = throttle * acceleration
	elif drivetrain == "RWD":
		RL.engine_force = throttle * acceleration
		RR.engine_force = throttle * acceleration
	else: # AWD
		FL.engine_force = throttle * acceleration * 0.5
		FR.engine_force = throttle * acceleration * 0.5
		RL.engine_force = throttle * acceleration * 0.5
		RR.engine_force = throttle * acceleration * 0.5

	# BRAKING
	var braking := brake_strength if throttle < 0 else 0.0
	FL.brake = braking
	FR.brake = braking
	RL.brake = braking
	RR.brake = braking
