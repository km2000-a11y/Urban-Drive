extends CanvasLayer


func _on_bogota_airport_pressed():
	# Set the root node name of the track
	TrackName.track_name = "BogotaAirport"

	# Load main scene
	get_tree().change_scene_to_file("res://main.tscn")
