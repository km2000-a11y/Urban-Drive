extends RigidBody3D

var pending_delete := false

func _on_body_entered(body):
	if pending_delete:
		return

	# Disable collisions so solver stops touching it
	collision_layer = 0
	collision_mask = 0

	# Switch to kinematic so physics won't explode
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	freeze = false

	# Make it fly away (manual movement)
	var dir :Vector3= (global_position - body.global_position).normalized()
	var force :Vector3= dir * 8.0 + Vector3.UP * 3.0   # tweak this for more YEET

	# Animate the prop flying away
	# (manual fake physics)
	var t := get_tree().create_timer(0.25)
	while t.time_left > 0:
		global_position += force * get_process_delta_time()
		rotation.x += 8.0 * get_process_delta_time()
		rotation.z += 6.0 * get_process_delta_time()
		await get_tree().process_frame

	# Delete AFTER physics settles
	pending_delete = true
	queue_free()
