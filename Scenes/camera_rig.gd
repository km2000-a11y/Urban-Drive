extends SpringArm3D

# ------------------------------------------------------------
# CAMERA SETTINGS
# ------------------------------------------------------------
@export var follow_target: Node3D

@export var follow_distance: float = 6.0
@export var follow_height: float = 1.8
@export var tilt_angle: float = -8.0

@export var follow_smoothness: float = 6.0
@export var rotation_smoothness: float = 8.0

# Speed-based zoom
@export var zoom_min: float = 5.5
@export var zoom_max: float = 7.5
@export var zoom_speed_factor: float = 0.015

# Drift camera swing
@export var drift_swing_strength: float = 0.35


func _physics_process(delta: float) -> void:
	if follow_target == null:
		return

	# ------------------------------------------------------------
	# POSITION FOLLOW
	# ------------------------------------------------------------
	var target_pos: Vector3 = follow_target.global_transform.origin
	target_pos += -follow_target.transform.basis.z * follow_distance
	target_pos.y += follow_height

	global_transform.origin = global_transform.origin.lerp(target_pos, delta * follow_smoothness)

	# ------------------------------------------------------------
	# ROTATION FOLLOW
	# ------------------------------------------------------------
	var target_rot: float = follow_target.rotation.y

	# Drift swing (camera swings outward when drifting)
	if "drifting" in follow_target and follow_target.drifting:
		var drift_amount: float = follow_target.steering * drift_swing_strength
		target_rot += drift_amount

	rotation.y = lerp_angle(rotation.y, target_rot, delta * rotation_smoothness)

	# Tilt downward
	rotation_degrees.x = tilt_angle

	# ------------------------------------------------------------
	# SPEED-BASED ZOOM
	# ------------------------------------------------------------
	if "velocity" in follow_target:
		var speed: float = follow_target.velocity.length()
		var target_zoom: float = clamp(zoom_min + speed * zoom_speed_factor, zoom_min, zoom_max)
		spring_length = lerp(spring_length, target_zoom, delta * 4.0)
