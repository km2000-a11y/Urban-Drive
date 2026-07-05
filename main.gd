extends Node

var mode: String
var win_screen_radar
var player_car: CarController

var best_radar_speed := 0

func _ready():
	mode = Modes.mode
	load_radar_best()
	Cars.load_color()
	disable_all_ai()

	if mode == "Duel":
		_setup_duel()
	else:
		spawn_player_car()

	if mode == "Radar Race":
		var ws_scene = load("res://Scenes/win_screen_radar.tscn")
		win_screen_radar = ws_scene.instantiate()
		add_child(win_screen_radar)
		win_screen_radar.visible = false


func _process(delta):
	# DuelManager now handles its own _process and HUD updates.
	# No duel logic here.
	pass


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
		var speedo = get_node("Speedometer")
		speedo.target_car = player_car

	if mode != "Duel":
		_apply_color_to_car(player_car, Cars.selected_color)

	if has_node("SpawnPoint"):
		player_car.global_transform = $SpawnPoint.global_transform

	if player_car.has_node("Camera3D"):
		player_car.get_node("Camera3D").current = true


func _setup_duel():
	DuelManager.player_spawn = $SpawnPoint.global_position
	DuelManager.ai_spawn = $AISpawnPoint.global_position

	DuelManager.player_car_path = Cars.selected_car
	DuelManager.ai_car_path = Cars.selected_ai_car

	if DuelManager.ai_car_path == "":
		DuelManager.ai_car_path = Cars.selected_car

	DuelManager.spawn_duel(self)


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


func disable_all_ai():
	for node in get_tree().get_nodes_in_group("cars"):
		if node is CarController:
			node.is_ai = false
			
