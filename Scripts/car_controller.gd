extends CharacterBody3D

var gravity_force:=12.0
@export var car_name: String
@export var country: String
@export var transmission:  String
@export var engine: String

@export var horsepower: int
@export var weight_kg: int
@export var zero_to_hundred: float
@export var top_speed: int
@export var price: int

@export var max_speed: float
@export var acceleration: float
@export var brake_force: float
@export var turn_speed: float
@export var grip: float
@export var drift_grip: float
@export var weight: float
@export var drivetrain_type: String

func _physics_process(delta):
	# --- GRAVITY ---
	velocity.y -= gravity_force * delta

	# --- INPUT ---
	var throttle := Input.get_action_strength("accelerate")
	var brake := Input.get_action_strength("brake")
	var steer := Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")

	# --- FORWARD DIRECTION ---
	var forward := -transform.basis.z   # Godot forward = -Z

	# --- ACCELERATION ---
	if throttle > 0:
		velocity += forward * acceleration * delta

	# --- REVERSE ---
	if brake > 0:
		velocity -= forward * brake_force * delta   # reverse = +Z direction

	# --- HORIZONTAL VELOCITY ---
	var horizontal := Vector3(velocity.x, 0, velocity.z)

	# --- SPEED LIMIT ---
	if horizontal.length() > max_speed:
		horizontal = horizontal.normalized() * max_speed

	# --- FRICTION ---
	if throttle == 0 and brake == 0:
		horizontal = horizontal.move_toward(Vector3.ZERO, grip * delta)

	# Write back horizontal velocity
	velocity.x = horizontal.x
	velocity.z = horizontal.z

	# --- STEERING ---
		# --- STEERING ---
	if horizontal.length() > 0.5:
		rotation.y += steer * turn_speed * delta

	# --- APPLY MOVEMENT USING YOUR HORIZONTAL VELOCITY ---
	var move_vec :Vector3= horizontal * delta
	translate(move_vec)


	# --- MOVE ---
	print("VEL BEFORE:", velocity)
	move_and_slide()
	print("FORWARD:", forward)

	
	
