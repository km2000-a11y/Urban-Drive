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
var current_steer := 0.0

# ---------------------------------------------------------
#  READY
# ---------------------------------------------------------
func _ready():
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
#  INPUT HANDLING (RIGIDBODY ARCADE PHYSICS)
# ---------------------------------------------------------
func handle_input(delta):
	if stats == null:
		return

	var throttle := Input.get_action_strength("accelerate")
	var brake := Input.get_action_strength("brake")
	var steer := Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")

	# Steering torque
	var max_steer := deg_to_rad(stats.handling * 2.5)
	current_steer = lerp(current_steer, steer * max_steer, delta * 6.0)
	var steer_torque := Vector3.UP * current_steer * linear_velocity.length() * 0.015
	apply_torque_impulse(steer_torque)

	# Forward force
	var speed := linear_velocity.length()
	if speed < stats.max_speed:
		var force := throttle * stats.acceleration * 18000.0
		apply_central_force(global_transform.basis.z * -force)

	# Braking
	if brake > 0.1:
		var brake_vec := -linear_velocity.normalized() * stats.brake_strength * 20000.0
		apply_central_force(brake_vec)

	# Drift control
	var lv := linear_velocity
	var sideways := global_transform.basis.x.dot(lv)
	var forward := global_transform.basis.z.dot(lv)
	sideways *= 0.92
	lv = global_transform.basis.x * sideways + global_transform.basis.z * forward
	linear_velocity = lv * stats.traction

# ---------------------------------------------------------
#  VISUAL WHEEL SYNC (MODEL → MODEL)
# ---------------------------------------------------------
func update_visual_wheels():
	if not car_model:
		return

	var m := car_model

	# Rotate wheels visually based on speed
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
