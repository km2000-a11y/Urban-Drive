extends RigidBody3D

@export var stats: CarStats
@export var car_model_scene: PackedScene

var car_model: Node3D

# ---------------------------------------------------------
#  RUNTIME CAR DATABASES
# ---------------------------------------------------------
var car_models := {
	"abarth_500": preload("res://Cars/abarth_500.tscn"),
}

var car_stats := {
	"abarth_500": preload("res://Car Stats/abarth_500.tres"),
}

var car_list := [
	"abarth_500","golf","mini","beetle","tt","350z","slk","rs5",
	"charger","mustang","1967_shelby","cls","v8_vantage","granturismo",
	"db9","hummer","expedition","elise","corvette","gallardo","diablo",
	"murcielago","zonda","f1","ccxr"
]

# ---------------------------------------------------------
#  INTERNAL STATE
# ---------------------------------------------------------
var steer_angle := 0.0

func _ready():
	can_sleep = false
	sleeping = false
	switch_car(car_list[0])

# ---------------------------------------------------------
#  LOAD CAR MODEL
# ---------------------------------------------------------
func load_car_model():
	if car_model:
		car_model.queue_free()

	car_model = car_model_scene.instantiate()
	$ModelRoot.add_child(car_model)

# ---------------------------------------------------------
#  APPLY CAR STATS
# ---------------------------------------------------------
func apply_stats():
	if stats == null:
		return
	mass = stats.weight

# ---------------------------------------------------------
#  PHYSICS LOOP
# ---------------------------------------------------------
func _physics_process(delta):
	handle_input(delta)
	update_visual_wheels()

# ---------------------------------------------------------
#  INPUT HANDLING (REALISTIC ARCADE PHYSICS)
# ---------------------------------------------------------
func handle_input(delta):
	if stats == null:
		return

	var throttle := Input.get_action_strength("accelerate")
	var brake := Input.get_action_strength("brake")
	var steer_input := Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")

	# -----------------------------------------------------
	# STEERING (torque-based, stable)
	# -----------------------------------------------------
	var max_steer := deg_to_rad(stats.handling * 2.0)
	steer_angle = lerp(steer_angle, steer_input * max_steer, delta * 6.0)

	var steer_torque := Vector3.UP * steer_angle * clamp(linear_velocity.length(), 0.0, 30.0) * 0.03
	apply_torque_impulse(steer_torque)

	# -----------------------------------------------------
	# FORWARD ACCELERATION (realistic torque curve)
	# -----------------------------------------------------
	var speed := linear_velocity.length()
	if speed < stats.max_speed:
		var forward := -global_transform.basis.z
		var accel_force := throttle * stats.acceleration * 250000.0
		apply_central_force(forward * accel_force)

	# -----------------------------------------------------
	# BRAKING
	# -----------------------------------------------------
	if brake > 0.1:
		var brake_force := -linear_velocity * stats.brake_strength * 8.0
		apply_central_force(brake_force)

	# -----------------------------------------------------
	# LATERAL FRICTION (NO VELOCITY OVERWRITE)
	# -----------------------------------------------------
	var lateral := global_transform.basis.x.dot(linear_velocity)
	var lateral_force := -global_transform.basis.x * lateral * stats.traction * 40.0
	apply_central_force(lateral_force)

	# -----------------------------------------------------
	# NATURAL DRAG
	# -----------------------------------------------------
	var drag := -linear_velocity * 0.15
	apply_central_force(drag)

# ---------------------------------------------------------
#  VISUAL WHEEL SYNC
# ---------------------------------------------------------
func update_visual_wheels():
	if not car_model:
		return

	var m := car_model
	var rot_speed := linear_velocity.length() * 0.05

	for wheel_name in ["WheelFL_Mesh","WheelFR_Mesh","WheelRL_Mesh","WheelRR_Mesh"]:
		var w = m.get_node("Wheels/" + wheel_name)
		w.rotate_x(rot_speed)

# ---------------------------------------------------------
#  SWITCH CAR BY ID
# ---------------------------------------------------------
func switch_car(car_id: String):
	if not car_models.has(car_id) or not car_stats.has(car_id):
		push_error("Car ID not found: " + car_id)
		return

	car_model_scene = car_models[car_id]
	stats = car_stats[car_id]

	load_car_model()
	apply_stats()
