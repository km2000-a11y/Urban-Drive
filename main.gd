extends Node

var mode: String
var win_screen_radar
var player_car: CarController

# ============================
# RADAR RACE
# ============================
var best_radar_speed: int = 0

# ============================
# DUEL MODE
# ============================
var duel_ai_car: CarController
var duel_player_laps := 0
var duel_ai_laps := 0
var duel_total_laps := 2
var duel_finished := false
var lap_cooldown := false

# ============================
# AI CAR DICTIONARY
# ============================
var ai_car_paths := {
	"Colossus Titan Max":"res://AI CARS/hummer_h1.tscn",
	"Colossus Behemoth":"res://AI CARS/hummer_h2.tscn",
	"Kuro Fortress":"res://AI CARS/lexus_lx470.tscn",
	"Straeda Pitbull":"res://AI CARS/vw_touareg_v10.tscn",
	"Schroder Atrix Q32":"res://AI CARS/audi_tt.tscn",
	"Straeda B32":"res://AI CARS/new_beetle.tscn",
	"Zenith Horizon":"res://AI CARS/nissan_350z.tscn",
	"Straeda G25":"res://AI CARS/golf_v_gti.tscn",
	"Kestrel Seabird":"res://AI CARS/lotus_exige_s.tscn",
	"Kestrel Speedster":"res://AI CARS/morgan_aero_8.tscn",
	"Berkshire Blunt":"res://AI CARS/jaguar_xkr.tscn",
	"Brutus Stingray":"res://AI CARS/chevrolet_corvette_c5.tscn",
	"Brutus Viper":"res://AI CARS/gt500.tscn",
	"Brutus Mauler":"res://AI CARS/chevelle_ss.tscn",
	"Eisenach Monarch":"res://AI CARS/bmw_750il.tscn",
	"Schroder Kaiser":"res://AI CARS/audi_a8.tscn",
	"Kuro Zephyr V6":"res://AI CARS/lexus_is350.tscn",
	"Kuro Supreme":"res://AI CARS/lexus_is_f.tscn",
	"Kuro Vault":"res://AI CARS/lexus_ls430.tscn",
	"Berkshire V12-S":"res://AI CARS/aston_db9.tscn",
	"Berkshire Tempest":"res://AI CARS/vanquish.tscn",
	"Eisenach Roadstar":"res://AI CARS/bmw_z4.tscn",
	"Bartoli Cruiser":"res://AI CARS/granturismo.tscn",
	"Kestrel Battleaxe":"res://AI CARS/sagaris.tscn",
	"Linetti Firestorm":"res://AI CARS/diablo_road.tscn",
	"Linetti Shepherd":"res://AI CARS/gallardo.tscn",
	"Linetti Terror":"res://AI CARS/murcielago.tscn",
	"Brutus Venom":"res://AI CARS/dodge_viper.tscn",
	"Kestrel Guillotine":"res://AI CARS/tvr_t_440r.tscn",
}

# ============================================================
# READY
# ============================================================
func _ready():
	mode = Modes.mode

	load_radar_best()
	spawn_player_car()

	if mode == "Radar Race":
		var ws_scene = load("res://Scenes/win_screen_radar.tscn")
		win_screen_radar = ws_scene.instantiate()
		add_child(win_screen_radar)
		win_screen_radar.visible = false

	if mode == "Duel":
		spawn_ai_car()

# ============================================================
# PLAYER CAR
# ============================================================
func spawn_player_car():
	var path = Cars.selected_car
	if path == "":
		push_error("No player car selected!")
		return

	var scene = load(path)
	if scene == null:
		push_error("Player car scene missing: " + path)
		return

	player_car = scene.instantiate()
	add_child(player_car)

	# Apply color
	if player_car.has_node("ModelRoot/Body"):
		var body = player_car.get_node("ModelRoot/Body")
		for child in body.get_children():
			if child is MeshInstance3D:
				var mat = child.get_active_material(0)
				if mat:
					mat.albedo_color = Cars.selected_color

	# Spawn
	if has_node("SpawnPoint"):
		player_car.global_transform = $SpawnPoint.global_transform

# ============================================================
# AI CAR
# ============================================================
func spawn_ai_car():
	var ai_name: String

	# If player selected a specific AI car
	if Cars.selected_ai_car != "":
		ai_name = Cars.selected_ai_car
	else:
		# Otherwise pick random AI car
		var keys = ai_car_paths.keys()
		ai_name = keys[randi() % keys.size()]

	print("AI SELECTED:", ai_name)

	if not ai_car_paths.has(ai_name):
		push_error("AI car not found in dictionary: " + ai_name)
		return

	var ai_path = ai_car_paths[ai_name]
	var ai_scene = load(ai_path)

	if ai_scene == null:
		push_error("AI scene missing: " + ai_path)
		return

	duel_ai_car = ai_scene.instantiate()
	add_child(duel_ai_car)

	# Spawn AI
	if has_node("AISpawnPoint"):
		duel_ai_car.global_transform = $AISpawnPoint.global_transform

# ============================================================
# LAP TRIGGER
# ============================================================
func _on_lap_line_body_entered(body):
	if lap_cooldown or duel_finished:
		return

	lap_cooldown = true
	_start_lap_cooldown()

	if body == player_car:
		duel_player_laps += 1

	if body == duel_ai_car:
		duel_ai_laps += 1

	_check_duel_finish()

func _start_lap_cooldown():
	await get_tree().create_timer(1.0).timeout
	lap_cooldown = false

# ============================================================
# DUEL FINISH
# ============================================================
func _check_duel_finish():
	if duel_player_laps >= duel_total_laps:
		_finish_duel(true)

	if duel_ai_laps >= duel_total_laps:
		_finish_duel(false)

func _finish_duel(player_won: bool):
	duel_finished = true
	player_car.controls_enabled = false
	duel_ai_car.ai_enabled = false
	_send_results_to_leaderboard()

# ============================================================
# LEADERBOARD
# ============================================================
func _send_results_to_leaderboard():
	RaceResults.clear()

	RaceResults.add_result(
		player_car.driver_name,
		player_car.car_name,
		player_car.total_race_time_ms
	)

	RaceResults.add_result(
		duel_ai_car.driver_name,
		duel_ai_car.car_name,
		duel_ai_car.total_race_time_ms
	)

	get_tree().change_scene_to_file("res://Scenes/Leaderboard.tscn")

# ============================================================
# RADAR TRAP
# ============================================================
func _on_radar_trap_body_entered(body):
	if mode != "Radar Race":
		return

	var car = body
	while car and not (car is CarController):
		car = car.get_parent()

	if car is CarController:
		var speed = int(round(car.velocity.length() * 3.6))

		if speed > best_radar_speed:
			best_radar_speed = speed
			save_radar_best()

		player_car.controls_enabled = false
		win_screen_radar.show_win(speed, best_radar_speed)

# ============================================================
# SAVE / LOAD
# ============================================================
func load_radar_best():
	if FileAccess.file_exists("user://radar_best.save"):
		var f = FileAccess.open("user://radar_best.save", FileAccess.READ)
		best_radar_speed = int(f.get_as_text())
		f.close()

func save_radar_best():
	var f = FileAccess.open("user://radar_best.save", FileAccess.WRITE)
	f.store_string(str(best_radar_speed))
	f.close()
