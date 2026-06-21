extends Node

var mode 
@onready var timer:=$Timer
@onready var timer_label:=$TimerLbl

func _ready():
	mode=Modes.mode
	spawn_selected_car()
	timer.start()
	
func _process(delta: float) -> void:
	timer_label.text=str(timer.time_left)
	
	
func spawn_selected_car():
	var path :String = Cars.selected_car
	if path == "" or path == null:
		print("ERROR: No car selected!")
		return

	var car_scene := load(path)
	if car_scene == null:
		print("ERROR: Car scene not found at:", path)
		return

	var car: CarController = car_scene.instantiate()
	add_child(car)

	# ⭐ APPLY SAVED COLOR HERE ⭐
	if car.has_node("ModelRoot/Body"):
		var body: Node3D = car.get_node("ModelRoot/Body")
		for child in body.get_children():
			if child is MeshInstance3D:
				var mat = child.get_active_material(0)
				if mat:
					mat.albedo_color = Cars.selected_color

	if has_node("SpawnPoint"):
		var sp: Node3D = $SpawnPoint

		# Base: match spawn point transform
		car.global_transform = sp.global_transform

		# Apply per-car yaw correction
		if "spawn_yaw_deg" in car:
			car.rotate_y(deg_to_rad(car.spawn_yaw_deg))
	else:
		print("WARNING: No SpawnPoint found in main.tscn")
		
