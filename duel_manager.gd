extends Node

var player_car_path: String = ""
var ai_car_path: String = ""

var player_spawn: Vector3 = Vector3.ZERO
var ai_spawn: Vector3 = Vector3.ZERO

var player_car: CarController = null
var ai_car: CarController = null

var duel_active: bool = false
var winner: String = ""

var player_laps: int = 1
var ai_laps: int = 1
var total_laps: int = 2
var lap_cooldown: bool = false
var hud: Node = null
var player_crossed_start: bool = false
var ai_crossed_start: bool = false





func _process(delta):
	if duel_active:
		update_duel()


func spawn_duel(main_scene: Node) -> void:
	ai_car_path = _pick_unique_ai_car()

	if player_car_path == "" or ai_car_path == "":
		push_error("DuelManager: Car paths not set!")
		return
	hud = main_scene.get_node("HUD")
	hud.update_lap(player_laps, total_laps)
	hud.update_position(2, 2)   # Player starts in 2nd place


	# -----------------------------------------------------
	# PLAYER CAR
	# -----------------------------------------------------
	var player_scene := load(player_car_path)
	player_car = player_scene.instantiate() as CarController
	player_car.global_position = player_spawn
	player_car.is_ai = false
	player_car.controls_enabled = true

	main_scene.add_child(player_car)
	_apply_player_color(player_car)

	if player_car.has_node("Camera3D"):
		player_car.get_node("Camera3D").current = true

	# -----------------------------------------------------
	# AI CAR
	# -----------------------------------------------------
	var ai_scene := load(ai_car_path)
	ai_car = ai_scene.instantiate() as CarController
	ai_car.global_position = ai_spawn
	ai_car.is_ai = true
	ai_car.controls_enabled = true

	main_scene.add_child(ai_car)
	_apply_random_ai_color(ai_car)

	if ai_car.has_node("Camera3D"):
		ai_car.get_node("Camera3D").current = false

	# -----------------------------------------------------
	# ASSIGN WAYPOINTS (AFTER cars exist!)
	# -----------------------------------------------------
	var wp_root := main_scene.find_child("Waypoints", true, false)
	print("WAYPOINT ROOT =", wp_root)

	player_car.set_waypoints(wp_root)
	ai_car.set_waypoints(wp_root)

	# -----------------------------------------------------
	# START DUEL
	# -----------------------------------------------------
		# -----------------------------------------------------
	# START DUEL
	# -----------------------------------------------------
	player_laps = 1
	ai_laps = 1
	player_crossed_start = false
	ai_crossed_start = false
	winner = ""
	duel_active = true

	print("DuelManager: Duel started.")


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
	var name := Cars.selected_ai_car_name

	# If AI uses the same car as the player, DO NOT recolor it
	if name == Cars.selected_car_name:
		print("[AI] Same car as player, skipping AI color.")
		return

	# Apply random color from palette
	if Cars.car_colors.has(name):
		var palette: Array = Cars.car_colors[name]
		var random_color: Color = palette[randi() % palette.size()]

		if car.has_node("ModelRoot/Body"):
			var body := car.get_node("ModelRoot/Body")
			for child in body.get_children():
				if child is MeshInstance3D:
					var mat :Material= child.get_active_material(0)
					if mat is BaseMaterial3D:
						# Duplicate material so AI recolor NEVER affects player
						mat = mat.duplicate()
						child.set_surface_override_material(0, mat)
						mat.albedo_color = random_color

		print("[AI] Random color for", name, "=", random_color)

func update_duel() -> void:
	if not duel_active:
		return

	_update_laps_from_progress()   # ← ADD THIS LINE

	hud.update_stopwatch(player_car.total_race_time)
	hud.update_lap(player_laps, total_laps)
	hud.update_position(_calculate_position(), 2)


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
		player_crossed_start = true

	elif car == ai_car:
		ai_crossed_start = true
		

func _start_lap_cooldown() -> void:
	await get_tree().create_timer(1.0).timeout
	lap_cooldown = false


func _check_finish() -> void:
	if player_laps > total_laps:
		_end_duel("Player")
	elif ai_laps > total_laps:
		_end_duel("AI")



func _end_duel(who_won: String) -> void:
	if not duel_active:
		return

	duel_active = false
	winner = who_won

	print("DuelManager: Winner =", winner)

	if player_car != null:
		player_car.controls_enabled = false

	if ai_car != null:
		ai_car.controls_enabled = false

func _calculate_position() -> int:
	# 1. Lap comparison
	_update_laps_from_progress()
	if player_laps > ai_laps:
		return 1
	elif ai_laps > player_laps:
		return 2

	# 2. Waypoint index comparison
	var p_wp := player_car.current_wp
	var a_wp := ai_car.current_wp

	if p_wp > a_wp:
		return 1
	elif a_wp > p_wp:
		return 2

	# 3. Distance comparison (same waypoint)
	var wp := player_car.waypoints[p_wp]
	var p_dist := player_car.global_position.distance_to(wp.global_position)
	var a_dist := ai_car.global_position.distance_to(wp.global_position)

	if p_dist < a_dist:
		return 1
	return 2
	
func _update_laps_from_progress() -> void:
	# PLAYER
	if player_crossed_start and player_car.current_wp == 1:
		player_laps += 1
		player_crossed_start = false
		print("Player lap:", player_laps)

	# AI
	if ai_crossed_start and ai_car.current_wp == 1:
		ai_laps += 1
		ai_crossed_start = false
		print("AI lap:", ai_laps)
