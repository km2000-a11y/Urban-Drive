extends CarController

# COSMETIC INFO (UI only)
var car_name := "Schroder Kaiser"
var country := "Germany"
var engine := "V8 4.2L"
var weight_kg := 1780
var zero_to_hundred_display := 6.00

func _ready():
	# GAMEPLAY STATS
	mass = 1780.0
	horsepower = 330
	max_rpm = 6500.0
	zero_to_hundred = 6.0
	top_speed_kmh = 257
	turn_speed = 2.55
	brake_strength = 11.2
	lateral_friction = 1.08
	transmission = "Four wheel drive"

	handling_type = "executive_awd"

	apply_stats()
	print("Child READY loaded:", car_name)
