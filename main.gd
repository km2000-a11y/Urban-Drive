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
# CAR CLASS → CAR LIST
# ============================
var car_classes := {
	"4x4 SUV": [
		"Straeda Pitbull",
		"Colossus Behemoth",
		"Kuro Fortress",
		"Colossus Titan Max"
	],
	"Compact Cars": [
		"Zenith Horizon",
		"Schroder Atrix Q32",
		"Straeda G25",
		"Straeda B32"
	],
	"Muscle Cars": [
		"Brutus Mauler",
		"Brutus Viper"
	],
	"Urban Racers": [
		"Brutus Stingray",
		"Kestrel Speedster",
		"Kestrel Seabird",
		"Kuro Zephyr V6",
		"Eisenach Roadstar"
	],
	"Sedans": [
		"Eisenach Monarch",
		"Schroder Kaiser",
		"Kuro Vault",
		"Kronstadt Blade"
	],
	"Sport Coupes": [
		"Berkshire Tempest",
		"Berkshire V12-S",
		"Bartoli Cruiser",
		"Kuro Supreme",
		"Berkshire Blunt"
	],
	"Sport Racing Cars": [
		"Kestrel Battleaxe",
		"Linetti Shepherd",
		"Brutus Venom"
	],
	"Supercars": [
		"Linetti Terror",
		"Linetti Firestorm",
		"Kestrel Guillotine"
	]
}

var car_class_map = {
	"Straeda Pitbull": "4x4 SUV",
	"Colossus Behemoth": "4x4 SUV",
	"Kuro Fortress": "4x4 SUV",
	"Colossus Titan Max": "4x4 SUV",

	"Zenith Horizon": "Compact Cars",
	"Schroder Atrix Q32": "Compact Cars",
	"Straeda G25": "Compact Cars",
	"Straeda B32": "Compact Cars",

	"Brutus Mauler": "Muscle Cars",
	"Brutus Viper": "Muscle Cars",

	"Brutus Stingray": "Urban Racers",
	"Kestrel Speedster": "Urban Racers",
	"Kestrel Seabird": "Urban Racers",
	"Kuro Zephyr V6": "Urban Racers",
	"Eisenach Roadstar": "Urban Racers",

	"Eisenach Monarch": "Sedans",
	"Schroder Kaiser": "Sedans",
	"Kuro Vault": "Sedans",
	"Kronstadt Blade": "Sedans",

	"Berkshire Tempest": "Sport Coupes",
	"Berkshire V12-S": "Sport Coupes",
	"Bartoli Cruiser": "Sport Coupes",
	"Kuro Supreme": "Sport Coupes",
	"Berkshire Blunt": "Sport Coupes",

	"Kestrel Battleaxe": "Sport Racing Cars",
	"Linetti Shepherd": "Sport Racing Cars",
	"Brutus Venom": "Sport Racing Cars",

	"Linetti Terror": "Supercars",
	"Linetti Firestorm": "Supercars",
	"Kestrel Guillotine": "Supercars"
}

# ============================
# CAR NAME → SCENE PATH
# ============================
var car_scene_paths := {
	"Colossus Titan Max":"res://Scenes/hummer_h1.tscn",
	"Colossus Behemoth":"res://Scenes/hummer_h2.tscn",
	"Kuro Fortress":"res://Scenes/lexus_lx470.tscn",
	"Straeda Pitbull":"res://Scenes/vw_touareg_v10.tscn",
	"Schroder Atrix Q32":"res://Scenes/audi_tt.tscn",
	"Straeda B32":"res://Scenes/new_beetle.tscn",
	"Zenith Horizon":"res://Scenes/nissan_350z.tscn",
	"Straeda G25":"res://Scenes/golf_v_gti.tscn",
	"Kestrel Seabird":"res://Scenes/lotus_exige_s.tscn",
	"Kestrel Speedster":"res://Scenes/morgan_aero_8.tscn",
	"Berkshire Blunt":"res://Scenes/jaguar_xkr.tscn",
	"Brutus Stingray":"res://Scenes/chevrolet_corvette_c5.tscn",
	"Brutus Viper":"res://Scenes/gt500.tscn",
	"Brutus Mauler":"res://Scenes/chevelle_ss.tscn",
	"Eisenach Monarch":"res://Scenes/bmw_750il.tscn",
	"Schroder Kaiser":"res://Scenes/audi_a8.tscn",
	"Kuro Zephyr V6":"res://Scenes/lexus_is350.tscn",
	"Kuro Supreme":"res://Scenes/lexus_is_f.tscn",
	"Kuro Vault":"res://Scenes/lexus_ls430.tscn",
	"Berkshire V12-S":"res://Scenes/aston_db9.tscn",
	"Berkshire Tempest":"res://Scenes/vanquish.tscn",
	"Eisenach Roadstar":"res://Scenes/bmw_z4.tscn",
	"Bartoli Cruiser":"res://Scenes/granturismo.tscn",
	"Kestrel Battleaxe":"res://Scenes/sagaris.tscn",
	"Linetti Firestorm":"res://Scenes/diablo_road.tscn",
	"Linetti Shepherd":"res://Scenes/gallardo.tscn",
	"Linetti Terror":"res://Scenes/murcielago.tscn",
	"Brutus Venom":"res://Scenes/dodge_viper.tscn",
	"Kestrel Guillotine":"res://Scenes/tvr_t_440r.tscn",
	"Kronstadt Blade":"res://Scenes/cls_350_cdi.tscn"
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

	if player_car.has_node("ModelRoot/Body"):
		var body = player_car.get_node("ModelRoot/Body")
		for child in body.get_children():
			if child is MeshInstance3D:
				var mat = child.get_active_material(0)
				if mat:
					mat.albedo_color = Cars.selected_color

	if has_node("SpawnPoint"):
		player_car.global_transform = $SpawnPoint.global_transform

# ============================================================
# AI CAR
# ============================================================
func spawn_ai_car():
	var ai_name: String

	# If player selected a specific AI car, use that
	if Cars.selected_ai_car != "":
		ai_name = Cars.selected_ai_car
	else:
		# Otherwise pick random AI car from same class as player
		var player_class :String= Cars.selected_class
		if player_class == "" or not car_classes.has(player_class):
			# Fallback: random from all cars
			var keys_all = car_scene_paths.keys()
			ai_name = keys_all[randi() % keys_all.size()]
		else:
			var list = car_classes[player_class]
			ai_name = list[randi() % list.size()]

	print("AI SELECTED:", ai_name)

	if not car_scene_paths.has(ai_name):
		push_error("AI car not found in scene dictionary: " + ai_name)
		return

	var ai_path = car_scene_paths[ai_name]
	var ai_scene = load(ai_path)

	if ai_scene == null:
		push_error("AI scene missing: " + ai_path)
		return

	duel_ai_car = ai_scene.instantiate()
	add_child(duel_ai_car)

	if has_node("AISpawnPoint"):
		duel_ai_car.global_transform = $AISpawnPoint.global_transform

	# Attach AI brain
	var ai_brain = load("res://Scripts/AIController.gd").new()
	duel_ai_car.add_child(ai_brain)
	ai_brain.car = duel_ai_car
	ai_brain.apply_pp_behavior(duel_ai_car.performance_points)

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

	# Disable AI by freezing its controls
	if duel_ai_car:
		duel_ai_car.controls_enabled = false

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
