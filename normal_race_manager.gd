extends Node

var player_car_path: String = ""
var ai_car_paths: Array = []        # 7 AI car scene paths

var player_spawn: Vector3 = Vector3.ZERO
var ai_spawns: Array = []           # 7 Vector3 positions

var player_car: CarController = null
var ai_cars: Array[CarController] = []

var race_active: bool = false
var total_laps: int = 3

var player_laps: int = 0
var ai_laps: Array[int] = []

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

	MusicManager.stop_music()
	MusicManager.play_race_music()

func register_lap(body: Node) -> void:
	if not race_active or lap_cooldown:
		return

	# Find the CarController
	var car := body
	while car != null and not (car is CarController):
		car = car.get_parent()

	if car == null:
		return

	# Prevent double-trigger
	lap_cooldown = true
	_start_lap_cooldown()

	# --- PLAYER LAP ---
	if car == player_car:
		player_laps += 1
		player_car.current_wp = 0


		print("Player lap:", player_laps)

	# --- AI LAP ---
	else:
		var idx := ai_cars.find(car)
		if idx != -1:
			ai_laps[idx] += 1
			ai_cars[idx].current_wp = 0

	# Check finish
	_check_finish()



func _start_lap_cooldown() -> void:
	await get_tree().create_timer(1.0).timeout
	lap_cooldown = false



func _check_finish() -> void:
	if not race_active:
		return

	# Did player finish?
	var player_finished := player_laps >= total_laps

	# Track AI finish status (but do NOT end race)
	var ai_finished := false
	for i in range(ai_cars.size()):
		if ai_laps[i] >= total_laps:
			ai_finished = true
			# DO NOT end race here
			break

	# If player has NOT finished → keep racing
	if not player_finished:
		return

	# Player finished → now determine final position
	var player_position := _calculate_position()

	# Win if player is 1st, 2nd, or 3rd
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

	# 1. Собираем данные всех участников
	var participants = []
	
	# Считаем общий прогресс в вейпоинтах для точной сортировки
	# (Кол-во кругов * общее кол-во WP + текущий WP)
	var total_waypoints = player_car.waypoints.size()

	var p_progress = (player_laps * total_waypoints) + player_car.current_wp
	participants.append({
		"car_obj": player_car,
		"name": player_car.driver_name,
		"car_name": player_car.car_name,
		"progress": p_progress,
		"dist": _distance_to_next_wp(player_car),
		"real_time": player_car.total_race_time,
		"finished": player_laps >= total_laps
	})

	for i in range(ai_cars.size()):
		var ai = ai_cars[i]
		var ai_progress = (ai_laps[i] * total_waypoints) + ai.current_wp
		participants.append({
			"car_obj": ai,
			"name": ai.driver_name,
			"car_name": ai.car_name,
			"progress": ai_progress,
			"dist": _distance_to_next_wp(ai),
			"real_time": ai.total_race_time,
			"finished": ai_laps[i] >= total_laps
		})

	# 2. Сортируем участников по реальному первенству
	participants.sort_custom(func(a, b):
		if a["progress"] != b["progress"]:
			return a["progress"] > b["progress"]
		return a["dist"] < b["dist"]
	)

	# 3. Генерируем времена на основе позиций
	RaceResults.clear()
	
	var winner_time = participants[0]["real_time"]
	
	for i in range(participants.size()):
		var p = participants[i]
		var final_time : int
		
		if i == 0:
			# Первый всегда получает свое реальное время
			final_time = p["real_time"]
		else:
			if p["finished"]:
				# Если этот AI тоже успел финишировать, пишем его реальное время
				final_time = p["real_time"]
			else:
				# Если не финишировал, генерируем время:
				# Время лидера + (разница в прогрессе * среднее время на 1 вейпоинт) + рандомный разброс
				var progress_diff = participants[0]["progress"] - p["progress"]
				var avg_time_per_wp = winner_time / max(participants[0]["progress"], 1)
				
				# Добавляем небольшую случайность (0.5 - 1.5 сек), чтобы не было слишком "математически"
				var penalty = int(progress_diff * avg_time_per_wp) + (randi() % 2000 + 500)
				final_time = winner_time + penalty
		
		RaceResults.add_result(p["name"], p["car_name"], final_time)

	main_scene.show_finish(winner == "Player")
	hud.visible = false
	MusicManager.stop_music()


func update_race() -> void:
	if not race_active:
		return

	hud.update_stopwatch(player_car.total_race_time)
	hud.update_lap(player_laps + 1, total_laps)
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
	var total_wp := player_car.waypoints.size()
	var cars := []

	# Player
	cars.append({
		"car": player_car,
		"progress": player_laps * total_wp + player_car.current_wp,
		"dist": _distance_to_next_wp(player_car)
	})

	# AI
	for i in range(ai_cars.size()):
		var ai := ai_cars[i]
		cars.append({
			"car": ai,
			"progress": ai_laps[i] * total_wp + ai.current_wp,
			"dist": _distance_to_next_wp(ai)
		})

	# Sort by progress first, then distance
	cars.sort_custom(func(a, b):
		if a["progress"] != b["progress"]:
			return a["progress"] > b["progress"]
		return a["dist"] < b["dist"]
	)

	# Find player position
	for i in range(cars.size()):
		if cars[i]["car"] == player_car:
			return i + 1

	return 1




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

	# AI must ONLY use Cars.car_colors
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
				var mesh_instance: MeshInstance3D = child
				var mesh: Mesh = mesh_instance.mesh
				if mesh == null:
					return

				var surface_count: int = mesh.get_surface_count()

				# Create a brand-new material that ignores the original
				var new_mat: StandardMaterial3D = StandardMaterial3D.new()
				new_mat.albedo_color = random_color

				for s in range(surface_count):
					mesh_instance.set_surface_override_material(s, new_mat)


func force_player_camera():
	if player_car and player_car.has_node("Camera3D"):
		player_car.get_node("Camera3D").current = true

func _estimate_ai_finish_time(ai: CarController, ai_laps_done: int) -> int:
	# Base average lap time
	var avg_lap_time :float= ai.total_race_time / max(ai_laps_done, 1)
	var laps_left := total_laps - ai_laps_done

	# Progress inside current lap (0.0 to 1.0)
	var wp_count := ai.waypoints.size()
	var wp_progress := float(ai.current_wp) / float(max(wp_count - 1, 1))

	# Distance factor (closer to next waypoint = more progress)
	var dist := _distance_to_next_wp(ai)
	var dist_factor :float= clamp(1.0 - (dist / 200.0), 0.0, 1.0)

	# Combined progress (waypoint + distance)
	var lap_progress :float= clamp((wp_progress * 0.7) + (dist_factor * 0.3), 0.0, 1.0)

	# Remaining lap time reduced by progress
	var remaining_lap_time := int(avg_lap_time * (1.0 - lap_progress))

	# Total remaining time
	var remaining_time_ms := remaining_lap_time + int(avg_lap_time * (laps_left - 1))

	return ai.total_race_time + remaining_time_ms
