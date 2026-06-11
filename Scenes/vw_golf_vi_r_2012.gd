extends CarController

# COSMETIC INFO (UI only)
var car_name := "Straeda R20"
var country := "Germany"
var engine := "L4 2.0L Turbo"
var weight_kg := 1500
var zero_to_hundred_display := 5.50

func _ready():
	# GAMEPLAY STATS
	mass = 1500.0
	horsepower = 270
	max_rpm = 6500.0
	zero_to_hundred = 5.5
	top_speed_kmh = 250
	turn_speed = 2.8
	brake_strength = 11.2
	lateral_friction = 1.05
	transmission = "Four wheel drive"

	handling_type = "hot_hatch_awd"

	apply_stats()
	print("Child READY loaded:", car_name)
