extends CharacterBody3D

@export var stats: CarStats
@export var car_model_scene: PackedScene

var car_model: Node3D
var steer_angle := 0.0

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

# ---------------------------------------------------------
#  APPLY CAR STATS
# ---------------------------------------------------------
func apply_stats():
	if stats == null:
		push_error("Stats is NULL in apply_stats()")
		return
		
	print("Accel: ", stats.acceleration)

# ---------------------------------------------------------
#  PHYSICS LOOP
# ---------------------------------------------------------
func _physics_process(delta):
	handle_input(delta)
	update_visual_wheels()
	move_and_slide()
	
	print("Body basis:", transform.basis)
	print("Throttle:", Input.get_action_strength("accelerate"))
	print("Velocity:", velocity)
	print("Body rot:", rotation_degrees)
	print("ModelRoot rot:", $ModelRoot.rotation_degrees)
	print("Model rot:", car_model.rotation_degrees)


# ---------------------------------------------------------
#  INPUT HANDLING
# ---------------------------------------------------------
func handle_input(delta):
	# --- INPUT ---
	var throttle := Input.get_action_strength("accelerate")
	var brake := Input.get_action_strength("brake")
	var steer := Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")

	# --- CAR FORWARD VECTOR ---
	var forward: Vector3 = -global_transform.basis.z

	# --- ACCELERATION ---
	if throttle > 0.01:
		velocity += forward * throttle * stats.acceleration * delta
	else:
		# natural slowdown
		velocity = velocity.move_toward(Vector3.ZERO, stats.traction * delta)

	# --- BRAKING ---
	if brake > 0.01:
		velocity = velocity.move_toward(Vector3.ZERO, stats.brake_strength * delta)

	# --- SPEED LIMIT ---
	var speed := velocity.length()
	if speed > stats.max_speed:
		velocity = velocity.normalized() * stats.max_speed

	# --- STEERING (ROTATE CAR + VELOCITY) ---
	if speed > 0.1:
		var turn_amount: float = steer * stats.handling * delta
		rotate_y(turn_amount)
		velocity = velocity.rotated(Vector3.UP, turn_amount)


# ---------------------------------------------------------
#  VISUAL WHEEL SYNC
# ---------------------------------------------------------
func update_visual_wheels():
	if not car_model:
		return

	var rot_speed := velocity.length() * 0.05
	var wheels := car_model.get_node("Wheels")

	for wheel_name in ["WheelFL_Mesh","WheelFR_Mesh","WheelRL_Mesh","WheelRR_Mesh"]:
		if wheels.has_node(wheel_name):
			var w = wheels.get_node(wheel_name)
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
