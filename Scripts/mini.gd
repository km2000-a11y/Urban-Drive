extends VehicleBody3D

var horsepower := 168
var RPM := 6000
var max_speed := 61.0

var turn_speed := 3.0
var turn_amount := 0.3

var accel_input := 0.0
var brake_input := 0.0

func _physics_process(delta):

	# INPUT
	var accel_raw := Input.get_action_strength("accelerate")
	var brake_raw := Input.get_action_strength("brake")
	var steer_raw := Input.get_action_strength("turn_left") - Input.get_action_strength("turn_right")

	# SMOOTH INPUT
	accel_input = lerp(accel_input, accel_raw, delta * 5.0)
	brake_input = lerp(brake_input, brake_raw, delta * 10.0)

	# STEERING (local, always correct)
	steering = lerp(steering, steer_raw * turn_amount, turn_speed * delta)

	# TORQUE
	var torque = ((horsepower * 5252.0) / max(RPM, 1)) * 20.0

	# ENGINE FORCE (always forward relative to car)
	engine_force = torque * accel_input

	# BRAKE
	brake = brake_input * 80.0

	# SPEED LIMIT
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
