extends CarController

# COSMETIC INFO (UI only)
var car_name := "Kuro Grandmaster"
var country := "Japan"
var engine := "V6 3.5L"
var weight_kg := 1680
var zero_to_hundred_display := 5.80

func _ready():
	# GAMEPLAY STATS
	mass = 1680.0
	horsepower = 306
	max_rpm = 6500.0
	zero_to_hundred = 5.8
	top_speed_kmh = 253
	turn_speed = 2.6
	brake_strength = 11.0
	lateral_friction = 1.03
	transmission = "Rear wheel drive"

	handling_type = "executive_sport"

	apply_stats()
	print("Child READY loaded:", car_name)
