extends CarController


# COSMETIC INFO (UI only)
var car_name := "Gruber Targa"
var country := "Germany"
var engine := "V6 3.0L"
var weight_kg := 1420
var zero_to_hundred_display := 4.50

func _ready():
	# GAMEPLAY STATS
	mass = 1420.0
	horsepower = 285
	max_rpm = 7000.0
	zero_to_hundred = 4.5
	top_speed_kmh = 273
	turn_speed = 3.10
	brake_strength = 13.8
	lateral_friction = 1.18
	transmission = "Four wheel drive"

	# Porsche 993 handling (rear‑biased, agile, light front end)
	

	# 6‑speed manual‑style gearing (classic Porsche ratios)
	gear_count = 6
	gear_ratios = [
		3.82,  # 1st - strong launch, rear-biased traction
		2.20,  # 2nd
		1.52,  # 3rd
		1.18,  # 4th
		0.96,  # 5th
		0.76   # 6th - overdrive for 273 km/h
	]
	shift_up_rpm = 6800
	shift_down_rpm = 3000

	apply_stats()
	print("Child READY loaded:", car_name)
