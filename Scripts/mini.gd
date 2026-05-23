extends RigidBody3D

# CAR-SPECIFIC STATS (hardcoded)
const ACCEL_FORCE := 20000
const BRAKE_FORCE := 1400.0
const TURN_RATE := 5.7
const MAX_SPEED := 61.1
const TRACTION := 0.92
const DOWNFORCE := 20.0

# FIXED PHYSICS
const FIXED_CENTER_OF_MASS := Vector3(0, -0.2, 0)

@onready var front: Node3D = $ForwardRef

var steer_input := 0.0
var accel_input := 0.0
var brake_input := 0.0


func _ready():
	center_of_mass = FIXED_CENTER_OF_MASS
	angular_damp = 5.0
	linear_damp = 0.1
	sleeping = false
	can_sleep=false


func _physics_process(delta):
	if sleeping:
		set_sleeping(false)
	print("FORWARD = ", _get_forward_dir())
	print("CAR FACING = ", transform.basis.z)
	transform.basis = transform.basis.orthonormalized()
	_get_input()
	_apply_accel()
	_apply_brake()
	_apply_steer()
	_apply_grip()
	_apply_downforce()
	_limit_speed()
	print("LV = ", linear_velocity)


	# Anti-fly bandaids
	if linear_velocity.y > 0:
		linear_velocity.y = min(linear_velocity.y, 2.0)

	angular_velocity.x *= 0.85
	angular_velocity.z *= 0.85

	apply_central_force(Vector3.DOWN * 5)


func _get_input():
	var right = Input.get_action_strength("turn_right")
	var left = Input.get_action_strength("turn_left")
	steer_input = left - right

	accel_input = Input.get_action_strength("accelerate")
	brake_input = Input.get_action_strength("brake")


func _get_forward_dir() -> Vector3:
	var forward = front.global_transform.basis.z
	if forward.length() == 0.0:
		return Vector3.FORWARD
	return forward.normalized()


func _apply_accel():
	if accel_input > 0.0:
		var forward = _get_forward_dir() # THIS IS +Z
		apply_central_force(forward * ACCEL_FORCE * accel_input)
	print("APPLY FORCE: ", _get_forward_dir() * ACCEL_FORCE * accel_input)



func _apply_brake():
	if brake_input > 0.0:
		var backward = -_get_forward_dir()
		apply_central_force(backward * BRAKE_FORCE * brake_input)



func _apply_steer():
	var speed = linear_velocity.length()
	var steer_strength = clamp(speed / 12.0, 0.25, 1.0)
	angular_velocity.y = steer_input * TURN_RATE * steer_strength


func _apply_grip():
	var forward = _get_forward_dir()
	var up = Vector3.UP

	var right = forward.cross(up).normalized()
	up = right.cross(forward).normalized()

	var basis = Basis(right, up, forward)

	var lv = basis.inverse() * linear_velocity

	var vertical = lv.y
	lv.x *= TRACTION
	lv.y = vertical

	linear_velocity = basis * lv


func _apply_downforce():
	apply_central_force(Vector3.DOWN * DOWNFORCE * linear_velocity.length())


func _limit_speed():
	if linear_velocity.length() > MAX_SPEED:
		linear_velocity = linear_velocity.normalized() * MAX_SPEED
