extends Node

var mode: String
var win_screen_radar: Node
var player_car: CarController

@onready var finish_flash := $FinishFlash
@onready var start_countdown := $Start
@onready var leaderboard := $Leaderboard if has_node("Leaderboard") else null
@onready var normal_hud:=$HUD
@onready var elimination_hud:=$EliminationHud

var best_radar_speed := 0

func _ready():
	mode = Modes.mode
	load_radar_best()
	Cars.load_color()
	MusicManager.play_race_music()
	$EliminationWinScreen.visible=false

	if mode == "Duel":
		_setup_duel()
	elif mode.to_lower() == "normal race":
		_setup_normal_race()
		
	elif mode == "Elimination":
		_setup_elimination()
	else:
		_spawn_player_free_drive()

	# Radar race win screen
	if mode == "Radar Race":
		var ws_scene = load("res://Scenes/win_screen_radar.tscn")
		win_screen_radar = ws_scene.instantiate()
		add_child(win_screen_radar)
		win_screen_radar.visible = false

	finish_flash.visible = false
	if leaderboard:
		leaderboard.visible = false

	start_countdown.start_countdown()

func _process(delta):
	if mode.to_lower() == "normal race":
		NormalRaceManager.update_race()
	elif mode == "Elimination":
		EliminationManager.update_race()

func _input(event):
	if event.is_action_pressed("pause_menu"):
		if has_node("PauseMenu"):
			$PauseMenu.toggle_pause()

# ---------------------------------------------------------
# FREE DRIVE
# ---------------------------------------------------------
func _spawn_player_free_drive():
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

	_apply_color_to_car(player_car, Cars.selected_color)

	var root := get_node(TrackName.track_name)
	player_car.global_transform = root.get_node("SpawnPoint").global_transform

	_force_player_camera()

# ---------------------------------------------------------
# DUEL
# ---------------------------------------------------------
func _setup_duel():
	var root := get_node(TrackName.track_name)

	DuelManager.player_spawn = root.get_node("SpawnPoint").global_position
	DuelManager.ai_spawn = root.get_node("AISpawnPoint").global_position

	DuelManager.player_car_path = Cars.selected_car
	DuelManager.ai_car_path = Cars.selected_ai_car

	if DuelManager.ai_car_path == "":
		DuelManager.ai_car_path = Cars.selected_car

	DuelManager.spawn_duel(self)
	DuelManager.main_scene = self

	player_car = DuelManager.player_car
	_force_player_camera()

# ---------------------------------------------------------
# NORMAL RACE
# ---------------------------------------------------------
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

	player_car = NormalRaceManager.player_car
	_force_player_camera()

# ---------------------------------------------------------
# ELIMINATION
# ---------------------------------------------------------
func _setup_elimination():
	if player_car:
		player_car.queue_free()
	player_car = null

	# Hide normal HUD
	normal_hud.visible=false

	var root := get_node(TrackName.track_name)

	EliminationManager.player_spawn = root.get_node("SpawnPoint").global_position

	EliminationManager.ai_spawns = []
	for i in range(1, 8):
		EliminationManager.ai_spawns.append(
			root.get_node("AISpawnPoint" + str(i)).global_position
		)

	EliminationManager.player_car_path = Cars.selected_car
	EliminationManager.ai_car_paths = Cars.get_ai_paths_for_class(Cars.selected_class)

	# Load elimination HUD
	var hud_scene := load("res://Scenes/elimination_hud.tscn")
	var hud :CanvasLayer= hud_scene.instantiate()
	hud.visible = false
	add_child(hud)

	EliminationManager.hud = hud
	EliminationManager.main_scene = self

	# Connect elimination signals
	EliminationManager.connect("player_eliminated", _on_player_eliminated)
	EliminationManager.connect("elimination_win", _on_elimination_win)

	# Spawn race
	EliminationManager.spawn_race(self)

	player_car = EliminationManager.player_car
	_force_player_camera()

	# Show HUD after countdown
	start_countdown.connect("countdown_finished", _on_elimination_countdown_finished)

func _on_elimination_countdown_finished():
	if EliminationManager.hud:
		EliminationManager.hud.visible = true

# ---------------------------------------------------------
# ELIMINATION SIGNAL HANDLERS
# ---------------------------------------------------------
func _on_player_eliminated():
	show_finish(false)

func _on_elimination_win(car):
	show_finish(true)

# ---------------------------------------------------------
# CAMERA
# ---------------------------------------------------------
func _force_player_camera():
	if not player_car:
		return

	for node in get_tree().get_nodes_in_group("cars"):
		if node is CarController and node != player_car:
			if node.has_node("Camera3D"):
				node.get_node("Camera3D").current = false

	if player_car.has_node("Camera3D"):
		player_car.get_node("Camera3D").current = true

# ---------------------------------------------------------
# COLOR
# ---------------------------------------------------------
func _apply_color_to_car(car: CarController, color: Color):
	if car.has_node("ModelRoot/Body"):
		var body = car.get_node("ModelRoot/Body")
		for child in body.get_children():
			if child is MeshInstance3D:
				var mat = child.get_active_material(0)
				if mat:
					mat.albedo_color = color

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
		var speed := int(round(car.velocity.length() * 3.6))

		if speed > best_radar_speed:
			best_radar_speed = speed
			save_radar_best()

		player_car.controls_enabled = false
		win_screen_radar.show_win(speed, best_radar_speed)

	finish_flash.flash()
	MusicManager.stop_music()
	_screech_to_halt()

func load_radar_best():
	if FileAccess.file_exists("user://radar_best.save"):
		var f := FileAccess.open("user://radar_best.save", FileAccess.READ)
		best_radar_speed = int(f.get_as_text())
		f.close()

func save_radar_best():
	var f := FileAccess.open("user://radar_best.save", FileAccess.WRITE)
	f.store_string(str(best_radar_speed))
	f.close()

# ---------------------------------------------------------
# GLOBAL AI DISABLE
# ---------------------------------------------------------
func disable_all_ai():
	for node in get_tree().get_nodes_in_group("cars"):
		if node is CarController:
			node.is_ai = false

func _screech_to_halt():
	for node in get_tree().get_nodes_in_group("cars"):
		if node is CarController:
			node.controls_enabled = false
			node.hard_frozen = true
			node.velocity = Vector3.ZERO

# ---------------------------------------------------------
# FINISH SCREEN
# ---------------------------------------------------------
func show_finish(player_won: bool):
	finish_flash.visible = true
	finish_flash.flash()

	_screech_to_halt()

	if leaderboard:
		leaderboard.visible = true
		leaderboard.show_results(player_won)

	if player_won:
		print("YOU WIN!")
	else:
		print("YOU LOSE!")
