extends CarController

# COSMETIC INFO (UI only)
var def_car_name := "Berkshire Blunt"
var country := "UK"
var engine := "V8 4.2L"
var weight_kg := 1832
var zero_to_hundred_display := 5.20

func _ready():
	# GAMEPLAY STATS
	mass = 1832.0
	horsepower = 396
	max_rpm = 6200.0
	zero_to_hundred = 5.2
	top_speed_kmh = 286
	turn_speed = 2.55
	brake_strength = 12.0
	lateral_friction = 1.06
	transmission = "Rear wheel drive"

	# Jaguar XKR-style handling (heavy, smooth, torque-rich GT)
	

	# Jaguar 6-speed auto (long gears, smooth shifts)
	gear_count = 6
	gear_ratios = [
		3.36,  # 1st - strong GT launch
		2.04,  # 2nd
		1.40,  # 3rd
		1.00,  # 4th
		0.75,  # 5th
		0.67   # 6th - overdrive
	]
	shift_up_rpm = 5600
	shift_down_rpm = 2000

	apply_stats()
	print("Child READY loaded:", def_car_name)
	
