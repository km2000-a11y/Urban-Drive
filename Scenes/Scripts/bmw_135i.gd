extends CarController

# COSMETIC INFO (UI only)
var def_car_name := "Eisenach Bengal"
var country := "Germany"
var engine := "L6 3.0L Twin‑Turbo"
var weight_kg := 1650
var zero_to_hundred_display := 5.50

func _ready():
	# GAMEPLAY STATS
	mass = 1650.0
	horsepower = 306
	max_rpm = 7000.0
	zero_to_hundred = 5.5
	top_speed_kmh = 260
	turn_speed = 2.90              # slightly softer than Z4M, playful turbo cabrio feel
	brake_strength = 13.8          # heavier car, slightly longer stopping distance
	lateral_friction = 1.10        # less razor‑sharp than S54 roadster
	transmission = "Rear wheel drive"

	# 135i Cabrio handling (agile, turbo shove, short‑wheelbase chaos)

	# 6‑speed sport automatic / manual‑mapped ratios (GS6‑17/GS6‑53 inspired)
	gear_count = 6
	gear_ratios = [
		4.06,  # 1st - strong turbo launch
		2.40,  # 2nd - pulls hard to ~95 km/h
		1.58,  # 3rd - main acceleration gear
		1.19,  # 4th - keeps boost alive
		1.00,  # 5th - direct drive
		0.84   # 6th - long overdrive for 260 km/h
	]

	shift_up_rpm = 6600
	shift_down_rpm = 2800

	apply_stats()
	print("Child READY loaded:", def_car_name)
