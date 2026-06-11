extends CarController

# COSMETIC INFO (UI only)
var car_name := "Eisenach Escorter"
var country := "Germany"
var engine := "V8 4.6L"
var weight_kg := 2188
var zero_to_hundred_display := 7.30

func _ready():
	# GAMEPLAY STATS
	mass = 2188.0
	horsepower = 290
	max_rpm = 6000.0
	zero_to_hundred = 7.3
	top_speed_kmh = 240
	turn_speed = 2.1
	brake_strength = 13.0
	lateral_friction = 1.05
	transmission = "Four wheel drive"

	# X5-style gearing (German SUV, smooth + long legs)
	gear_count = 5
	gear_ratios = [
		3.91,  # 1st - strong launch for a heavy AWD SUV
		2.20,  # 2nd
		1.52,  # 3rd
		1.00,  # 4th
		0.83   # 5th - overdrive for 240 km/h
	]
	shift_up_rpm = 5600
	shift_down_rpm = 2200

	# DISTINCT HANDLING PROFILE
	handling_type = "awd_grip"

	# APPLY STATS + HANDLING
	apply_stats()
	apply_handling_profile()

	print("Child READY loaded:", car_name)
