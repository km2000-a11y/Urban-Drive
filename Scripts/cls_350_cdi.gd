extends CarController

# COSMETIC INFO (UI only)
var car_name := "Kronstadt Blade"
var country := "Germany"
var engine := "V6 3.0L"
var weight_kg := 1810
var zero_to_hundred_display := 5.9

func _ready():
	# GAMEPLAY STATS
	mass = 1810.0
	horsepower = 266
	max_rpm = 4500.0
	zero_to_hundred = 5.9
	top_speed_kmh = 250
	turn_speed = 2.45
	brake_strength = 11.0
	lateral_friction = 1.06
	transmission = "Rear-wheel drive"
	is_diesel = true

	
	gear_count = 6
	gear_ratios = [3.9, 2.2, 1.6, 1.3, 1.08, 0.88]
	shift_up_rpm = 4200
	shift_down_rpm = 1600

	apply_stats()
	print("Child READY loaded:", car_name)
