extends CarController

# COSMETIC INFO (UI only)
var def_car_name := "Eisenach Compaque"
var country := "Germany"
var engine := "V6 3.0L"
var weight_kg := 1450
var zero_to_hundred_display := 6.90   # Sporty RWD launch, lively but not extreme

func _ready():
	# GAMEPLAY STATS
	mass = 1450.0
	horsepower = 215                 # N52B30 detuned 125i output
	max_rpm = 6800.0                 # Straight-six rev band, smoother & higher than IS250
	zero_to_hundred = 6.9
	top_speed_kmh = 238              # Real-world 125i top speed
	turn_speed = 2.65                # Sharper than IS250, playful BMW rotation
	brake_strength = 11.4            # Sport brakes, firmer bite than Lexus
	lateral_friction = 1.18          # More grip; confident cornering without being twitchy
	transmission = "Rear wheel drive"

	# 125i-style handling (light, playful, responsive, proper BMW balance)

	# BMW 6-Speed Manual Gearing (realistic ratios)
	gear_count = 6
	gear_ratios = [
		4.35,  # 1st - Strong launch, straight-six torque
		2.50,  # 2nd - Good pull, lively mid-range
		1.66,  # 3rd - Sporty acceleration
		1.23,  # 4th
		1.00,  # 5th - Direct drive
		0.85   # 6th - Highway gear
	]

	shift_up_rpm = 6600             # High-rev BMW character
	shift_down_rpm = 2800

	apply_stats()
	print("Child READY loaded:", def_car_name)
