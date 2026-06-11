extends CarController

# COSMETIC INFO (UI only)
var car_name := "Eisenach Q‑3"
var country := "Germany"
var engine := "V6 2.5L"
var weight_kg := 1380
var zero_to_hundred_display := 7.20

func _ready():
	# GAMEPLAY STATS
	mass = 1380.0
	horsepower = 192
	max_rpm = 6500.0
	zero_to_hundred = 7.2
	top_speed_kmh = 240
	turn_speed = 2.7
	brake_strength = 11.0
	lateral_friction = 1.05
	transmission = "Rear wheel drive"

	handling_type = "light_sport"

	apply_stats()
	apply_handling_profile()
