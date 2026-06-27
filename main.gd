extends Node

var mode: String
var win_screen_radar
var player_car: CarController

var best_radar_speed: int = 0

# ---------------------------------------------------------
# CAR SCENE PATHS
# ---------------------------------------------------------

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
	"Gruber Targa":"res://Scenes/porsche_911_targa_993.tscn",
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
	"Kestrel Guillotine":"res://Scenes/tvr t 440r.tscn",
	"Kronstadt Blade":"res://Scenes/cls_350_cdi.tscn"
}

# ---------------------------------------------------------
# READY
# ---------------------------------------------------------

func _ready():
	mode = Modes.mode
	load_radar_best()

	# Only spawn player car in NON-DUEL modes
	if mode != "Duel":
		spawn_player_car()

	if mode == "Radar Race":
		var ws_scene = load("res://Scenes/win_screen_radar.tscn")
		win_screen_radar = ws_scene.instantiate()
		add_child(win_screen_radar)
		win_screen_radar.visible = false

	if mode == "Duel":
		_setup_duel()


func _process(delta):
	if mode == "Duel":
		DuelManager.update_duel()


# ---------------------------------------------------------
# PLAYER CAR SPAWN
# ---------------------------------------------------------

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

	# Assign player car to speedometer (CanvasLayer root)
	if has_node("Speedometer"):
		var speedo = get_node("Speedometer")
		speedo.target_car = player_car

	# Apply selected color
	if player_car.has_node("ModelRoot/Body"):
		var body = player_car.get_node("ModelRoot/Body")
		for child in body.get_children():
			if child is MeshInstance3D:
				var mat = child.get_active_material(0)
				if mat:
					mat.albedo_color = Cars.selected_color

	# Spawn position
	if has_node("SpawnPoint"):
		player_car.global_transform = $SpawnPoint.global_transform

	# Activate player camera
	if player_car.has_node("Camera3D"):
		player_car.get_node("Camera3D").current = true


# ---------------------------------------------------------
# DUEL MODE SETUP
# ---------------------------------------------------------

func _setup_duel():
	DuelManager.player_spawn = $SpawnPoint.global_position
	DuelManager.ai_spawn = $AISpawnPoint.global_position

	DuelManager.player_car_path = Cars.selected_car
	DuelManager.ai_car_path = Cars.selected_ai_car

	# If AI car not selected → just pick same car as player
	if DuelManager.ai_car_path == "":
		DuelManager.ai_car_path = Cars.selected_car

	DuelManager.spawn_duel(self)


# ---------------------------------------------------------
# RADAR RACE
# ---------------------------------------------------------

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


# ---------------------------------------------------------
# SAVE / LOAD
# ---------------------------------------------------------

func load_radar_best():
	if FileAccess.file_exists("user://radar_best.save"):
		var f = FileAccess.open("user://radar_best.save", FileAccess.READ)
		best_radar_speed = int(f.get_as_text())
		f.close()

func save_radar_best():
	var f = FileAccess.open("user://radar_best.save", FileAccess.WRITE)
	f.store_string(str(best_radar_speed))
	f.close()
