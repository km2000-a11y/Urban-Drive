extends CanvasLayer

func _on_radar_race_btn_pressed() -> void:
	Modes.mode="Radar Race"
	get_tree().change_scene_to_file("res://Scenes/car_select.tscn")
