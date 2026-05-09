extends Node3D

@export var stats: CarStats
@export var car_model_scene: PackedScene

var car_model: Node3D
var velocity: Vector3 = Vector3.ZERO

# ---------------------------------------------------------
#  CAR DATABASES (KEEP THESE)
# ---------------------------------------------------------
var car_models := {
	"abarth_500": preload("res://Cars/abarth_500.tscn"),
}

var car_stats := {
	"abarth_500": preload("res://Car Stats/abarth_500.tres"),
}

var car_list := [
	"abarth_500"
]

# ---------------------------------------------------------
#  READY
# ---------------------------------------------------------
func _ready():
	switch_car(car_list[0])
	velocity = Vector3.ZERO

# ---------------------------------------------------------
#  LOAD CAR MODEL
# ---------------------------------------------------------
func load_car_model():
	if car_model:
		car_model.queue_free()

	car_model = car_model_scene.instantiate()
	$ModelRoot.add_child(car_model)

	# --- POSITION RAYCASTS TO MATCH WHEEL POS ---
	$Wheels/WheelFL.global_position = car_model.get_node("WheelPos/WheelFL_Pos").global_position
	$Wheels/WheelFR.global_position = car_model.get_node("WheelPos/WheelFR_Pos").global_position
	$Wheels/WheelRL.global_position = car_model.get_node("WheelPos/WheelRL_Pos").global_position
	$Wheels/WheelRR.global_position = car_model.get_node("WheelPos/WheelRR_Pos").global_position

# ---------------------------------------------------------
#  APPLY CAR STATS
# ---------------------------------------------------------
func apply_stats():
	if stats == null:
		push_error("Stats is NULL in apply_stats()")
		return
	print("Accel:", stats.acceleration)

# ---------------------------------------------------------
#  PHYSICS LOOP
# ---------------------------------------------------------
func _physics_process(delta: float) -> void:
	velocity.y -= 30.0 * delta

	handle_input(delta)
	update_visual_wheels(delta)

	global_position += velocity * delta

# ---------------------------------------------------------
#  INPUT HANDLING
# ---------------------------------------------------------
func handle_input(delta: float) -> void:
	var throttle := Input.get_action_strength("accelerate")
	var brake := Input.get_action_strength("brake")
	var steer := Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")

	var forward := -global_transform.basis.z

	# ACCELERATION
	if throttle > 0.01:
		velocity += forward * throttle * stats.acceleration * delta
	else:
		velocity = velocity.move_toward(Vector3.ZERO, stats.traction * delta)

	# BRAKING
	if brake > 0.01:
		velocity = velocity.move_toward(Vector3.ZERO, stats.brake_strength * delta)

	# SPEED LIMIT
	var speed := velocity.length()
	if speed > stats.max_speed:
		velocity = velocity.normalized() * stats.max_speed

	# STEERING
	if speed > 0.1:
		var turn_amount := steer * stats.turn_rate * delta
		rotate_y(turn_amount)
		velocity = velocity.rotated(Vector3.UP, turn_amount)

# ---------------------------------------------------------
#  VISUAL WHEEL SYNC (NO DICTS, JUST DIRECT PATHS)
# ---------------------------------------------------------
func update_visual_wheels(delta: float):
	if car_model == null:
		return

	var rot_speed := velocity.length() * 0.05

	# Raycasts
	var FL_ray = $Wheels/WheelFL
	var FR_ray = $Wheels/WheelFR
	var RL_ray = $Wheels/WheelRL
	var RR_ray = $Wheels/WheelRR

	# Meshes
	var FL_mesh = car_model.get_node("WheelMesh/WheelFL_Mesh")
	var FR_mesh = car_model.get_node("WheelMesh/WheelFR_Mesh")
	var RL_mesh = car_model.get_node("WheelMesh/WheelRL_Mesh")
	var RR_mesh = car_model.get_node("WheelMesh/WheelRR_Mesh")

	# Sync positions
	FL_mesh.global_position = FL_ray.global_position
	FR_mesh.global_position = FR_ray.global_position
	RL_mesh.global_position = RL_ray.global_position
	RR_mesh.global_position = RR_ray.global_position

	# Rotate visuals
	FL_mesh.rotate_x(rot_speed)
	FR_mesh.rotate_x(rot_speed)
	RL_mesh.rotate_x(rot_speed)
	RR_mesh.rotate_x(rot_speed)

# ---------------------------------------------------------
#  SWITCH CAR
# ---------------------------------------------------------
func switch_car(car_id: String):
	if not car_models.has(car_id) or not car_stats.has(car_id):
		push_error("Car ID not found: " + car_id)
		return

	car_model_scene = car_models[car_id]
	stats = car_stats[car_id]

	load_car_model()
	apply_stats()
