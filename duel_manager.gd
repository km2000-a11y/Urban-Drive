extends Node

var player_car_path: String = ""
var ai_car_path: String = ""

var player_spawn: Vector3 = Vector3.ZERO
var ai_spawn: Vector3 = Vector3.ZERO

var player_car: CarController = null
var ai_car: CarController = null

var duel_active: bool = false
var winner: String = ""

var player_laps: int = 0
var ai_laps: int = 0
var total_laps: int = 2

var lap_cooldown: bool = false
var hud: Node = null
var player_finished: bool = false
var ai_finished: bool = false


var player_crossed_start: bool = false
var ai_crossed_start: bool = false
var main_scene: Node = null



func _process(delta):
	if duel_active:
		update_duel()


func spawn_duel(main_scene: Node) -> void:
	RaceResults.clear()
	ai_car_path = _pick_unique_ai_car()

	if player_car_path == "" or ai_car_path == "":
		push_error("DuelManager: Car paths not set!")
		return

	hud = main_scene.get_node("HUD")
	hud.update_lap(player_laps, total_laps)
	hud.update_position(2, 2)

	# PLAYER
	# PLAYER
		# PLAYER
	var player_scene := load(player_car_path)
	player_car = player_scene.instantiate() as CarController
	player_car.global_position = player_spawn
	player_car.is_ai = false
	player_car.controls_enabled = true

	player_car.driver_name = "Player"
	player_car.car_name = Cars.selected_car_name

	main_scene.add_child(player_car)
	_apply_player_color(player_car)

	player_laps = 0
	ai_laps = 0

	await get_tree().process_frame
	await get_tree().process_frame

	if player_car.has_node("Camera3D"):
		player_car.get_node("Camera3D").current = true


	# AI
	var ai_scene := load(ai_car_path)
	ai_car = ai_scene.instantiate() as CarController
	ai_car.global_position = ai_spawn
	ai_car.is_ai = true
	ai_car.controls_enabled = true
	main_scene.add_child(ai_car)
	_apply_random_ai_color(ai_car)

	ai_car.driver_name = ai_car.ai_names[randi() % ai_car.ai_names.size()]
	await get_tree().process_frame
	ai_car.car_name = Cars.selected_ai_car_name

	if ai_car.has_node("Camera3D"):
		ai_car.get_node("Camera3D").current = false

	# WAYPOINTS
	var wp_root := main_scene.find_child("Waypoints", true, false)
	player_car.set_waypoints(wp_root)
	ai_car.set_waypoints(wp_root)

	# START
	# START
	player_laps = 0
	ai_laps = 0
	player_crossed_start = false
	ai_crossed_start = false
	winner = ""
	duel_active = true

	# HUD MUST BE UPDATED AFTER START
	hud.update_lap(player_laps + 1, total_laps)
	hud.update_position(2, 2)


	print("DuelManager: Duel started.")
	MusicManager.stop_music()
	MusicManager.play_race_music()


func _pick_unique_ai_car() -> String:
	var cls: String = Cars.selected_class
	var list: Array = Cars.class_lists.get(cls, [])

	var filtered: Array = []
	for name in list:
		if name != Cars.selected_car_name:
			filtered.append(name)

	if filtered.size() == 0:
		Cars.selected_ai_car_name = Cars.selected_car_name
		return Cars.selected_car

	var chosen_name: String = filtered[randi() % filtered.size()]
	Cars.selected_ai_car_name = chosen_name

	return Cars.car_scene_paths[chosen_name]


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
					
func update_duel() -> void:
	if not duel_active:
		return

	# ❌ REMOVE extra lap logic from waypoints
	# _update_laps_from_progress()

	if not player_finished:
			
			hud.update_stopwatch(player_car.total_race_time)
			
	hud.update_lap(player_laps + 1, total_laps)
	hud.update_position(_calculate_position(), 2)
	_check_finish()


func register_lap(body: Node) -> void:
	if not duel_active or lap_cooldown:
		return

	var car := body
	while car != null and not (car is CarController):
		car = car.get_parent()

	if car == null:
		return

	lap_cooldown = true
	_start_lap_cooldown()

	if car == player_car:
		player_laps += 1
		print("Player lap:", player_laps)

		if player_laps == total_laps:
			player_finished = true

	elif car == ai_car:
		await get_tree().create_timer(0.15).timeout
		ai_laps += 1
		print("AI lap:", ai_laps)

		if ai_laps == total_laps:
			ai_finished = true


func _start_lap_cooldown() -> void:
	await get_tree().create_timer(1.0).timeout
	lap_cooldown = false


func _check_finish() -> void:
	# Player finishes → end immediately
	if player_finished:
		_end_duel("Player")
		return

	# AI finishes → DO NOT end duel
	if ai_finished:
		# Just mark AI finished, do nothing else
		return



func _end_duel(who_won: String) -> void:
	duel_active = false

	player_car.controls_enabled = false
	ai_car.controls_enabled = false

	var player_time := player_car.total_race_time
	var ai_time := _estimate_ai_finish_time()


	RaceResults.add_result(player_car.driver_name, player_car.car_name, player_time)
	RaceResults.add_result(ai_car.driver_name, ai_car.car_name, ai_time)

	main_scene.show_finish(who_won == "Player")
	hud.visible = false
	
	print("DEBUG PLAYER:",
		"driver=", player_car.driver_name,
		"car=", player_car.car_name,
		"time=", player_time
	)
	print("DEBUG AI:",
		"driver=", ai_car.driver_name,
		"car=", ai_car.car_name,
		"time=", ai_time
	)
	MusicManager.stop_music()



func _calculate_position() -> int:
	# LAP FIRST
	if player_laps > ai_laps:
		return 1
	elif ai_laps > player_laps:
		return 2

	# WAYPOINT INDEX
	var p_wp := player_car.current_wp
	var a_wp := ai_car.current_wp

	if p_wp > a_wp:
		return 1
	elif a_wp > p_wp:
		return 2

	# DISTANCE TO SAME WP
	var wp := player_car.waypoints[p_wp]
	var p_dist := player_car.global_position.distance_to(wp.global_position)
	var a_dist := ai_car.global_position.distance_to(wp.global_position)

	return 1 if p_dist < a_dist else 2


func _update_laps_from_progress() -> void:
	# keep here if you ever go back to WP1 system,
	# but it's NOT used with LapLine now
	if player_crossed_start and player_car.current_wp == 1:
		player_laps += 1
		player_crossed_start = false

	if ai_crossed_start and ai_car.current_wp == 1:
		ai_laps += 1
		ai_crossed_start = false
		
func _estimate_ai_finish_time() -> int:
	var lapline := main_scene.get_node("LapLine")

	var remaining_dist: float = ai_car.distance_to_finish_line(lapline)
	var ai_speed: float = ai_car.current_speed

	if ai_speed < 1.0:
		ai_speed = 1.0

	var remaining_time_ms: int = int((remaining_dist / ai_speed) * 1000)
	return ai_car.total_race_time + remaining_time_ms
