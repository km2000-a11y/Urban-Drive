extends CarController

# COSMETIC INFO (UI only)
var car_name := "Brutus Mauler"
var country := "USA"
var engine := "V8 7.4L"
var weight_kg := 1780
var zero_to_hundred_display := 5.60

func _ready():
	# GAMEPLAY STATS
	mass = 1780.0
	horsepower = 360
	max_rpm = 5600.0
	zero_to_hundred = 5.6
	top_speed_kmh = 245
	turn_speed = 2.50
	brake_strength = 12.2
	lateral_friction = 1.03
	transmission = "Rear wheel drive"

	# Chevelle SS handling (big‑block weight, straight‑line brute)
	

	# 3‑speed TH400‑style gearing (long, torque-heavy)
	gear_count = 3
	gear_ratios = [
		2.48,  # 1st - massive torque hit
		1.48,  # 2nd
		1.00   # 3rd - direct drive for 245 km/h
	]
	shift_up_rpm = 5200
	shift_down_rpm = 2300

	apply_stats()
	print("Child READY loaded:", car_name)
