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

# Smooth input
var accel_input := 0.0
var brake_input := 0.0

func _physics_process(delta):

	# RAW INPUT
	var accel_raw := Input.get_action_strength("accelerate")
	var brake_raw := Input.get_action_strength("brake")
	var steer_raw := Input.get_action_strength("turn_left") - Input.get_action_strength("turn_right")

	# SMOOTH ACCEL + BRAKE
	accel_input = lerp(accel_input, accel_raw, delta * 5.0)
	brake_input = lerp(brake_input, brake_raw, delta * 10.0)

	# STEERING
	steering = lerp(steering, steer_raw * turn_amount, turn_speed * delta)

	# TORQUE FORMULA (your original, kept exactly)
	var torque : float = ((horsepower * 5252.0) / max(RPM, 1)) * 20.0

	# ENGINE FORCE (ONLY forward)
	if accel_input > 0.01:
		engine_force = torque * accel_input
	else:
		engine_force = 0.0

	# BRAKE (separate, strong, does NOT reverse)
	if brake_input > 0.01:
		brake = brake_input * 80.0
	else:
		brake = 0.0

	# SPEED LIMITER
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
		
	print("ACCEL:", accel_raw, " BRAKE:", brake_raw, " STEER:", steer_raw)
