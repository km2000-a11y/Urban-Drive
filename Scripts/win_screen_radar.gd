extends CanvasLayer

func show_win(success: bool):
	if success:
		$Control/Panel/VBoxContainer/Label_Title.text = "YOU WIN!"
	else:
		$Control/Panel/VBoxContainer/Label_Title.text = "YOU LOSE!"

	visible = true


func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mode_select.tscn")
