extends CarController

# COSMETIC INFO (UI only)
var def_car_name := "Schroder Atrix Sport"
var country := "Germany"
var engine := "L5 2.5L Turbo"
var weight_kg := 1470
var zero_to_hundred_display := 4.60

func _ready():
	# GAMEPLAY STATS
	mass = 1470.0
	horsepower = 340
	max_rpm = 7000.0
	zero_to_hundred = 4.6
	top_speed_kmh = 266
	turn_speed = 2.9
	brake_strength = 22.0
	lateral_friction = 1.22
	transmission = "Four wheel drive"

	# SHIFT LOGIC
	shift_up_rpm = 6800
	shift_down_rpm = 3000

	# REAL TT RS GEARING (close-ratio AWD turbo)
	gear_count = 6
	gear_ratios = [
		3.46,  # 1st
		2.05,  # 2nd
		1.46,  # 3rd
		1.13,  # 4th
		0.97,  # 5th
		0.84   # 6th
	]

	# AWD turbo coupe handling (sharp, planted, punchy)

	apply_stats()
	print("Child READY loaded:", def_car_name)
