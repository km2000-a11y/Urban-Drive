extends VehicleBody3D

# MINI COOPER S CABRIO '05
var car_name := "Comet Spryte S"
var horsepower := 168
var country := "UK"
var engine := "1.6L I4 Supercharged"
var zero_to_hundred := 7.2
var top_speed := 220
var RPM := 6000
var max_speed := 61.0
var weight := 1290
var drivetrain := "FWD"

var turn_speed := 3.0
var turn_amount := 0.3

func _physics_process(delta):

	var throttle := Input.get_action_strength("accelerate") - Input.get_action_strength("brake")
	var steer_input := Input.get_action_strength("turn_left") - Input.get_action_strength("turn_right")

	# Steering
	steering = lerp(steering, steer_input * turn_amount, turn_speed * delta)

	# Torque
	var torque:float= (horsepower * 5252.0) / max(RPM, 1)

	# ENGINE FORCE (the magic line)
	engine_force = torque * throttle

	# Braking
	if throttle < 0:
		brake = abs(throttle) * 50.0
	else:
		brake = 0.0

	# Speed limiter
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
