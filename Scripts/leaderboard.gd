extends CanvasLayer

@onready var title_label := $Control/Panel/TitleLabel
@onready var entries := $Control/VBoxContainer
@onready var retry_button := $Control/RetryBtn
@onready var quit_button := $Control/QuitBtn

func show_results(player_won: bool):
	# Set title
	if player_won:
		title_label.text = "YOU WIN!"
	else:
		title_label.text = "YOU LOSE!"

	# Clear old entries
	for child in entries.get_children():
		child.queue_free()

	# Get results from autoload
	var results := RaceResults.results

	# Sort by time (ascending)
	results.sort_custom(_sort_by_time)

	# Add each entry to the UI
	for i in range(results.size()):
		var r = results[i]

		var line := Label.new()
		line.text = str(i + 1) + ". " \
			+ r["name"] + " — " \
			+ r["car"] + " — " \
			+ _format_time(r["time"])

		entries.add_child(line)

	visible = true


func _sort_by_time(a, b):
	return a["time"] < b["time"]

func _format_time(ms: int) -> String:
	var total_seconds := ms / 1000.0
	var minutes := int(total_seconds / 60)
	var seconds := total_seconds - minutes * 60
	return "%02d:%05.2f" % [minutes, seconds]


func _on_retry_btn_pressed() -> void:
	get_tree().reload_current_scene()


func _on_quit_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mode_select.tscn")
