extends CarController

# COSMETIC INFO (UI only)
var def_car_name := "Eisenach Goliath"
var country := "Germany"
var engine := "V10 5.0L"
var weight_kg := 1720
var zero_to_hundred_display := 4.40

func _ready():
	# GAMEPLAY STATS
	mass = 1720.0
	horsepower = 500
	max_rpm = 8250.0
	zero_to_hundred = 4.4
	top_speed_kmh = 307
	turn_speed = 3.05
	brake_strength = 14.2
	lateral_friction = 1.12
	transmission = "Rear wheel drive"

	# E60 M5-style handling (aggressive, high-r
	# SMG III 7-speed single-clutch (violent shifts, short mid gears)
	gear_count = 7
	gear_ratios = [
		4.00,  # 1st - brutal launch, traction struggles
		2.60,  # 2nd - early V10 scream
		1.90,  # 3rd - main acceleration gear
		1.44,  # 4th - highway pull begins
		1.17,  # 5th - mid-high speed
		0.94,  # 6th - long gear for 250–290 km/h
		0.79   # 7th - overdrive for 307 km/h
	]

	# SHIFT LOGIC (high-rev V10 insanity)
	shift_up_rpm = 8000
	shift_down_rpm = 3000

	apply_stats()
	print("Child READY loaded:", def_car_name)
