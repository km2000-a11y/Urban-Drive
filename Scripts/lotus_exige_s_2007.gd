extends CarController

# COSMETIC INFO (UI only)
var def_car_name := "Kestrel Seabird"
var country := "UK"
var engine := "L4 1.8L"
var weight_kg := 935
var zero_to_hundred_display := 4.30

func _ready():
	# GAMEPLAY STATS
	mass = 935.0
	horsepower = 217
	max_rpm = 8000.0
	zero_to_hundred = 4.5
	top_speed_kmh = 238
	turn_speed = 3.6
	brake_strength = 22.0
	lateral_friction = 1.26
	transmission = "Rear wheel drive"

	

	apply_stats()
	
	print("Child READY loaded:", def_car_name)
