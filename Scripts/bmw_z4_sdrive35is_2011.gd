extends CarController

# COSMETIC INFO (UI only)
var car_name := "Eisenach Roadstar"
var country := "Germany"
var engine := "V6 3.0L"
var weight_kg := 1600
var zero_to_hundred_display := 4.40

func _ready():
	# GAMEPLAY STATS
	mass = 1600.0
	horsepower = 335
	max_rpm = 7000.0
	zero_to_hundred = 4.8
	top_speed_kmh = 250
	turn_speed = 2.95
	brake_strength = 14.5
	lateral_friction = 1.12
	transmission = "Rear wheel drive"

	# BMW Z4 handling (sharp, playful roadster feel)
	

	# 7‑speed DCT‑style gearing (short, punchy)
	gear_count = 7
	gear_ratios = [
		3.15,  # 1st - strong launch
		2.10,  # 2nd
		1.67,  # 3rd
		1.25,  # 4th
		1.00,  # 5th
		0.82,  # 6th
		0.67   # 7th - overdrive for 265 km/h
	]
	shift_up_rpm = 6800
	shift_down_rpm = 2760

	apply_stats()
	print("Child READY loaded:", car_name)
	
