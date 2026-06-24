extends AI_Car

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
	transmission = "Rear wheel drive"

	handling_type = "luxury_boat"

	# REAL E38 750iL GEAR RATIOS
	gear_count = 5
	gear_ratios = [
		3.57,  # 1st
		2.20,  # 2nd
		1.56,  # 3rd
		1.19,  # 4th
		1.00   # 5th
	]
	

	# SHIFT LOGIC (luxury V12 behavior)
	shift_up_rpm = 5700
	shift_down_rpm = 1800

	apply_stats()
	print("Child READY loaded:", car_name)
