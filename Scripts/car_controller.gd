extends CharacterBody3D

@export var stats: CarStats

# Nodes
@onready var model_root = $ModelRoot
@onready var wheel_fl = $Wheels/FL
@onready var wheel_fr = $Wheels/FR
@onready var wheel_rl = $Wheels/RL
@onready var wheel_rr = $Wheels/RR

@onready var s_engine = $Audio/Engine
@onready var s_skid = $Audio/Skid
@onready var s_brake = $Audio/Brake
@onready var s_crash = $Audio/Crash

# Physics
var speed := 0.0
var steer_angle := 0.0
var velocity_vec := Vector3.ZERO

# NOS
var nos_amount := 1.0
var nos_active := false

func _physics_process(delta):
	_handle_input(delta)
	_apply_engine(delta)
	_apply_steering(delta)
	_apply_friction(delta)
	_apply_nos(delta)
	_update_audio()
	_update_wheels(delta)

	velocity = velocity_vec
	move_and_slide()

	if get_slide_collision_count() > 0:
		s_crash.play()

# ---------------------------------------------------------
# INPUT
# ---------------------------------------------------------
func _handle_input(delta):
	var throttle = Input.get_action_strength("accelerate")
	var brake = Input.get_action_strength("brake")
	var steer = Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")

	# Acceleration
	if throttle > 0:
		speed += stats.acceleration * throttle * delta
	elif brake > 0:
		speed -= stats.brake_force * brake * delta
	else:
		speed = lerp(speed, 0.0, stats.coast_drag * delta)

	speed = clamp(speed, -stats.reverse_speed, stats.max_speed)

	# Steering
	steer_angle = steer * stats.steer_angle

	# NOS
	nos_active = Input.is_action_pressed("nitrous") and nos_amount > 0

# ---------------------------------------------------------
# ENGINE + MOVEMENT
# ---------------------------------------------------------
func _apply_engine(delta):
	var forward = -transform.basis.z
	velocity_vec = forward * speed

# ---------------------------------------------------------
# STEERING
# ---------------------------------------------------------
func _apply_steering(delta):
	if abs(speed) > 1.0:
		rotate_y(deg_to_rad(steer_angle * delta * stats.steer_speed))

# ---------------------------------------------------------
# FRICTION + DRIFT
# ---------------------------------------------------------
func _apply_friction(delta):
	var lateral = transform.basis.x.dot(velocity_vec)
	var forward = transform.basis.z.dot(velocity_vec)

	# Drift factor
	var drift_factor = stats.drift_grip if Input.is_action_pressed("drift") else stats.normal_grip

	var new_lateral = lerp(lateral, 0.0, drift_factor * delta)
	velocity_vec = transform.basis.x * new_lateral + transform.basis.z * forward

	# Skid sound
	if abs(new_lateral) > stats.skid_threshold:
		if not s_skid.playing:
			s_skid.play()
	else:
		s_skid.stop()

# ---------------------------------------------------------
# NOS BOOST
# ---------------------------------------------------------
func _apply_nos(delta):
	if nos_active:
		speed += stats.nos_power * delta
		nos_amount -= stats.nos_usage * delta
	else:
		nos_amount = min(nos_amount + stats.nos_regen * delta, 1.0)

# ---------------------------------------------------------
# AUDIO
# ---------------------------------------------------------
func _update_audio():
	s_engine.pitch_scale = 1.0 + (speed / stats.max_speed) * 1.2

# ---------------------------------------------------------
# WHEEL VISUALS
# ---------------------------------------------------------
func _update_wheels(delta):
	var rot_speed = speed * 0.1

	wheel_fl.rotate_x(rot_speed * delta)
	wheel_fr.rotate_x(rot_speed * delta)
	wheel_rl.rotate_x(rot_speed * delta)
	wheel_rr.rotate_x(rot_speed * delta)

	wheel_fl.rotation.y = deg_to_rad(steer_angle)
	wheel_fr.rotation.y = deg_to_rad(steer_angle)
