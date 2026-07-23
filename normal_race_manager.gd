extends Node

var player_car_path: String = ""
var ai_car_paths: Array = []        # 7 AI car scene paths

var player_spawn: Vector3 = Vector3.ZERO
var ai_spawns: Array = []

var player_car: CarController = null
var ai_cars: Array[CarController] = []

var race_active: bool = false
var total_laps: int = 3

var lap_cooldown: bool = false
var hud: Node = null
var main_scene: Node = null

# flawless lap + waypoint tracking
var car_laps: Dictionary = {}
var last_wp: Dictionary = {}
var wrap_cooldown: Dictionary = {}


func spawn_race(scene: Node) -> void:
	race_active = false
	lap_cooldown = false

	# Remove old cars
	if player_car and player_car.is_inside_tree():
		player_car.queue_free()

	for ai in ai_cars:
		if ai and ai.is_inside_tree():
			ai.queue_free()

	ai_cars.clear()

	await get_tree().process_frame

	var root := scene.get_node(TrackName.track_name)

	player_spawn = root.get_node("SpawnPoint").global_transform.origin

	ai_spawns.clear()
	for i in range(7):
		ai_spawns.append(root.get_node("AISpawnPoint" + str(i+1)).global_transform.origin)

	RaceResults.clear()
	main_scene = scene
	hud = scene.get_node("HUD")

	# PLAYER
	var player_scene := load(player_car_path)
	player_car = player_scene.instantiate() as CarController
	player_car.is_ai = false
	player_car.global_transform = root.get_node("SpawnPoint").global_transform
	player_car.controls_enabled = true
	player_car.driver_name = "Player"
	player_car.car_name = Cars.selected_car_name
	scene.add_child(player_car)

	_apply_player_color(player_car)

	await get_tree().process_frame
	await get_tree().process_frame

	if player_car.has_node("Camera3D"):
		player_car.get_node("Camera3D").current = true

	# AI CARS
	ai_cars.clear()

	for i in range(ai_spawns.size()):
		var ai_scene := load(ai_car_paths[i])
		var ai := ai_scene.instantiate() as CarController
		scene.add_child(ai)

		if ai.has_node("Camera3D"):
			ai.get_node("Camera3D").current = false

		var spawn_node := root.get_node("AISpawnPoint" + str(i+1))
		ai.global_transform = spawn_node.global_transform
		ai.is_ai = true
		ai.controls_enabled = true

		ai.driver_name = ai.ai_names[randi() % ai.ai_names.size()]
		ai.car_name = Cars.car_scene_paths.keys()[Cars.car_scene_paths.values().find(ai_car_paths[i])]

		_apply_random_ai_color(ai)

		ai_cars.append(ai)

	await get_tree().process_frame
	await get_tree().process_frame

	# WAYPOINTS
	var wp_root := scene.find_child("Waypoints", true, false)
	player_car.set_waypoints(wp_root)

	for ai in ai_cars:
		ai.set_waypoints(wp_root)

	# INIT flawless lap dictionaries (correct placement)
	car_laps.clear()
	last_wp.clear()
	wrap_cooldown.clear()

	car_laps[player_car] = 0
	last_wp[player_car] = 0
	wrap_cooldown[player_car] = false

	for ai in ai_cars:
		car_laps[ai] = 0
		last_wp[ai] = 0
		wrap_cooldown[ai] = false

	race_active = true

	hud.update_lap(1, total_laps)
	hud.update_position(8, 8)

	MusicManager.stop_music()
	MusicManager.play_race_music()

func register_lap(body: Node) -> void:
	if not race_active or lap_cooldown:
		return

	var car: Node = body
	while car != null and not (car is CarController):
		car = car.get_parent()

	if car == null:
		return

	if not car_laps.has(car):
		return  # <- critical safety

	lap_cooldown = true
	_start_lap_cooldown()

	car_laps[car] += 1

	_check_finish()


func _start_lap_cooldown() -> void:
	await get_tree().create_timer(1.0).timeout
	lap_cooldown = false


func _check_finish() -> void:
	if not race_active:
		return

	var player_finished: bool = car_laps[player_car] >= total_laps

	if not player_finished:
		return

	var player_position := _calculate_position()
	var player_won := (player_position <= 3)

	if player_won:
		_end_race("Player")
	else:
		_end_race("AI")


