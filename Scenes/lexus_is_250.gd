extends CarController

# COSMETIC INFO (UI only)
var def_car_name := "Kuro Zephyr"
var country := "Japan"
var engine := "V6 2.5L"
var weight_kg := 1600
var zero_to_hundred_display := 7.30  # Calm RWD launch, beginner-friendly

func _ready():
	# GAMEPLAY STATS
	mass = 1600.0
	horsepower = 204                 # 4GR-FSE V6 output
	max_rpm = 6400.0                 # Smooth, mid-range Lexus rev band
	zero_to_hundred = 7.3
	top_speed_kmh = 234              # IS250 real-world top speed
	turn_speed = 2.35                # Softer than IS350; stable beginner handling
	brake_strength = 11.0            # Comfort brakes, not too sharp
	lateral_friction = 1.10         # Medium grip; safe, predictable rotation
	transmission = "Rear wheel drive"

	# IS250-style handling (Calm, balanced, beginner-friendly, stable under throttle)

	# Toyota/Lexus 4GR-FSE 6-Speed Automatic Gearing
	gear_count = 6
	gear_ratios = [
		3.52,  # 1st - Smooth launch, not aggressive
		2.04,  # 2nd - Gentle pull, beginner-friendly
		1.40,  # 3rd
		1.00,  # 4th
		0.76,  # 5th
		0.56   # 6th - Highway overdrive
	]

	shift_up_rpm = 6200             # Lower redline than IS350
	shift_down_rpm = 2600

	apply_stats()
	print("Child READY loaded:", def_car_name)
