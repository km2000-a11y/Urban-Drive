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
@export var max_steer_angle: float = 0.8
@export var steering_speed: float = 2.5

var steer_target := 0.0

func _physics_process(delta):
	var throttle := Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	var steer_input := Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")

	engine_force = throttle * acceleration * 1800.0
	brake = brake_strength if throttle < 0 else 0.0

	steer_target = steer_input * max_steer_angle
	steering = lerp(steering, steer_target, steering_speed * delta)
