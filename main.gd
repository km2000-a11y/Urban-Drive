extends Node

var mode: String
var win_screen_radar: Node
var player_car: CarController

@onready var finish_flash := $FinishFlash
@onready var start_countdown := $Start
@onready var leaderboard := $Leaderboard if has_node("Leaderboard") else null

var best_radar_speed := 0


func _ready():
	mode = Modes.mode
	load_radar_best()
	Cars.load_color()
	MusicManager.play_race_music()

	# Spawn depending on mode
	if mode == "Duel":
		_setup_duel()
	elif mode.to_lower() == "normal race":
		_setup_normal_race()
	else:
		spawn_player_car()


	# Radar race win screen
	if mode == "Radar Race":
		var ws_scene = load("res://Scenes/win_screen_radar.tscn")
		win_screen_radar = ws_scene.instantiate()
		add_child(win_screen_radar)
		win_screen_radar.visible = false

	# Hide UI at start
	finish_flash.visible = false
	if leaderboard:
		leaderboard.visible = false

	# Start countdown
	start_countdown.start_countdown()

func _process(delta):
	if mode == "Normal Race":
		NormalRaceManager.update_race()



func spawn_player_car():
	var path := Cars.selected_car
	if path == "":
		push_error("No player car selected!")
		return

	var scene := load(path)
	if scene == null:
		push_error("Player car scene missing: " + path)
		return

	player_car = scene.instantiate()
	add_child(player_car)

	if has_node("Speedometer"):
		get_node("Speedometer").target_car = player_car

	if mode != "Duel":
		_apply_color_to_car(player_car, Cars.selected_color)

	# ⭐ FIXED — no more has_node()
	var root := get_node(TrackName.track_name)
	player_car.global_transform = root.get_node("SpawnPoint").global_transform

	if player_car.has_node("Camera3D"):
		player_car.get_node("Camera3D").current = true



func _setup_duel():
	var root := get_node(TrackName.track_name)

	# OPTION 1 — DuelManager uses Vector3
	DuelManager.player_spawn = root.get_node("SpawnPoint").global_position
	DuelManager.ai_spawn = root.get_node("AISpawnPoint").global_position

	DuelManager.player_car_path = Cars.selected_car
	DuelManager.ai_car_path = Cars.selected_ai_car

	if DuelManager.ai_car_path == "":
		DuelManager.ai_car_path = Cars.selected_car

	DuelManager.spawn_duel(self)
	DuelManager.main_scene = self

	start_countdown.start_countdown()



func _apply_color_to_car(car: CarController, color: Color):
	if car.has_node("ModelRoot/Body"):
		var body = car.get_node("ModelRoot/Body")
		for child in body.get_children():
			if child is MeshInstance3D:
				var mat = child.get_active_material(0)
				if mat:
					mat.albedo_color = color


func _on_radar_trap_body_entered(body):
	if mode != "Radar Race":
		return

	var car = body
	while car and not (car is CarController):
		car = car.get_parent()

	if car is CarController:
		var speed := int(round(car.velocity.length() * 3.6))

		if speed > best_radar_speed:
			best_radar_speed = speed
			save_radar_best()

		player_car.controls_enabled = false
		win_screen_radar.show_win(speed, best_radar_speed)


func load_radar_best():
	if FileAccess.file_exists("user://radar_best.save"):
		var f := FileAccess.open("user://radar_best.save", FileAccess.READ)
		best_radar_speed = int(f.get_as_text())
		f.close()


func save_radar_best():
	var f := FileAccess.open("user://radar_best.save", FileAccess.WRITE)
	f.store_string(str(best_radar_speed))
	f.close()

func _setup_normal_race():
	if player_car:
		player_car.queue_free()
	player_car = null

	var root := get_node(TrackName.track_name)

	NormalRaceManager.player_spawn = root.get_node("SpawnPoint").global_position
	NormalRaceManager.player_car_path = Cars.selected_car

	NormalRaceManager.ai_spawns = []
	for i in range(1, 8):
		NormalRaceManager.ai_spawns.append(
			root.get_node("AISpawnPoint" + str(i)).global_position
		)

	NormalRaceManager.ai_car_paths = Cars.get_ai_paths_for_class(Cars.selected_class)

	NormalRaceManager.spawn_race(self)

	# ⭐ FIX: main scene must know the actual player car
	player_car = NormalRaceManager.player_car

	# ⭐ FIX: now assign camera safely
	if player_car and player_car.has_node("Camera3D"):
		var cam = player_car.get_node("Camera3D")
		player_car.get_node("Camera3D").current = true
		cam.current = true

func disable_all_ai():
	for node in get_tree().get_nodes_in_group("cars"):
		if node is CarController:
			node.is_ai = false


# ---------------------------------------------------------
# FINISH + LEADERBOARD FIXED
# ---------------------------------------------------------
func show_finish(player_won: bool):
	# Show flash
	finish_flash.visible = true
	finish_flash.flash()

	# Show leaderboard
	if leaderboard:
		leaderboard.visible = true
		leaderboard.show_results(player_won)

	# Debug print
	if player_won:
		print("YOU WIN!")
	else:
		print("YOU LOSE!")
