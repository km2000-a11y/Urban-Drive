extends Node

# ---------------------------------------------------------
# CONFIG (set by main.gd)
# ---------------------------------------------------------

var player_car_path: String = ""
var ai_car_path: String = ""

var player_spawn: Vector3 = Vector3.ZERO
var ai_spawn: Vector3 = Vector3.ZERO

var player_car: Node3D = null
var ai_car: Node3D = null

var duel_active := false
var winner := ""

var player_laps := 0
var ai_laps := 0
var total_laps := 2
var lap_cooldown := false


# ---------------------------------------------------------
# SPAWN DUEL
# ---------------------------------------------------------

func spawn_duel(main_scene: Node):
	# If AI car not set → pick unique car from same class
	if ai_car_path == "":
		ai_car_path = _pick_unique_ai_car()

	if player_car_path == "" or ai_car_path == "":
		push_error("DuelManager: Car paths not set!")
		return

	# --- Spawn Player ---
	player_car = load(player_car_path).instantiate()
	player_car.global_position = player_spawn
	main_scene.add_child(player_car)

	# --- Spawn AI ---
	ai_car = load(ai_car_path).instantiate()
	ai_car.global_position = ai_spawn
	main_scene.add_child(ai_car)

	_setup_player()
	_setup_ai()

	duel_active = true
	winner = ""

	print("DuelManager: Duel started.")


# ---------------------------------------------------------
# AI CAR SELECTION (same class, unique)
# ---------------------------------------------------------

func _pick_unique_ai_car() -> String:
	var cls = Cars.selected_class
	var list = Cars.class_lists.get(cls, [])

	# Remove player car from list
	var filtered := []
	for name in list:
		if name != Cars.selected_car_name:
			filtered.append(name)

	# If class has only one car → AI uses same car
	if filtered.size() == 0:
		return Cars.selected_car

	# Pick random unique car
	var chosen = filtered[randi() % filtered.size()]
	return Cars.car_scene_paths[chosen]


# ---------------------------------------------------------
# PLAYER SETUP
# ---------------------------------------------------------

func _setup_player():
	if player_car == null:
		return

	if player_car.has_node("CarController"):
		player_car.get_node("CarController").set_process(true)

	if player_car.has_node("AIController"):
		player_car.get_node("AIController").set_process(false)

	if player_car.has_node("Camera3D"):
		player_car.get_node("Camera3D").current = true


# ---------------------------------------------------------
# AI SETUP
# ---------------------------------------------------------

func _setup_ai():
	if ai_car == null:
		return

	if ai_car.has_node("AIController"):
		ai_car.get_node("AIController").set_process(true)

	if ai_car.has_node("CarController"):
		ai_car.get_node("CarController").set_process(false)

	if ai_car.has_node("Camera3D"):
		ai_car.get_node("Camera3D").current = false


# ---------------------------------------------------------
# UPDATE LOOP
# ---------------------------------------------------------

func update_duel():
	if not duel_active:
		return
	pass


# ---------------------------------------------------------
# LAP HANDLING
# ---------------------------------------------------------

func register_lap(body):
	if not duel_active:
		return
	if lap_cooldown:
		return

	lap_cooldown = true
	_start_lap_cooldown()

	if body == player_car:
		player_laps += 1
		print("Player lap:", player_laps)

	if body == ai_car:
		ai_laps += 1
		print("AI lap:", ai_laps)

	_check_finish()


func _start_lap_cooldown():
	await get_tree().create_timer(1.0).timeout
	lap_cooldown = false


func _check_finish():
	if player_laps >= total_laps:
		_end_duel("Player")

	if ai_laps >= total_laps:
		_end_duel("AI")


# ---------------------------------------------------------
# END DUEL
# ---------------------------------------------------------

func _end_duel(who_won: String):
	if not duel_active:
		return

	duel_active = false
	winner = who_won

	print("DuelManager: Winner =", winner)

	if player_car and player_car.has_node("CarController"):
		player_car.get_node("CarController").set_process(false)

	if ai_car and ai_car.has_node("AIController"):
		ai_car.get_node("AIController").set_process(false)

	if get_tree().current_scene.has_node("UI"):
		get_tree().current_scene.get_node("UI").show_winner(winner)
