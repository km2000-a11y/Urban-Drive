extends VehicleBody3D

@export var stats: CarStats
@export var car_model_scene: PackedScene

var car_model: Node3D

# ---------------------------------------------------------
#  RUNTIME CAR DATABASES (EXPLICITLY LOADED)
#  → KEYS MATCH FILE NAMES
# ---------------------------------------------------------
var car_models := {
	"abarth_500": preload("res://Cars/abarth_500.tscn"),
}

var car_stats := {
	"abarth_500": preload("res://Car Stats/abarth_500.tres"),
}

var car_list := [
	"abarth_500",
	"golf",
	"mini",
	"beetle",
	"tt",
	"350z",
	"slk",
	"rs5",
	"charger",
	"mustang",
	"1967_shelby",
	"cls",
	"v8_vantage",
	"granturismo",
	"db9",
	"hummer",
	"expedition",
	"elise",
	"corvette",
	"gallardo",
	"diablo",
	"murcielago",
	"zonda",
	"f1",
	"ccxr"
]

# ---------------------------------------------------------
#  WHEEL REFERENCES (PHYSICS WHEELS)
# ---------------------------------------------------------
@onready var w_fl = $WheelFL
@onready var w_fr = $WheelFR
@onready var w_rl = $WheelRL
@onready var w_rr = $WheelRR

@onready var rev = $RevPlayer
@onready var skid = $SkidPlayer
@onready var crash = $CrashPlayer
@onready var braker = $BrakePlayer

# ---------------------------------------------------------
#  READY
# ---------------------------------------------------------
func _ready():
	switch_car(car_list[0])

# ---------------------------------------------------------
#  LOAD CAR MODEL
# ---------------------------------------------------------
func load_car_model():
	if car_model:
		car_model.queue_free()

	car_model = car_model_scene.instantiate()
	$ModelRoot.add_child(car_model)

	align_wheels_to_model() # physics wheels move ONCE

# ---------------------------------------------------------
#  APPLY CAR STATS
# ---------------------------------------------------------
func apply_stats():
	if stats == null:
		return

	mass = stats.weight

	w_fl.wheel_friction_slip = stats.traction
	w_fr.wheel_friction_slip = stats.traction
	w_rl.wheel_friction_slip = stats.traction
	w_rr.wheel_friction_slip = stats.traction

# ---------------------------------------------------------
#  PHYSICS LOOP
# ---------------------------------------------------------
func _physics_process(delta):
	handle_input(delta)
	update_visual_wheels()

# ---------------------------------------------------------
#  INPUT HANDLING
# ---------------------------------------------------------
func handle_input(delta):
	if stats == null:
		return

	var throttle := Input.get_action_strength("accelerate")
	var brake := Input.get_action_strength("brake")
	var steer := Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")

	var steer_angle := deg_to_rad(stats.handling * 2.5)
	w_fl.steering = steer * steer_angle
	w_fr.steering = steer * steer_angle

	var speed := linear_velocity.length()
	if speed > stats.max_speed:
		throttle = 0.0

	var accel_force := throttle * stats.acceleration * 1800.0

	match stats.drivetrain:
		"FWD":
			w_fl.engine_force = accel_force
			w_fr.engine_force = accel_force
			w_rl.engine_force = 0
			w_rr.engine_force = 0
		"RWD":
			w_fl.engine_force = 0
			w_fr.engine_force = 0
			w_rl.engine_force = accel_force
			w_rr.engine_force = accel_force
		"AWD":
			var f := accel_force * 0.5
			w_fl.engine_force = f
			w_fr.engine_force = f
			w_rl.engine_force = f
			w_rr.engine_force = f

	var brake_force := brake * stats.brake_strength * 2000.0
	w_fl.brake = brake_force
	w_fr.brake = brake_force
	w_rl.brake = brake_force
	w_rr.brake = brake_force

# ---------------------------------------------------------
#  WHEEL ALIGNMENT (MODEL → PHYSICS) — RUNS ONCE
# ---------------------------------------------------------
func align_wheels_to_model():
	if not car_model:
		return

	var m := car_model

	w_fl.global_transform.origin = m.get_node("WheelPos/WheelFL_Pos").global_transform.origin
	w_fr.global_transform.origin = m.get_node("WheelPos/WheelFR_Pos").global_transform.origin
	w_rl.global_transform.origin = m.get_node("WheelPos/WheelRL_Pos").global_transform.origin
	w_rr.global_transform.origin = m.get_node("WheelPos/WheelRR_Pos").global_transform.origin

# ---------------------------------------------------------
#  VISUAL WHEEL SYNC (PHYSICS → MODEL)
# ---------------------------------------------------------
func update_visual_wheels():
	if not car_model:
		return

	var m := car_model

	m.get_node("Wheels/WheelFL_Mesh").global_transform = w_fl.global_transform
	m.get_node("Wheels/WheelFR_Mesh").global_transform = w_fr.global_transform
	m.get_node("Wheels/WheelRL_Mesh").global_transform = w_rl.global_transform
	m.get_node("Wheels/WheelRR_Mesh").global_transform = w_rr.global_transform

# ---------------------------------------------------------
#  SWITCH CAR BY ID
# ---------------------------------------------------------
func switch_car(car_id: String):
	if not car_models.has(car_id) or not car_stats.has(car_id):
		push_error("Car ID not found: " + car_id)
		return

	car_model_scene = car_models[car_id]
	stats = car_stats[car_id]

	load_car_model()
	apply_stats()
