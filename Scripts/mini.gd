extends RigidBody3D

const ENGINE_FORCE := 3300.0
const TURN_RATE := 2.5
const MAX_SPEED := 61.0

func _physics_process(delta):
	var forward := -global_transform.basis.z
	var right := global_transform.basis.x

	# -------------------------
	# ACCELERATION
	# -------------------------
	if Input.is_action_pressed("accelerate"):
		apply_central_force(forward * ENGINE_FORCE)

	if Input.is_action_pressed("brake"):
		apply_central_force(-forward * ENGINE_FORCE)

	# -------------------------
	# STEERING
	# -------------------------
	if Input.is_action_pressed("turn_left"):
		rotation.y += TURN_RATE * delta
	if Input.is_action_pressed("turn_right"):
		rotation.y -= TURN_RATE * delta

	# -------------------------
	# SPEED LIMIT
	# -------------------------
	if linear_velocity.length() > MAX_SPEED:
		linear_velocity = linear_velocity.normalized() * MAX_SPEED

	# -------------------------
	# ⭐ REAL SIDEWAYS FRICTION (LOCAL SPACE)
	# -------------------------
	# Convert velocity to local space
	var lv := global_transform.basis.inverse() * linear_velocity

	# Kill sideways component
	lv.x = 0

	# Convert back to world space
	linear_velocity = global_transform.basis * lv
