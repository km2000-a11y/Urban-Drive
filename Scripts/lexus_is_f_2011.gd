extends CarController

# COSMETIC INFO (UI only)
var car_name := "Kuro Supreme"
var country := "Japan"
var engine := "V8 5.0L"
var weight_kg := 1690
var zero_to_hundred_display := 4.60  # IS F real-world 0–100 time

func _ready():
	# GAMEPLAY STATS
	mass = 1690.0
	horsepower = 416              # 2UR‑GSE V8 power
	max_rpm = 6800.0              # High-revving Yamaha-tuned V8
	zero_to_hundred = 4.6
	top_speed_kmh = 280           # Updated from 273 → now matches Sport Coupe tier
	turn_speed = 2.85             # Sharp but heavy GT handling
	brake_strength = 14.0         # Brembo 6‑piston brakes
	lateral_friction = 1.14       # Big tires, big grip, still RWD
	transmission = "Rear wheel drive"

	# IS F handling: aggressive, planted, heavy but precise

	# 8‑speed Direct Shift automatic (real IS F gearbox)
	gear_count = 8
	gear_ratios = [
		3.17,  # 1st - brutal V8 launch
		2.19,  # 2nd - strong midrange pull
		1.61,  # 3rd
		1.27,  # 4th
		1.00,  # 5th
		0.82,  # 6th
		0.69,  # 7th
		0.56   # 8th - highway overdrive
	]

	shift_up_rpm = 6600
	shift_down_rpm = 3000

	apply_stats()
	print("Child READY loaded:", car_name)
