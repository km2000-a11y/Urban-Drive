extends CanvasLayer

var best_speed: int = 0

func show_win(current_speed: int, saved_best: int):
	# Update internal best
	best_speed = saved_best

	if current_speed > best_speed:
		best_speed = current_speed
		$Control/Panel/VBoxContainer/Label_Title.text = "YOU WIN!"
		$Control/Panel/VBoxContainer/Label_Speed.text = "NEW BEST: %d KM/H" % current_speed
	else:
		$Control/Panel/VBoxContainer/Label_Title.text = "YOU WIN!"
		$Control/Panel/VBoxContainer/Label_Speed.text = "SPEED: %d KM/H\nBEST: %d KM/H" % [current_speed, best_speed]

	visible = true


func _on_retry_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/car_select.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mode_select.tscn")