func _end_race(winner: String) -> void:
	race_active = false
	player_car.controls_enabled = false
	for ai in ai_cars:
		ai.controls_enabled = false

	var participants = []
	var total_wp := player_car.waypoints.size()

	var p_progress = (car_laps[player_car] * total_wp) + player_car.current_wp
	participants.append({
		"car_obj": player_car,
		"name": player_car.driver_name,
		"car_name": player_car.car_name,
		"progress": p_progress,
		"dist": _distance_to_next_wp(player_car),
		"real_time": player_car.total_race_time,
		"finished": car_laps[player_car] >= total_laps
	})

	for ai in ai_cars:
		var ai_progress = (car_laps[ai] * total_wp) + ai.current_wp
		participants.append({
			"car_obj": ai,
			"name": ai.driver_name,
			"car_name": ai.car_name,
			"progress": ai_progress,
			"dist": _distance_to_next_wp(ai),
			"real_time": ai.total_race_time,
			"finished": car_laps[ai] >= total_laps
		})

	participants.sort_custom(func(a, b):
		if a["progress"] != b["progress"]:
			return a["progress"] > b["progress"]
		return a["dist"] < b["dist"]
	)

	RaceResults.clear()

	var winner_time = participants[0]["real_time"]

	for p in participants:
		var final_time: int

		if p["finished"]:
			final_time = p["real_time"]
		else:
			var leader_progress = participants[0]["progress"]
			var leader_time = participants[0]["real_time"]

			var progress_diff = leader_progress - p["progress"]
			var avg_time_per_wp = leader_time / max(leader_progress, 1)

			var penalty = int(progress_diff * avg_time_per_wp) + (randi() % 1500 + 500)
			final_time = leader_time + penalty

		RaceResults.add_result(p["name"], p["car_name"], final_time)

	main_scene.show_finish(winner == "Player")
	hud.visible = false
	MusicManager.stop_music()


func update_race() -> void:
	if not race_active:
		return

	hud.update_stopwatch(player_car.total_race_time)
	hud.update_lap(car_laps[player_car] + 1, total_laps)
	hud.update_position(_calculate_position(), ai_cars.size() + 1)


func _distance_to_next_wp(car: CarController) -> float:
	if car.waypoints.is_empty():
		return 0.0

	var next_wp := car.current_wp + 1
	if next_wp >= car.waypoints.size():
		next_wp = 0

	var wp := car.waypoints[next_wp] as Node3D
	return car.global_position.distance_to(wp.global_position)


func _calculate_position() -> int:
	var sorted := _sorted_cars()

	for i in range(sorted.size()):
		if sorted[i] == player_car:
			return i + 1

	return 1


func _sorted_cars() -> Array:
	var total_wp := player_car.waypoints.size()
	var cars := []

	# DO NOT increment laps here in Normal Race
	# Only update last_wp so progress sorting works

	if player_car.current_wp == 0 and last_wp[player_car] == total_wp - 1:
		pass

	for ai in ai_cars:
		if ai.current_wp == 0 and last_wp[ai] == total_wp - 1:
			pass

	# build sortable data
	cars.append({
		"car": player_car,
		"progress": car_laps[player_car] * total_wp + player_car.current_wp,
		"dist": _distance_to_next_wp(player_car)
	})

	for ai in ai_cars:
		cars.append({
			"car": ai,
			"progress": car_laps[ai] * total_wp + ai.current_wp,
			"dist": _distance_to_next_wp(ai)
		})

	# sort
	cars.sort_custom(func(a, b):
		if a["progress"] != b["progress"]:
			return a["progress"] > b["progress"]
		return a["dist"] < b["dist"]
	)

	var result: Array = []
	for c in cars:
		result.append(c["car"])

	last_wp[player_car] = player_car.current_wp
	for ai in ai_cars:
		last_wp[ai] = ai.current_wp

	return result


func _apply_player_color(car: CarController) -> void:
	var color: Color = Cars.selected_color
	if car.has_node("ModelRoot/Body"):
		var body := car.get_node("ModelRoot/Body")
		for child in body.get_children():
			if child is MeshInstance3D:
				var mat :Material= child.get_active_material(0)
				if mat is BaseMaterial3D:
					mat.albedo_color = color


func _apply_random_ai_color(car: CarController) -> void:
	var name: String = car.car_name

	if not Cars.car_colors.has(name):
		return

	var palette: Array = Cars.car_colors[name]
	if palette.is_empty():
		return

	var random_color: Color = palette[randi() % palette.size()]

	if car.has_node("ModelRoot/Body"):
		var body := car.get_node("ModelRoot/Body")

		for child in body.get_children():
			if child is MeshInstance3D:
				var mesh_instance := child
				var mesh :Mesh= mesh_instance.mesh
				if mesh == null:
					return

				var surface_count := mesh.get_surface_count()

				var new_mat := StandardMaterial3D.new()
				new_mat.albedo_color = random_color

				for s in range(surface_count):
					mesh_instance.set_surface_override_material(s, new_mat)


func force_player_camera():
	if player_car and player_car.has_node("Camera3D"):
		player_car.get_node("Camera3D").current = true
