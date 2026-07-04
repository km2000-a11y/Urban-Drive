extends RigidBody3D

var pending_delete := false

func _on_rigid_body_3d_2_body_entered(body: Node) -> void:
	if pending_delete:
		return

	pending_delete = true

	# Disable collisions so solver stops touching it
	collision_layer = 0
	collision_mask = 0

	# Switch to kinematic so physics won't explode
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	freeze = false

	# Make it fly away (manual movement)
	var dir: Vector3 = (global_position - body.global_position).normalized()
	var force: Vector3 = dir * 8.0 + Vector3.UP * 3.0   # tweak this for more YEET

	# Animate the prop flying away (fake physics)
	var timer := get_tree().create_timer(0.25)
	while timer.time_left > 0.0:
		var dt := get_process_delta_time()
		global_position += force * dt
		rotation.x += 8.0 * dt
		rotation.z += 6.0 * dt
		await get_tree().process_frame

	queue_free()
