extends CarController

# COSMETIC INFO (UI only)
var car_name := "Brutus Predator"
var country := "USA"
var engine := "V8 7.0L"
var weight_kg := 1250
var zero_to_hundred_display := 3.70

func _ready():
	# GAMEPLAY STATS
	mass = 1250.0
	horsepower = 550
	max_rpm = 6800.0
	zero_to_hundred = 3.7
	top_speed_kmh = 325
	turn_speed = 3.05
	brake_strength = 14.2
	lateral_friction = 1.18
	transmission = "Rear wheel drive"

	# Saleen S7 handling (analog American supercar, razor sharp front, light rear)
	# High downforce feel, very responsive steering, low weight behavior

	# 6‑speed manual (race‑car gearing, strong acceleration, high top speed)
	gear_count = 6
	gear_ratios = [
		2.97,  # 1st - brutal V8 launch
		2.07,  # 2nd - strong pull
		1.43,  # 3rd
		1.14,  # 4th
		0.97,  # 5th
		0.79   # 6th - long overdrive for 325 km/h
	]

	shift_up_rpm = 6500
	shift_down_rpm = 3000

	apply_stats()
	print("Child READY loaded:", car_name)
