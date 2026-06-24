extends AI_Car

# COSMETIC INFO (UI only)
var car_name := "Kuro Fortress"
var country := "Japan"
var engine := "V8 4.7L"
var weight_kg := 2560
var zero_to_hundred_display := 8.90

func _ready():
	# GAMEPLAY STATS
	mass = 2560.0
	horsepower = 235
	max_rpm = 4800.0            # Toyota 2UZ-FE V8 redlines lower but has great low-end grunt
	zero_to_hundred = 8.9
	top_speed_kmh = 203
	turn_speed = 2.05           # Slightly more agile than the H2 due to shedding 340 kg
	brake_strength = 13.2       # Lighter weight requires slightly less brute braking force
	lateral_friction = 1.03     # Good 4WD pavement grip for a vehicle of this size
	transmission = "Four wheel drive"

	# Toyota/Lexus A340F 5-Speed Gearing (optimized for smooth acceleration and that 8.9s launch)
	gear_count = 5
	gear_ratios = [
		3.52,  # 1st - short and punchy to get the 2.5 tons moving instantly
		2.04,  # 2nd
		1.40,  # 3rd
		1.00,  # 4th
		0.71   # 5th - overdrive cruiser
	]
	shift_up_rpm = 4500
	shift_down_rpm = 2000

	# DISTINCT HANDLING PROFILE (Plush but heavy luxury brawler)
	handling_type = "luxury_boat"

	# APPLY STATS + HANDLING
	apply_stats()
	apply_handling_profile()

	print("Child READY loaded:", car_name)
