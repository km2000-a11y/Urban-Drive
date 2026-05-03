extends VehicleBody3D

@export var stats: CarStats
@export var model_scene: PackedScene

@onready var model_root = $ModelRoot
@onready var nos_particles = $Exhaust/ExhaustPoint/GPUParticles3D
@onready var rev_player = $RevPlayer

# VehicleBody3D handles wheels via its children, but we'll reference them for specific logic if needed
@onready var wheels = {
	"fl": $Wheels/WheelFL,
	"fr": $Wheels/WheelFR,
	"rl": $Wheels/WheelRL,
	"rr": $Wheels/WheelRR
}

var nos_amount := 1.0
var nos_active := false

# Mapped Stats
var max_speed_kph := 0.0
var engine_power := 0.0
var steer_limit := 0.0
var brake_power := 0.0
var nos_force := 0.0
var nos_usage := 0.0
var nos_regen := 0.0

func _ready():
	_load_stats()
	_load_model()
	nos_particles.emitting = false

func _load_stats():
	mass = stats.weight
	max_speed_kph = stats.max_speed
	engine_power = stats.acceleration * 100.0
	steer_limit = deg_to_rad(stats.handling * 15.0)
	brake_power = stats.brake_strength * 10.0
	
	nos_force = stats.nos_power * 50.0
	nos_usage = stats.nos_usage
	nos_regen = stats.nos_regen

func _load_model():
	for child in model_root.get_children():
		child.queue_free()
	var model = model_scene.instantiate()
	model_root.add_child(model)

func _physics_process(delta):
	var current_speed = linear_velocity.length() * 3.6
	
	_handle_input(current_speed)
	_apply_nos(delta)
	_update_audio(current_speed, delta)

func _handle_input(current_speed):
	var throttle = Input.get_action_strength("accelerate")
	var brake_input = Input.get_action_strength("brake")
	var steer_input = Input.get_action_strength("turn_left") - Input.get_action_strength("turn_right")

	# Steering
	steering = steer_input * steer_limit

	# Acceleration
	if current_speed < max_speed_kph:
		engine_force = throttle * engine_power
	else:
		engine_force = 0.0

	# Braking
	brake = brake_input * brake_power

func _apply_nos(delta):
	nos_active = Input.is_action_pressed("nitrous") and nos_amount > 0.0
	
	if nos_active:
		apply_central_force(-global_transform.basis.z * nos_force)
		nos_amount -= nos_usage * delta
		nos_particles.emitting = true
	else:
		nos_amount = min(nos_amount + nos_regen * delta, 1.0)
		nos_particles.emitting = false

func _update_audio(current_speed, delta):
	var target_pitch = 1.0 + (current_speed / max_speed_kph) * 1.2
	if nos_active:
		target_pitch += 0.5
	rev_player.pitch_scale = lerp(rev_player.pitch_scale, target_pitch, delta * 5.0)
