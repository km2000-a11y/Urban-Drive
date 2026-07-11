extends Node

var player_car_path: String = ""
var ai_car_paths: Array = []        # 7 AI car scene paths

var player_spawn: Vector3 = Vector3.ZERO
var ai_spawns: Array = []           # 7 Vector3 positions

var player_car: CarController = null
var ai_cars: Array = []

var race_active: bool = false
var total_laps: int = 3

var player_laps: int = 0
var ai_laps: Array = []

var lap_cooldown: bool = false
var hud: Node = null
var main_scene: Node = null


func spawn_race(scene: Node) -> void:
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
	force_player_camera()
	scene.add_child(player_car)

	_apply_player_color(player_car)

	await get_tree().process_frame
	await get_tree().process_frame

	if player_car.has_node("Camera3D"):
		player_car.get_node("Camera3D").current = true

	# AI CARS
	ai_cars.clear()
	ai_laps.clear()

	for i in range(ai_spawns.size()):
		var ai_scene := load(ai_car_paths[i])
		var ai_car := ai_scene.instantiate() as CarController
		scene.add_child(ai_car)

		if ai_car.has_node("Camera3D"):
			var cam := ai_car.get_node("Camera3D")
			cam.current = false
			
		var spawn_node := root.get_node("AISpawnPoint" + str(i+1))
		ai_car.global_transform = spawn_node.global_transform
		ai_car.is_ai = true
		ai_car.controls_enabled = true

		ai_car.driver_name = ai_car.ai_names[randi() % ai_car.ai_names.size()]
		ai_car.car_name = ai_car_paths[i].get_file().get_basename()

		_apply_random_ai_color(ai_car)

		ai_cars.append(ai_car)
		ai_laps.append(0)

	await get_tree().process_frame
	await get_tree().process_frame

	# WAYPOINTS
	var wp_root := scene.find_child("Waypoints", true, false)
	player_car.set_waypoints(wp_root)

	for ai in ai_cars:
		ai.set_waypoints(wp_root)

	# START
	player_laps = 0
	race_active = true

	hud.update_lap(1, total_laps)
	hud.update_position(8, 8)

	print("NormalRaceManager: Race started.")
	MusicManager.stop_music()
	MusicManager.play_race_music()


func register_lap(body: Node) -> void:
	if not race_active or lap_cooldown:
		return

	var car := body
	while car != null and not (car is CarController):
		car = car.get_parent()

	if car == null:
		return

	# PLAYER LAP LOGIC FIX
	if car == player_car:

		# must have waypoints
		if player_car.waypoints.size() == 0:
			return

		var wp0 := player_car.waypoints[0] as Node3D

		# forward direction
		var forward := -player_car.transform.basis.z
		forward.y = 0.0
		forward = forward.normalized()

		# direction to WP0
		var to_wp0 := wp0.global_position - player_car.global_position
		to_wp0.y = 0.0
		var dir := to_wp0.normalized()

		var dot := forward.dot(dir)

		# waypoint behind the car → ignore lap
		if dot < 0.0:
			return

		# must be at last waypoint before WP0
		if player_car.current_wp != player_car.waypoints.size() - 1:
			return

		# now count lap
		player_laps += 1
		print("Player lap:", player_laps)

	else:
		# AI lap logic unchanged
		var idx := ai_cars.find(car)
		if idx != -1:
			ai_laps[idx] += 1
			print("AI", idx, "lap:", ai_laps[idx])

	# cooldown only after valid lap
	lap_cooldown = true
	_start_lap_cooldown()

	_check_finish()



func _start_lap_cooldown() -> void:
	await get_tree().create_timer(1.0).timeout
	lap_cooldown = false


func _check_finish() -> void:
	if player_laps >= total_laps:
		_end_race("Player")
		return

	for i in range(ai_cars.size()):
		if ai_laps[i] >= total_laps:
			_end_race("AI")
			return


func _end_race(winner: String) -> void:
	race_active = false

	player_car.controls_enabled = false
	for ai in ai_cars:
		ai.controls_enabled = false

	RaceResults.add_result(player_car.driver_name, player_car.car_name, player_car.total_race_time)

	for i in range(ai_cars.size()):
		RaceResults.add_result(ai_cars[i].driver_name, ai_cars[i].car_name, ai_cars[i].total_race_time)

	main_scene.show_finish(winner == "Player")
	hud.visible = false

	MusicManager.stop_music()


func update_race() -> void:
	if not race_active:
		return

	hud.update_stopwatch(player_car.total_race_time)
	hud.update_lap(player_laps + 1, total_laps)
	hud.update_position(_calculate_position(), ai_cars.size() + 1)


func _calculate_position() -> int:
	var positions := []

	positions.append({
		"car": player_car,
		"laps": player_laps,
		"wp": player_car.current_wp,
		"dist": player_car.distance_to_next_wp()
	})

	for i in range(ai_cars.size()):
		positions.append({
			"car": ai_cars[i],
			"laps": ai_laps[i],
			"wp": ai_cars[i].current_wp,
			"dist": ai_cars[i].distance_to_next_wp()
		})

	positions.sort_custom(_sort_positions)

	for i in range(positions.size()):
		if positions[i]["car"] == player_car:
			return i + 1

	return 1


func _sort_positions(a, b) -> bool:
	if a["laps"] != b["laps"]:
		return a["laps"] > b["laps"]

	if a["wp"] != b["wp"]:
		return a["wp"] > b["wp"]

	return a["dist"] < b["dist"]


func _apply_player_color(car: CarController) -> void:
	var color: Color = Cars.selected_color
	if car.has_node("ModelRoot/Body"):
		var body := car.get_node("ModelRoot/Body")
		for child in body.get_children():
			if child is MeshInstance3D:
				var mat :Material = child.get_active_material(0)
				if mat is BaseMaterial3D:
					mat.albedo_color = color


func _apply_random_ai_color(car: CarController) -> void:
	var name := car.car_name
	if Cars.car_colors.has(name):
		var palette: Array = Cars.car_colors[name]
		var random_color: Color = palette[randi() % palette.size()]

		if car.has_node("ModelRoot/Body"):
			var body := car.get_node("ModelRoot/Body")
			for child in body.get_children():
				if child is MeshInstance3D:
					var mat :Material = child.get_active_material(0)
					if mat is BaseMaterial3D:
						mat = mat.duplicate()
						child.set_surface_override_material(0, mat)
						mat.albedo_color = random_color


func force_player_camera():
	if player_car and player_car.has_node("Camera3D"):
		player_car.get_node("Camera3D").current = true
