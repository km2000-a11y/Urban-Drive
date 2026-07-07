extends CarController

# COSMETIC INFO (UI only)
var def_car_name := "Eisenach Roadstar"
var country := "Germany"
var engine := "V6 3.2L"
var weight_kg := 1600
var zero_to_hundred_display := 4.80

func _ready():
	# GAMEPLAY STATS
	mass = 1600.0
	horsepower = 335
	max_rpm = 7000.0
	zero_to_hundred = 4.8
	top_speed_kmh = 270
	turn_speed = 2.95
	brake_strength = 14.5
	lateral_friction = 1.12
	transmission = "Rear wheel drive"

	# BMW Z4 M handling (sharp, playful roadster feel)

	# TRUE 6‑speed manual (GS6‑37BZ inspired)
	gear_count = 6
	gear_ratios = [
		4.23,  # 1st - explosive S54 launch
		2.53,  # 2nd - pulls hard to ~100 km/h
		1.67,  # 3rd - main acceleration gear
		1.23,  # 4th - keeps engine in power band
		1.00,  # 5th - real Z4M 5th gear
		0.85   # 6th - tall overdrive for 270–271 km/h
	]

	shift_up_rpm = 6800
	shift_down_rpm = 2800

	apply_stats()
	print("Child READY loaded:", def_car_name)
