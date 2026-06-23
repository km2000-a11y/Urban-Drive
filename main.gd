extends Node

var mode: String
var win_screen_radar
var player_car: CarController

# ⭐ Saved best speed (loaded on startup)
var best_radar_speed: int = 0


# ============================================================
#  READY
# ============================================================
func _ready() -> void:
	mode = Modes.mode

	# Load saved best score
	load_radar_best()

	spawn_selected_car()

	# Load Radar Race UI
	if mode == "Radar Race":
		print("Radar Race mode active")

		var ws_scene = load("res://Scenes/win_screen_radar.tscn")
		win_screen_radar = ws_scene.instantiate()
		add_child(win_screen_radar)
		win_screen_radar.visible = false


# ============================================================
#  SAVE / LOAD SYSTEM (NO NEW FILES NEEDED)
# ============================================================
func load_radar_best():
	if FileAccess.file_exists("user://radar_best.save"):
		var f = FileAccess.open("user://radar_best.save", FileAccess.READ)
		best_radar_speed = int(f.get_as_text())
		f.close()
	else:
		best_radar_speed = 0

func save_radar_best():
	var f = FileAccess.open("user://radar_best.save", FileAccess.WRITE)
	f.store_string(str(best_radar_speed))
	f.close()


# ============================================================
#  SPAWN CAR
# ============================================================
func spawn_selected_car() -> void:
	var path: String = Cars.selected_car

	if path == "" or path == null:
		print("ERROR: No car selected!")
		return

	var car_scene := load(path)
	if car_scene == null:
		print("ERROR: Car scene not found at:", path)
		return

	var car: CarController = car_scene.instantiate()
	add_child(car)
	player_car = car   # ⭐ save reference

	# Apply saved color
	if car.has_node("ModelRoot/Body"):
		var body: Node3D = car.get_node("ModelRoot/Body")
		for child in body.get_children():
			if child is MeshInstance3D:
				var mat = child.get_active_material(0)
				if mat:
					mat.albedo_color = Cars.selected_color

	# Spawn position
	if has_node("SpawnPoint"):
		var sp: Node3D = $SpawnPoint
		car.global_transform = sp.global_transform

		if "spawn_yaw_deg" in car:
			car.rotate_y(deg_to_rad(car.spawn_yaw_deg))
	else:
		print("WARNING: No SpawnPoint found in main.tscn")


# ============================================================
#  RADAR TRAP
# ============================================================
func _on_radar_trap_body_entered(body: Node3D) -> void:
	if mode != "Radar Race":
		return

	var car = body

	# climb up until we find the CarController
	while car and not (car is CarController):
		car = car.get_parent()

	if car is CarController:
		var speed_kmh: float = car.velocity.length() * 3.6
		var speed_int: int = int(round(speed_kmh))
		print("TOP SPEED:", speed_int)

		# ⭐ Update best score
		if speed_int > best_radar_speed:
			best_radar_speed = speed_int
			save_radar_best()
			print("NEW RECORD:", best_radar_speed)
		else:
			print("BEST STILL:", best_radar_speed)

		# ⭐ Disable controls
		if player_car:
			player_car.controls_enabled = false

		# ⭐ Show Radar Race win screen (current + best)
		if win_screen_radar:
			win_screen_radar.show_win(speed_int, best_radar_speed)
