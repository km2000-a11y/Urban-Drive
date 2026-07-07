extends CanvasLayer

func _ready():
	MusicManager.play_menu_music()

func _on_free_race_menu_pressed() -> void:
	GameMode.game_mode = "Free Race"
	get_tree().change_scene_to_file("res://Scenes/mode_select.tscn")
