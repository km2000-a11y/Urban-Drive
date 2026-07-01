extends CarController

# COSMETIC INFO (UI only)
var car_name := "Kuro Dashibara"
var country := "Japan"
var engine := "V8 4.0L"
var weight_kg := 1540
var zero_to_hundred_display := 5.20

func _ready():
	# GAMEPLAY STATS
	mass = 1540.0
	horsepower = 295
	max_rpm = 6200.0
	zero_to_hundred = 5.2
	top_speed_kmh = 265
	turn_speed = 2.70
	brake_strength = 12.4
	lateral_friction = 1.08
	transmission = "Rear wheel drive"

	# SC400-style handling (smooth GT, stable at high speed, gentle rotation)
	handling_type = "grand_tourer"

	# Fictional 5-speed GT automatic (long gears, smooth acceleration)
	gear_count = 5
	gear_ratios = [
		3.10,  # 1st - strong GT launch
		1.98,  # 2nd - smooth mid pull
		1.40,  # 3rd - highway transition
		1.00,  # 4th - main GT gear
		0.72   # 5th - long overdrive for 265 km/h
	]
	shift_up_rpm = 6000
	shift_down_rpm = 2200

	apply_stats()
	print("Child READY loaded:", car_name)
