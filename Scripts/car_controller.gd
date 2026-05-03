extends CharacterBody3D

@export var stats: CarStats
@export var model_scene: PackedScene

@onready var model_root = $ModelRoot
@onready var wheels = {
	"fl": $Wheels/WheelFL,
	"fr": $Wheels/WheelFR,
	"rl": $Wheels/WheelRL,
	"rr": $Wheels/WheelRR
}

@onready var nos_particles = $Exhaust/ExhaustPoint/GPUParticles3D
@onready var rev_player = $RevPlayer

var speed := 0.0
var steer_angle := 0.0
var velocity_vec := Vector3.ZERO

var nos_amount := 1.0
var nos_active := false

var max_speed := 0.0
var acceleration := 0.0
var handling := 0.0
var traction := 0.0
var brake_strength := 0.0
var weight := 0.0
var nos_power := 0.0
var nos_usage := 0.0
var nos_regen := 0.0

func _ready():
	_load_stats()
	_load_model()
	nos_particles.emitting = false   # invisible by default

func _load_stats():
	max_speed = stats.max_speed
	acceleration = stats.acceleration
	handling = stats.handling
	traction = stats.traction
	brake_strength = stats.brake_strength
	weight = stats.weight

	nos_power = stats.nos_power
	nos_usage = stats.nos_usage
	nos_regen = stats.nos_regen

func free_children(node: Node):
	for child in node.get_children():
		child.queue_free()

func _load_model():
	free_children(model_root)
	var model=model_scene.instantiate()
	model_root.add_child(model)

func _physics_process(delta):
	_handle_input(delta)
	_apply_engine(delta)
	_apply_steering(delta)
	_apply_friction(delta)
	_apply_nos(delta)
	_update_wheels(delta)
	_update_audio(delta)

	velocity = velocity_vec
	move_and_slide()

func _handle_input(delta):
	var throttle = Input.get_action_strength("accelerate")
	var brake = Input.get_action_strength("brake")
	var steer = Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")

	if throttle > 0:
		speed += acceleration * throttle * delta
	elif brake > 0:
		speed -= brake_strength * brake * delta
	else:
		speed = lerp(speed, 0.0, 1.5 * delta)

	speed = clamp(speed, -max_speed * 0.4, max_speed)

	steer_angle = steer * handling

	nos_active = Input.is_action_pressed("nitrous") and nos_amount > 0.0

func _apply_engine(delta):
	var forward = -transform.basis.z
	velocity_vec = forward * speed

func _apply_steering(delta):
	if abs(speed) > 1.0:
		rotate_y(deg_to_rad(steer_angle * delta * 3.0))

func _apply_friction(delta):
	var lateral = transform.basis.x.dot(velocity_vec)
	var forward = transform.basis.z.dot(velocity_vec)

	var new_lateral = lerp(lateral, 0.0, traction * delta)
	velocity_vec = transform.basis.x * new_lateral + transform.basis.z * forward

func _apply_nos(delta):
	if nos_active:
		speed += nos_power * delta
		nos_amount -= nos_usage * delta
		nos_particles.emitting = true
	else:
		nos_amount = min(nos_amount + nos_regen * delta, 1.0)
		nos_particles.emitting = false

func _update_audio(delta):
	var target_pitch = 1.0 + (speed / max_speed) * 1.2

	if nos_active:
		target_pitch = 190.0 / 120.0   # 190 BPM boost (assuming 120 BPM base)

	rev_player.pitch_scale = lerp(rev_player.pitch_scale, target_pitch, delta * 5.0)

func _update_wheels(delta):
	var rot_speed = speed * 0.1

	wheels["fl"].rotate_x(rot_speed * delta)
	wheels["fr"].rotate_x(rot_speed * delta)
	wheels["rl"].rotate_x(rot_speed * delta)
	wheels["rr"].rotate_x(rot_speed * delta)

	wheels["fl"].rotation.y = deg_to_rad(steer_angle)
	wheels["fr"].rotation.y = deg_to_rad(steer_angle)
