extends RigidBody3D

const ACCEL := 15000.0
const TURN := 2.5
const MAX_SPEED := 40.0

func _physics_process(delta):
	var forward = -transform.basis.z.normalized()

	# Accelerate
	if Input.is_action_pressed("accelerate"):
		apply_central_force(forward * ACCEL)

	# Brake / reverse
	if Input.is_action_pressed("brake"):
		apply_central_force(-forward * ACCEL)

	# Steering
	if Input.is_action_pressed("turn_left"):
		rotation.y += TURN * delta
	if Input.is_action_pressed("turn_right"):
		rotation.y -= TURN * delta

	# Speed limit
	if linear_velocity.length() > MAX_SPEED:
		linear_velocity = linear_velocity.normalized() * MAX_SPEED
