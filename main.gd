extends Node

func _ready():
	spawn_selected_car()

func spawn_selected_car():
	var path = Cars.selected_car
	if path == "" or path == null:
		print("ERROR: No car selected!")
		return

	var car_scene = load(path)
	if car_scene == null:
		print("ERROR: Car scene not found at:", path)
		return

	var car = car_scene.instantiate()
	add_child(car)

	# Move car to spawn point
	if has_node("SpawnPoint"):
		car.global_transform.origin = $SpawnPoint.global_transform.origin
	else:
		print("WARNING: No SpawnPoint found in main.tscn")
