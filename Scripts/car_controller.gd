extends VehicleBody3D

@export var car_name: String
@export var engine: String
@export var drivetrain: String
@export var horsepower: int
@export var top_speed: float
@export var zero_to_hundred: float
@export var weight: float

@export var max_speed: float
@export var acceleration: float
@export var handling: float
@export var traction: float
@export var brake_strength: float

@export var country_of_origin: String = ""

@export var downforce: float = 1.0

const MAX_STEER=0.8

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _process(delta):
	steering=move_toward(steering,Input.get_axis("turn_right", "turn_left")*MAX_STEER, delta*2.5)
	var throttle=Input.get_axis("accelerate", "brake")
	var accel_force=throttle*acceleration*1800.0
	if Input.is_action_just_pressed("pause_menu"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
