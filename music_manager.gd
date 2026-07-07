extends Node

var player: AudioStreamPlayer

func _ready():
	player = AudioStreamPlayer.new()
	add_child(player)
	player.volume_db = -6
	
func play_menu_music():
	var path = "res://Songs/menu_track.mp3"

	# If already playing the same track, do nothing
	if player.stream and player.stream.resource_path == path and player.playing:
		return

	# Otherwise load and play
	player.stream = load(path)
	player.play()

func play_race_music():
	var path = "res://Songs/race_track.mp3"

	# If already playing the same track, do nothing
	if player.stream and player.stream.resource_path == path and player.playing:
		return

	player.stream = load(path)
	player.play()

func stop_music():
	player.stop()
