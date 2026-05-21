extends CharacterBody3D

var gravity_force:=12.0
@export var car_name: String
@export var country: String
@export var transmission:  String
@export var engine: String

@export var horsepower: int
@export var weight_kg: int
@export var zero_to_hundred: float
@export var top_speed: int
@export var price: int

@export var max_speed: float
@export var acceleration: float
@export var brake_force: float
@export var turn_speed: float
@export var grip: float
@export var drift_grip: float
@export var weight: float
@export var drivetrain_type: String

func _physics_process(delta: float) -> void:
	velocity.y-=gravity_force*delta
	
	var input_forward:=Input.get_action_strength("accelerate") - Input.get_action_strength("brake")
	var input_turm:=Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")
	if input_forward>0.0:
		velocity+=-transform.basis.z*acceleration*delta
	elif input_forward<0.0:
		velocity+=transform.basis.z*brake_force*delta
		
	print("VEC AFTER ACCEL: ",velocity)
	print(is_on_floor())

	
	var horizontal_vel:=Vector3(velocity.x,0.0,velocity.z)
	
	if horizontal_vel.z>0:
		horizontal_vel.z=0
	if horizontal_vel.length()>max_speed:
		horizontal_vel=horizontal_vel.normalized()*max_speed
		velocity.x=horizontal_vel.x
		velocity.z=horizontal_vel.z
		
	var speed_ratio:=horizontal_vel.move_toward(Vector3.ZERO, grip*delta)
	velocity.x=horizontal_vel.x
	velocity.z=horizontal_vel.z
	
	print("VELOCITY BEFORE MOVE: ", velocity)
	move_and_slide()
	
	print("FORWARD DIR: ",-transform.basis.z)
	print("ACCEL INPUT: ", Input.get_action_strength("accelerate"))
