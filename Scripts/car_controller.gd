extends RigidBody3D

@export var max_speed: float
@export var accel_force: float
@export var brake_force: float
@export var turn_rate: float
@export var traction: float
@export var handling: float
@export var downforce: float

var steer_input := 0.0
var accel_input := 0.0
var brake_input := 0.0

func _physics_process(delta):
	_get_input()
	_apply_downforce()
	_apply_acceleration()
	_apply_braking()
	_apply_steering()
	_apply_grip()
	_limit_speed()
	print("Forward:", -transform.basis.z)


func _get_input():
	steer_input = Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")
	accel_input = Input.get_action_strength("accelerate")
	brake_input = Input.get_action_strength("brake")

func _apply_acceleration():
	if accel_input > 0.0:
		var force = -transform.basis.z * accel_force * accel_input
		apply_central_force(force)

func _apply_braking():
	if brake_input > 0.0:
		var force = transform.basis.z * brake_force * brake_input
		apply_central_force(force)

func _apply_steering():
	if linear_velocity.length() > 1.0:
		angular_velocity.y = steer_input * turn_rate * handling
	else:
		angular_velocity.y = 0.0

func _apply_grip():
	linear_velocity.x *= traction
	linear_velocity.z *= 1.0  # forward grip untouched

func _apply_downforce():
	apply_central_force(Vector3.DOWN * downforce)

func _limit_speed():
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
