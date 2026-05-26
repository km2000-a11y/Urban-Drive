extends CharacterBody3D

# CAR PHYSICS
const MASS := 1150.0
const ZERO_TO_HUNDRED := 7.2
const TOP_SPEED := 61.1
const ACCELERATION := 27.78 / ZERO_TO_HUNDRED
const TURN_SPEED := 2.5
const GRAVITY := 30.0
const BRAKE_STRENGTH := 20.0
const LATERAL_FRICTION := 2.0

var steering := 0.0
@onready var car_model := $ModelRoot

func _physics_process(delta):

	# INPUT
	var accel := Input.get_action_strength("accelerate")
	var brake := Input.get_action_strength("brake")
	var steer := Input.get_action_strength("turn_left") - Input.get_action_strength("turn_right")

	# STEERING
	steering = lerp(steering, steer, delta * 6.0)
	rotation.y += steering * TURN_SPEED * delta

	# VISUAL LEAN
	var tilt := -steering * 10.0
	car_model.rotation_degrees.z = lerp(car_model.rotation_degrees.z, tilt, delta * 8.0)

	# DIRECTIONS
	var forward := -global_transform.basis.z
	var right := global_transform.basis.x

	# ACCELERATION
	if accel > 0.0:
		velocity += forward * ACCELERATION * accel * delta

	# BRAKING
	if brake > 0.0:
		velocity = velocity.move_toward(Vector3.ZERO, BRAKE_STRENGTH * delta)

	# LATERAL FRICTION
	var lateral := right.dot(velocity)
	velocity -= right * lateral * LATERAL_FRICTION * delta

	# SPEED LIMIT
	var flat := Vector3(velocity.x, 0, velocity.z)
	if flat.length() > TOP_SPEED:
		flat = flat.normalized() * TOP_SPEED
		velocity.x = flat.x
		velocity.z = flat.z

	# GRAVITY
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	# SAVE VELOCITY BEFORE COLLISION
	var old_velocity := velocity

	# MOVE
	move_and_slide()

	# COLLISION COUNT
	var collision_count := get_slide_collision_count()

	# MOMENTUM COLLISION RESPONSE
	if collision_count > 0:
		for i in range(collision_count):
			var col := get_slide_collision(i)
			var normal := col.get_normal()

			var p_before := MASS * old_velocity
			var v_reflect := old_velocity.bounce(normal)
			var p_after := MASS * v_reflect

			var impulse := p_after - p_before

			velocity = v_reflect
