extends Camera3D

@export var target: Node3D
@export var distance: float = 8.0
@export var height: float = 2.0
@export var smooth_speed: float = 10.0
@export var collision_offset: float = 0.2
@export var min_distance: float = 3.0   # <- camera will NEVER get closer than this

func _physics_process(delta):
	if target == null:
		return

	var car_pos = target.global_transform.origin
	var forward = -target.global_transform.basis.z.normalized()

	# Ideal camera position
	var ideal_pos = car_pos - forward * distance
	ideal_pos.y += height

	# Raycast from car → ideal camera position
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(car_pos, ideal_pos)
	query.exclude = [target]

	var hit = space.intersect_ray(query)

	var final_pos = ideal_pos

	if hit:
		# Position at the wall
		var wall_pos = hit.position + hit.normal * collision_offset

		# Distance from car to wall
		var wall_dist = car_pos.distance_to(wall_pos)

		# If wall is too close → clamp to min_distance
		if wall_dist < min_distance:
			final_pos = car_pos - forward * min_distance
			final_pos.y += height
		else:
			final_pos = wall_pos
	else:
		final_pos = ideal_pos

	# Smooth movement
	global_transform.origin = global_transform.origin.lerp(final_pos, delta * smooth_speed)

	# Look at car
	look_at(car_pos, Vector3.UP)
