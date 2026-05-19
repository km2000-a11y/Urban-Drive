extends VehicleBody3D

@export var car_name:String
@export var country_of_origin:String
@export var transmission:String
@export var engine:String

@export var top_speed:int
@export var horsepower:int
@export var zero_to_hundred:float
@export var weight:int

@export var max_speed: float
@export var acceleration: int
@export var handling: float
@export var traction:float
@export var brake_strength:float
@export var turn_rate: float
@export var downforce: float

func _physics_process(delta):
	var forward = -global_transform.basis.z
	print("FORWARD = ", forward)
	engine_force=horsepower*10*Input.get_action_strength("accelerate")
	brake=brake_strength*Input.get_action_strength("brake")
	var steer_target=turn_rate*(Input.get_action_strength("turn_right")-Input.get_action_strength("turn_left"))
