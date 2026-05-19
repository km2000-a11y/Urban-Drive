extends VehicleBody3D

@export var car_name:String
@export var country_of_origin:String
@export var transmission:String
@export var engine:String

@export var top_speed:int
@export var horsepower:int
@export var zero_to_hundred:float
@export var weight:int

@export var max_speed: float
@export var acceleration: int
@export var handling: float
@export var traction:float
@export var brake_strength:float
@export var turn_rate: float
@export var downforce: float

func _physics_process(delta):
	# Ignore the model's internal rotation.
	# Use world -Z as the car's forward direction.
	var forward := Vector3(0, 0, -1)

	# INPUT
	var throttle := Input.get_action_strength("accelerate")
	var braking := Input.get_action_strength("brake")
	var steer_input := Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")

	# ENGINE FORCE
	engine_force = horsepower * 10.0 * throttle

	# BRAKE
	brake = brake_strength * braking

	# STEERING
	steering = steer_input * turn_rate
	
	print("STEERING:", steering)
