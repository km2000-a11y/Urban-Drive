extends Node

func _ready():
	spawn_selected_car()

func spawn_selected_car():
	var path :String= Cars.selected_car
	if path == "" or path == null:
		print("ERROR: No car selected!")
		return

	var car_scene := load(path)
	if car_scene == null:
		print("ERROR: Car scene not found at:", path)
		return

	var car: CarController = car_scene.instantiate()
	add_child(car)

	if has_node("SpawnPoint"):
		var sp: Node3D = $SpawnPoint

		# Base: match spawn point transformw
		car.global_transform = sp.global_transform

		# Apply per-car yaw correction
		if "spawn_yaw_deg" in car:
			car.rotate_y(deg_to_rad(car.spawn_yaw_deg))
	else:
		print("WARNING: No SpawnPoint found in main.tscn")
