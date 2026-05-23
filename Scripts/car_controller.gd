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

func _ready():
	rotation_degrees = Vector3(0, 0, 0)

func _physics_process(delta):
	_get_input()
	_apply_downforce()
	_apply_acceleration()
	_apply_braking()
	_apply_steering()
	_apply_grip()
	_apply_stabilizer()
	_limit_speed()
	print(accel_input, brake_input, steer_input)
	print("Forward:", -transform.basis.z)


func _get_input():
	steer_input = Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")
	accel_input = Input.get_action_strength("accelerate")
	brake_input = Input.get_action_strength("brake")


func _apply_acceleration():
	if accel_input > 0.0:
		var force := -transform.basis.z * accel_force * accel_input

		# Apply force EXACTLY at the center → no roll, no tipping
		apply_central_force(force)
		print("ACCEL:", accel_input, " FORCE:", -transform.basis.z * accel_force * accel_input)


func _apply_braking():
	if brake_input > 0.0:
		var force = transform.basis.z * brake_force * brake_input
		apply_central_force(force)

func _apply_steering():
	var speed = linear_velocity.length()

	# Strong steering at low speed, stable at high speed
	var speed_factor = clamp(speed / 10.0, 0.3, 1.0)

	angular_velocity.y = steer_input * turn_rate * handling * speed_factor


func _apply_grip():
	var lv = transform.basis.inverse() * linear_velocity
	lv.x *= traction
	linear_velocity = transform.basis * lv

func _apply_stabilizer():
	var lv = transform.basis.inverse() * linear_velocity
	lv.x *= 0.98
	linear_velocity = transform.basis * lv

func _apply_downforce():
	var force = Vector3.DOWN * downforce
	apply_central_force(Vector3.DOWN * downforce)

func _limit_speed():
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
