extends CarController

# COSMETIC INFO (UI only)
var def_car_name := "Eisenach Suppressor"
var country := "Germany"
var engine := "V6 3.0L Twin‑Turbo Diesel"
var weight_kg := 1660
var zero_to_hundred_display := 5.70

func _ready():
	# GAMEPLAY STATS
	mass = 1660.0
	horsepower = 272
	max_rpm = 4800.0
	zero_to_hundred = 5.7
	top_speed_kmh = 245
	turn_speed = 2.65
	brake_strength = 12.8
	lateral_friction = 1.06
	transmission = "Rear wheel drive"

	# Diesel torque curve (massive low‑end pull, early redline)
	# ZF 6HP automatic behavior (long gears, smooth shifts)
	gear_count = 6
	gear_ratios = [
		4.17,  # 1st - huge torque launch
		2.34,  # 2nd - main acceleration gear
		1.52,  # 3rd - diesel mid‑range punch
		1.14,  # 4th - highway gear
		0.87,  # 5th - long pull
		0.69   # 6th - overdrive for 245 km/h
	]

	# SHIFT LOGIC (diesel: early upshift, low redline)
	shift_up_rpm = 4300
	shift_down_rpm = 1700
	is_diesel=true

	apply_stats()
	print("Child READY loaded:", def_car_name)
