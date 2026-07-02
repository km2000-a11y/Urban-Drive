extends CarController

# COSMETIC INFO (UI only)
var car_name := "Eisenach Compaque"
var country := "Germany"
var engine := "L4 2.0L"
var weight_kg := 1360
var zero_to_hundred_display := 7.5

func _ready():
	# GAMEPLAY STATS
	mass = 1360.0
	horsepower = 162
	max_rpm = 4500.0        # diesels rev lower
	idle_rpm = 800.0
	zero_to_hundred = 7.5
	top_speed_kmh = 223
	turn_speed = 2.55
	brake_strength = 10.9
	lateral_friction = 1.04
	transmission = "Rear wheel drive"
	is_diesel = true

	gear_count = 6
	gear_ratios = [
		3.80,  # 1st
		2.10,  # 2nd
		1.40,  # 3rd
		1.00,  # 4th
		0.83,  # 5th
		0.68   # 6th
	]
	shift_up_rpm=4300
	shift_down_rpm=1700


	apply_stats()
	print("Child READY loaded:", car_name)
