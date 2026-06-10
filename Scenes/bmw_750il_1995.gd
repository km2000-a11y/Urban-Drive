extends CarController

# COSMETIC INFO (UI only)
var car_name := "Eisenach Monarch"
var country := "Germany"
var engine := "V12 5.4L"
var weight_kg := 2050
var zero_to_hundred_display := 6.60

func _ready():
	# GAMEPLAY STATS
	mass = 2050.0
	horsepower = 322
	max_rpm = 6000.0
	zero_to_hundred = 6.6
	top_speed_kmh = 265
	turn_speed = 2.4
	brake_strength = 10.5
	lateral_friction = 1.00
	transmission = "Rear-wheel drive"

	handling_type = "luxury_boat"

	apply_stats()
	print("Child READY loaded:", car_name)
