extends CanvasLayer

@onready var title_label := $Control/Panel/TitleLabel
@onready var retry_button := $Control/Panel/RetryBtn
@onready var quit_button := $Control/Panel/QuitBtn

func show_results(player_won: bool):
	if player_won:
		title_label.text = "YOU WIN!"
	else:
		title_label.text = "YOU LOSE!"

	visible = true


func _on_retry_btn_pressed() -> void:
	get_tree().reload_current_scene()


func _on_quit_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mode_select.tscn")
