extends CanvasLayer

func _ready():
	MusicManager.play_menu_music()

func _on_radar_race_btn_pressed() -> void:
	Modes.mode = "Radar Race"
	get_tree().change_scene_to_file("res://Scenes/car_select.tscn")

func _on_duel_btn_pressed() -> void:
	Modes.mode = "Duel"
	get_tree().change_scene_to_file("res://Scenes/car_select.tscn")

func _on_normal_race_btn_pressed() -> void:
	Modes.mode = "Normal Race"
	get_tree().change_scene_to_file("res://Scenes/car_select.tscn")

func _on_elimination_btn_pressed() -> void:
	Modes.mode = "Elimination"
	get_tree().change_scene_to_file("res://Scenes/car_select.tscn")

func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_cop_chase_btn_pressed() -> void:
	Modes.mode = "Cop Chase"

	# Fixed: your actual police car scene
	Cars.selected_car = "res://Scenes/granturismo_police.tscn"

	# Fixed: your actual car name
	Cars.selected_car_name = "Bartoli Cruiser Interceptor"

	# Go straight into the race
	get_tree().change_scene_to_file("res://Scenes/track_select.tscn")
