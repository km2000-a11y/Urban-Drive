extends CanvasLayer

func _on_time_trial_btn_pressed() -> void:
	Modes.mode="Time trial"
	get_tree().change_scene_to_file("res://Scenes/car_select.tscn")
