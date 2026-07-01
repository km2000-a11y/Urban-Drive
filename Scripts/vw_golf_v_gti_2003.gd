extends CarController

# COSMETIC INFO (UI only)
var car_name := "Straeda G25"
var country := "Germany"
var engine := "L4 2.0L"
var weight_kg := 1350
var zero_to_hundred_display := 6.9

func _ready():
	# GAMEPLAY STATS
	mass = 1350.0
	horsepower = 197
	max_rpm = 6500.0
	zero_to_hundred = 6.9
	top_speed_kmh = 233
	turn_speed = 2.7
	brake_strength = 10.8
	lateral_friction = 1.03
	transmission = "Front-wheel drive"

	

	apply_stats()
	print("Child READY loaded:", car_name)
