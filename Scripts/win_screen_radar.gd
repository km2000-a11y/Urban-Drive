extends CanvasLayer

var best_speed: int = 0

func show_win(speed: int):
	if speed > best_speed:
		best_speed = speed
		$Control/Panel/VBoxContainer/Label_Title.text = "YOU WIN!"
		$Control/Panel/VBoxContainer/Label_Speed.text = "NEW BEST: %d KM/H" % speed
	else:
		$Control/Panel/VBoxContainer/Label_Title.text = "YOU WIN!"
		$Control/Panel/VBoxContainer/Label_Speed.text = "SPEED: %d KM/H" % speed

	visible = true

func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()

func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mode_select.tscn")
